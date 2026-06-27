import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/expert_provider.dart';
import '../../models/chat_models.dart';
import '../../models/expert_model.dart';
import 'chat_screen.dart';

// ══════════════════════════════════════════════════════════════════
// Data Model for UI Compatibility
// ══════════════════════════════════════════════════════════════════
class ConversationModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final Color avatarColor;
  final String? avatarText;
  final bool isSupportChat;
  final String role;

  const ConversationModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    required this.avatarColor,
    this.avatarText,
    this.isSupportChat = false,
    required this.role,
  });
}

// ══════════════════════════════════════════════════════════════════
// Conversations Screen
// ══════════════════════════════════════════════════════════════════
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late AnimationController _animCtrl;
  late List<Animation<double>> _itemAnims;

  String _searchQuery = '';
  bool _isSearchFocused = false;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnims = List.generate(
      50,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animCtrl,
          curve: Interval(
            (i * 0.08).clamp(0.0, 0.9),
            (i * 0.08 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animCtrl.forward();

    _searchFocus.addListener(
      () => setState(() => _isSearchFocused = _searchFocus.hasFocus),
    );
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = int.tryParse(authProvider.user?.id ?? '') ?? 0;
      if (userId > 0) {
        Provider.of<ChatProvider>(context, listen: false).init(userId);
      }
      Provider.of<ExpertProvider>(context, listen: false).fetchExperts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  ConversationModel _mapToUIModel(ConversationDetailModel realConv, ChatProvider provider) {
    final name = realConv.participant.name;
    final lastMessage = realConv.lastMessage;
    final timeStr = _formatTimestamp(realConv.lastMessageAt);
    final color = _generateAvatarColor(name);
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final isTyping = provider.getTypingStatus(realConv.id) != null;

    return ConversationModel(
      id: realConv.id.toString(),
      name: name,
      lastMessage: isTyping ? 'Typing...' : lastMessage,
      time: timeStr,
      unreadCount: realConv.unreadCount,
      isOnline: false,
      isTyping: isTyping,
      avatarColor: color,
      avatarText: initials.isNotEmpty ? initials : null,
      isSupportChat: name.toLowerCase().contains('support') || name.toLowerCase().contains('team'),
      role: realConv.participant.role,
    );
  }

  Color _generateAvatarColor(String name) {
    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFF26A69A),
      const Color(0xFFEC407A),
      const Color(0xFFFF7043),
      const Color(0xFF7E57C2),
      const Color(0xFF29B6F6),
    ];
    if (name.isEmpty) return colors[0];
    final hash = name.codeUnits.fold(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dateTime.day} ${months[dateTime.month - 1]}';
    }
  }

  List<ConversationModel> get _filtered {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final mappedConvs = chatProvider.conversations.map((rc) => _mapToUIModel(rc, chatProvider)).toList();

    if (_searchQuery.isEmpty) return mappedConvs;
    return mappedConvs
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.role.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  int get _totalUnread {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return chatProvider.conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildOnlineRow(),
              if (_isSearchVisible) ...[
                _buildSearchBar(),
                const SizedBox(height: 4),
              ],
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final conv = _filtered[i];
                              final animIndex = i;
                              final anim = animIndex < _itemAnims.length
                                  ? _itemAnims[animIndex]
                                  : _itemAnims.last;

                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.3, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _ConversationTile(
                                      conversation: conv,
                                      onTap: () => _openChat(conv),
                                      onDismiss: () => _deleteConversation(conv),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'conversations_fab',
          onPressed: _showNewChatSheet,
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                if (_totalUnread > 0)
                  Text(
                    '$_totalUnread unread message${_totalUnread > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Text(
                    'Your expert conversations',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchCtrl.clear();
                  _searchFocus.unfocus();
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSearchVisible ? AppColors.primarySoft : AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchVisible ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Icon(
                _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                color: _isSearchVisible ? AppColors.primary : AppColors.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineRow() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final onlineConvs = chatProvider.conversations
        .map((rc) => _mapToUIModel(rc, chatProvider))
        .where((c) => c.isOnline)
        .toList();

    if (onlineConvs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: onlineConvs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final conv = onlineConvs[i];
          return GestureDetector(
            onTap: () => _openChat(conv),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: conv.avatarColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                      child: _AvatarContent(conv: conv),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 54,
                  child: Text(
                    conv.name.split(' ')[0],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSearchFocused ? AppColors.primary : AppColors.line,
            width: _isSearchFocused ? 1.8 : 1.2,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                color: _isSearchFocused ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                     width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try starting a conversation with an expert',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  void _openChat(ConversationModel conv) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final realConv = chatProvider.conversations.firstWhere((rc) => rc.id.toString() == conv.id);
    chatProvider.selectConversation(realConv);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
    );
  }

  void _deleteConversation(ConversationModel conv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation with ${conv.name} deleted'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showNewChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _NewChatSheet(
        onSelect: (expert) async {
          Navigator.pop(context);
          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
          
          final existingConv = chatProvider.conversations.firstWhere(
            (c) => c.participant.id.toString() == expert.userId,
            orElse: () => ConversationDetailModel(
              id: -1,
              participant: ChatParticipantModel(id: -1, name: '', role: ''),
              lastMessage: '',
              lastMessageAt: DateTime.now(),
              unreadCount: 0,
            ),
          );

          if (existingConv.id != -1) {
            await chatProvider.selectConversation(existingConv);
            final uiModel = _mapToUIModel(existingConv, chatProvider);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: uiModel)));
          } else {
            final recId = int.tryParse(expert.userId ?? '') ?? 0;
            if (recId > 0) {
              await chatProvider.startNewConversation(recId, "Hello! I am interested in connecting with you.");
              if (chatProvider.activeConversation != null) {
                final uiModel = _mapToUIModel(chatProvider.activeConversation!, chatProvider);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: uiModel)));
              }
            }
          }
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 2),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: conversation.unreadCount > 0
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.line,
              width: conversation.unreadCount > 0 ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  conversation.unreadCount > 0 ? 0.07 : 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: conversation.avatarColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: conversation.avatarColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _AvatarContent(conv: conversation),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                conversation.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: conversation.unreadCount > 0
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              if (conversation.isSupportChat) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Support',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          conversation.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: conversation.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.muted,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.role,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: conversation.isTyping
                              ? const _TypingIndicator()
                              : Text(
                                  conversation.lastMessage,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: conversation.unreadCount > 0
                                        ? AppColors.ink
                                        : AppColors.muted,
                                    fontWeight: conversation.unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${conversation.unreadCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.2, i * 0.2 + 0.6, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'typing',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _dotAnims[i],
            builder: (_, _) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Transform.translate(
                offset: Offset(0, -3 * _dotAnims[i].value),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _NewChatSheet extends StatelessWidget {
  final ValueChanged<ExpertModel> onSelect;

  const _NewChatSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final experts = Provider.of<ExpertProvider>(context).experts;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'New Conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select an expert to start chatting',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (experts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No experts available', style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: experts.length,
                itemBuilder: (context, index) {
                  final expert = experts[index];
                  final initials = expert.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: expert.avatarColor,
                      child: expert.profileImage != null
                          ? ClipOval(child: Image.network(expert.profileImage!, fit: BoxFit.cover, width: 40, height: 40))
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                    title: Text(
                      expert.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      expert.title,
                      style: TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                    trailing: expert.isOnline
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          )
                        : null,
                    onTap: () => onSelect(expert),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _selected = 'All';
  final _filters = ['All', 'Unread', 'Online', 'Support'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Filter Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _filters.map((f) {
              final sel = _selected == f;
              return GestureDetector(
                onTap: () => setState(() => _selected = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.field,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.line,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.white : AppColors.ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
