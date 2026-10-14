import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_models.dart';
import '../../providers/chat_provider.dart';
import 'video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;
  bool _isTyping = false;
  bool _showEmoji = false;

  late ChatProvider _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );

    _msgCtrl.addListener(() {
      final typing = _msgCtrl.text.isNotEmpty;
      if (typing != _isTyping) setState(() => _isTyping = typing);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.conversation.id.isNotEmpty) {
        _chatProvider.fetchMessages(widget.conversation.id);
        _chatProvider.joinConversation(widget.conversation.id);
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    if (widget.conversation.id.isNotEmpty) {
      _chatProvider.leaveConversation(widget.conversation.id);
    }
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();

    try {
      if (widget.conversation.id.isEmpty) {
        await _chatProvider.sendMessage(
          recipientId: widget.conversation.participantId,
          text: text,
        );
        await _chatProvider.fetchConversations();
        
        final newConv = _chatProvider.conversations.firstWhere(
          (c) => c.participantId == widget.conversation.participantId,
          orElse: () => widget.conversation,
        );
        
        if (newConv.id.isNotEmpty && mounted) {
          _chatProvider.joinConversation(newConv.id);
          _chatProvider.fetchMessages(newConv.id);
        }
      } else {
        await _chatProvider.sendMessage(
          conversationId: widget.conversation.id,
          text: text,
        );
      }
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        _scrollToBottom();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F4),
            body: Column(
              children: [
                // ── App Bar ──────────────────────────
                _buildAppBar(),

                // ── Messages ─────────────────────────
                Expanded(
                  child: chatProvider.isLoadingMessages && chatProvider.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _buildMessages(chatProvider.messages),
                ),

                // ── Input ────────────────────────────
                _buildInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── App Bar ────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  // Back
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.conversation.avatarColor,
                          shape: BoxShape.circle,
                        ),
                        child: _AvatarContent(conv: widget.conversation),
                      ),
                      if (widget.conversation.isOnline)
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Name + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conversation.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          widget.conversation.isOnline
                              ? 'Online now'
                              : 'Last seen recently',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.conversation.isOnline
                                ? const Color(0xFF4CAF50)
                                : AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _appBarBtn(Icons.videocam_rounded, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          conversationId: widget.conversation.id,
                          participantId: widget.conversation.participantId ?? '',
                          participantName: widget.conversation.name,
                          isCaller: true,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  _appBarBtn(Icons.call_rounded, () {}),
                  const SizedBox(width: 4),
                  _appBarBtn(Icons.more_vert_rounded, _showMoreMenu),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.line),
          ],
        ),
      ),
    );
  }

  Widget _appBarBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }

  // ── Messages ───────────────────────────────────────────────────
  Widget _buildMessages(List<ChatMessage> messagesList) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: messagesList.length,
      itemBuilder: (_, i) {
        final msg = messagesList[i];
        final prev = i > 0 ? messagesList[i - 1] : null;
        final showTime = prev == null || prev.isSent != msg.isSent;

        return Column(
          children: [
            if (i == 0) _DateLabel(label: 'Today'),
            _MessageBubble(
              message: msg,
              showAvatar: !msg.isSent && showTime,
              conversation: widget.conversation,
            ),
          ],
        );
      },
    );
  }

  // ── Input Bar ──────────────────────────────────────────────────
  Widget _buildInput() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Column(
        children: [
          Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment
              GestureDetector(
                onTap: _showAttachmentSheet,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Text field
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _isFocused ? AppColors.primary : AppColors.line,
                      width: _isFocused ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: AppColors.muted.withValues(alpha:  0.7),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      // Emoji
                      GestureDetector(
                        onTap: () => setState(() => _showEmoji = !_showEmoji),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 10),
                          child: Text(
                            '😊',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Send
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isTyping ? AppColors.primary : AppColors.line,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isTyping
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha:  0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                    color: _isTyping ? AppColors.white : AppColors.muted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Send Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachBtn(
                  Icons.image_rounded,
                  'Image',
                  const Color(0xFF26A69A),
                ),
                _attachBtn(
                  Icons.insert_drive_file_rounded,
                  'Document',
                  const Color(0xFF5C6BC0),
                ),
                _attachBtn(Icons.videocam_rounded, 'Video', Colors.orange),
                _attachBtn(Icons.link_rounded, 'Link', Colors.teal),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _attachBtn(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha:  0.25)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _moreOption(
              Icons.person_rounded,
              'View Profile',
              AppColors.primary,
            ),
            _moreOption(
              Icons.calendar_today_rounded,
              'Book Session',
              Colors.deepPurple,
            ),
            _moreOption(
              Icons.notifications_off_outlined,
              'Mute Notifications',
              Colors.orange,
            ),
            _moreOption(
              Icons.delete_outline_rounded,
              'Clear Chat',
              Colors.redAccent,
            ),
            _moreOption(Icons.block_rounded, 'Block User', Colors.redAccent),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _moreOption(IconData icon, String label, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha:  0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Message Bubble
// ══════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final ConversationModel conversation;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: message.isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Received avatar
          if (!message.isSent) ...[
            if (showAvatar)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: conversation.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: _AvatarContent(conv: conversation),
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: GestureDetector(
              onLongPress: () {},
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: message.isSent ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.isSent ? 18 : 4),
                    bottomRight: Radius.circular(message.isSent ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:  0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: message.isSent
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: message.isSent ? AppColors.white : AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: message.isSent
                                ? Colors.white.withValues(alpha:  0.7)
                                : AppColors.muted,
                          ),
                        ),
                        if (message.isSent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == 'read'
                                ? Icons.done_all_rounded
                                : message.status == 'delivered'
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 13,
                            color: message.status == 'read'
                                ? Colors.lightBlueAccent
                                : Colors.white.withValues(alpha:  0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (message.isSent) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Date Label
// ══════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════
// Avatar Content
// ══════════════════════════════════════════════════════════════════
class _AvatarContent extends StatelessWidget {
  final ConversationModel conv;

  const _AvatarContent({required this.conv});

  @override
  Widget build(BuildContext context) {
    if (conv.isSupportChat) {
      return const Icon(
        Icons.support_agent_rounded,
        color: Colors.white,
        size: 28,
      );
    }
    if (conv.avatarText != null) {
      return Center(
        child: Text(
          conv.avatarText!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }
    return const Icon(Icons.person_rounded, color: Colors.white, size: 30);
  }
}

// ══════════════════════════════════════════════════════════════════
// Date Label
// ══════════════════════════════════════════════════════════════════
class _DateLabel extends StatelessWidget {
  final String label;
  const _DateLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
