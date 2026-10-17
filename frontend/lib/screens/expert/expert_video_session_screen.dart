import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'expert_session_notes_screen.dart';

class ExpertVideoSessionScreen extends StatefulWidget {
  final String menteeName;
  final String sessionTitle;
  final String menteeAvatar;

  const ExpertVideoSessionScreen({
    super.key,
    this.menteeName = 'Priya Mehta',
    this.sessionTitle = 'Flutter Architecture & Career Guidance',
    this.menteeAvatar =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=300',
  });

  @override
  State<ExpertVideoSessionScreen> createState() =>
      _ExpertVideoSessionScreenState();
}

class _ExpertVideoSessionScreenState extends State<ExpertVideoSessionScreen> {
  bool _isMicMuted = false;
  bool _isVideoOff = false;
  bool _isScreenSharing = false;
  bool _isNotesPanelOpen = false;
  final TextEditingController _liveNotesCtrl = TextEditingController(
    text: '• Discussed Provider vs Riverpod\n• Reviewed SQLite caching setup',
  );

  int _remainingSeconds = 45 * 60 - 415; // ~38 mins remaining
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _liveNotesCtrl.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Stack(
          children: [
            // Mentee Video Feed (Main Area)
            Positioned.fill(
              child: _buildMenteeVideoFeed(),
            ),

            // Top Status Bar (Timer, Mentee name, Recording badge)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildTopBar(),
            ),

            // Picture-in-picture Expert Self View
            Positioned(
              top: 80,
              right: 16,
              child: _buildExpertSelfView(),
            ),

            // In-Call Live Notes Drawer (Slide-up or Overlay)
            if (_isNotesPanelOpen)
              Positioned(
                left: 16,
                right: 16,
                bottom: 110,
                child: _buildLiveNotesPanel(),
              ),

            // Bottom Call Controls Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: _buildControlsDock(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenteeVideoFeed() {
    return Container(
      color: const Color(0xFF1F2937),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background simulation image
          Opacity(
            opacity: 0.9,
            child: Image.network(
              widget.menteeAvatar,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.person, size: 80, color: Colors.white54),
              ),
            ),
          ),
          // Subtle gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (_isScreenSharing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.screen_share_rounded,
                      color: AppColors.primary, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'You are sharing your screen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.menteeName} can see your code editor',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mentee tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.menteeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Session Timer countdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: Color(0xFFFFB300), size: 16),
              const SizedBox(width: 6),
              Text(
                _formatTimer(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertSelfView() {
    return Container(
      width: 95,
      height: 135,
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isVideoOff)
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white60, size: 28),
                  SizedBox(height: 4),
                  Text('Video Off',
                      style: TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              )
            else
              Container(
                color: const Color(0xFF0F766E),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 36),
                      SizedBox(height: 4),
                      Text('You (Expert)',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isMicMuted ? 'Muted' : 'Live',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: _isMicMuted ? Colors.redAccent : const Color(0xFF22C55E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveNotesPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Live In-Session Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.muted),
                onPressed: () => setState(() => _isNotesPanelOpen = false),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _liveNotesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Jot down agenda notes and questions to cover...',
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsDock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Mic toggle
            _buildDockIcon(
              icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              isActive: !_isMicMuted,
              activeColor: Colors.white,
              onTap: () => setState(() => _isMicMuted = !_isMicMuted),
            ),

            // Video toggle
            _buildDockIcon(
              icon: _isVideoOff
                  ? Icons.videocam_off_rounded
                  : Icons.videocam_rounded,
              isActive: !_isVideoOff,
              activeColor: Colors.white,
              onTap: () => setState(() => _isVideoOff = !_isVideoOff),
            ),

            // Screen Share toggle
            _buildDockIcon(
              icon: Icons.screen_share_rounded,
              isActive: _isScreenSharing,
              activeColor: AppColors.primary,
              onTap: () => setState(() => _isScreenSharing = !_isScreenSharing),
            ),

            // Notes toggle
            _buildDockIcon(
              icon: Icons.edit_note_rounded,
              isActive: _isNotesPanelOpen,
              activeColor: const Color(0xFFFFB300),
              onTap: () =>
                  setState(() => _isNotesPanelOpen = !_isNotesPanelOpen),
            ),

            // End Call / Complete Session
            GestureDetector(
              onTap: _confirmEndSession,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.call_end_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIcon({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.redAccent.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : Colors.redAccent,
          size: 22,
        ),
      ),
    );
  }

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('End Mentorship Session?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you ready to end the video call and complete the session summary notes for your mentee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpertSessionNotesScreen(
                    menteeName: widget.menteeName,
                    sessionTitle: widget.sessionTitle,
                  ),
                ),
              );
            },
            child: const Text('End & Add Notes',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
