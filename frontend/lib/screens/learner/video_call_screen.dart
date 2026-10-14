import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final bool isCaller;
  final Map<String, dynamic>? incomingOffer;

  const VideoCallScreen({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    required this.isCaller,
    this.incomingOffer,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isConnected = false;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _setupCall();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _setupCall() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Register Callbacks from ChatProvider
    chatProvider.onCallAnsweredCallback = _handleCallAnswered;
    chatProvider.onIceCandidateReceivedCallback = _handleIceCandidate;
    chatProvider.onCallRejectedCallback = _handleCallRejected;
    chatProvider.onCallHungupCallback = _handleCallHungup;

    // Request camera and microphone permissions at runtime
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus != PermissionStatus.granted || microphoneStatus != PermissionStatus.granted) {
      _showToastAndExit('Camera and Microphone permissions are required to make video calls.');
      return;
    }

    try {
      // 1. Get Local Media Stream
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': '640',
          'height': '480',
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      if (mounted) setState(() {});

      // 2. Create Peer Connection
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // 3. Add Local Tracks to Peer Connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // 4. Track Listeners
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        debugPrint('📞 WebRTC: Got remote track');
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];
          if (mounted) {
            setState(() {
              _isConnected = true;
              _isConnecting = false;
            });
          }
        }
      };

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
          chatProvider.emitIceCandidate(
            targetId: widget.participantId,
            candidate: {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          );
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('📞 WebRTC Connection State Changed: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          if (mounted) {
            setState(() {
              _isConnected = true;
              _isConnecting = false;
            });
          }
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          _cleanUpAndExit();
        }
      };

      // 5. Handle Caller vs Recipient Setup
      if (widget.isCaller) {
        debugPrint('📞 WebRTC: Initiating call. Creating offer...');
        final offer = await _peerConnection!.createOffer({
          'offerToReceiveVideo': true,
          'offerToReceiveAudio': true,
        });
        await _peerConnection!.setLocalDescription(offer);
        
        chatProvider.emitCallUser(
          recipientId: widget.participantId,
          conversationId: widget.conversationId,
          callerName: chatProvider.currentUserId ?? 'Expert/Learner',
          offer: {
            'type': offer.type,
            'sdp': offer.sdp,
          },
        );
      } else {
        debugPrint('📞 WebRTC: Answering call. Setting remote description...');
        if (widget.incomingOffer != null) {
          final offerSdp = widget.incomingOffer!['sdp'];
          final offerType = widget.incomingOffer!['type'];
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(offerSdp, offerType),
          );

          final answer = await _peerConnection!.createAnswer({
            'offerToReceiveVideo': true,
            'offerToReceiveAudio': true,
          });
          await _peerConnection!.setLocalDescription(answer);

          chatProvider.emitAnswerCall(
            callerId: widget.participantId,
            answer: {
              'type': answer.type,
              'sdp': answer.sdp,
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error establishing WebRTC call: $e');
      _showToastAndExit('Failed to initialize call: $e');
    }
  }

  void _handleCallAnswered(Map<String, dynamic> data) async {
    debugPrint('📞 WebRTC: Call answered, setting remote description...');
    final answer = data['answer'];
    if (answer != null && _peerConnection != null) {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _handleIceCandidate(Map<String, dynamic> data) async {
    final candidateData = data['candidate'];
    if (candidateData != null && _peerConnection != null) {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        ),
      );
    }
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    debugPrint('📞 WebRTC: Call rejected by remote user');
    _showToastAndExit('Call rejected');
  }

  void _handleCallHungup(Map<String, dynamic> data) {
    debugPrint('📞 WebRTC: Call hung up by remote user');
    _showToastAndExit('Call ended');
  }

  void _toggleMute() {
    if (_localStream == null) return;
    final audioTrack = _localStream!.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
      setState(() {
        _isMuted = !audioTrack.enabled;
      });
    }
  }

  void _toggleVideo() {
    if (_localStream == null) return;
    final videoTrack = _localStream!.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      videoTrack.enabled = !videoTrack.enabled;
      setState(() {
        _isVideoOff = !videoTrack.enabled;
      });
    }
  }

  void _hangup() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.emitHangup(targetId: widget.participantId);
    _cleanUpAndExit();
  }

  void _cleanUpAndExit() {
    // Clear Callbacks in ChatProvider
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.onCallAnsweredCallback = null;
    chatProvider.onIceCandidateReceivedCallback = null;
    chatProvider.onCallRejectedCallback = null;
    chatProvider.onCallHungupCallback = null;
    chatProvider.clearIncomingCall();

    // Close Peer Connection and Renderers
    _localStream?.dispose();
    _peerConnection?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showToastAndExit(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
      _cleanUpAndExit();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote Video Stream (Full Screen) ────────────────────
          Positioned.fill(
            child: _isConnected && _remoteRenderer.srcObject != null
                ? RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: const Color(0xFF1E1E24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primarySoft,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.participantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isConnecting ? 'Connecting...' : 'Calling...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (_isConnecting)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),

          // ── Local Video Stream (PiP View) ────────────────────────
          if (_localStream != null && !_isVideoOff)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 16,
              width: 120,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.black45,
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

          // ── Call Controls Bar (Bottom Overlay) ───────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Toggle Mic
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: _isMuted ? Colors.redAccent : Colors.white24,
                  iconColor: Colors.white,
                  onPressed: _toggleMute,
                ),

                // Hang Up (End Call)
                _buildControlButton(
                  icon: Icons.call_end_rounded,
                  color: Colors.red,
                  iconColor: Colors.white,
                  size: 64,
                  iconSize: 32,
                  onPressed: _hangup,
                ),

                // Toggle Camera
                _buildControlButton(
                  icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                  color: _isVideoOff ? Colors.redAccent : Colors.white24,
                  iconColor: Colors.white,
                  onPressed: _toggleVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
    double size = 52,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

// ── Incoming Call Invitation Dialog ──────────────────────────────
class IncomingCallDialog extends StatelessWidget {
  final Map<String, dynamic> callData;

  const IncomingCallDialog({super.key, required this.callData});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final callerName = callData['callerName'] ?? 'Someone';
    final callerId = callData['callerId'] ?? '';
    final conversationId = callData['conversationId'] ?? '';
    final offer = callData['offer'];

    return WillPopScope(
      onWillPop: () async => false, // force explicit action
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ripple Animation / Circle Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primarySoft,
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Incoming Video Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline Button
                  GestureDetector(
                    onTap: () {
                      chatProvider.emitRejectCall(callerId: callerId);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Decline',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Accept Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideoCallScreen(
                            conversationId: conversationId,
                            participantId: callerId,
                            participantName: callerName,
                            isCaller: false,
                            incomingOffer: offer,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
