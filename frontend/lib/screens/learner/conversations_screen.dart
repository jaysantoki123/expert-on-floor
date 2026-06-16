import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'chat_screen.dart';

// ══════════════════════════════════════════════════════════════════
// Data Model
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

final List<ConversationModel> _dummyConversations = [
  ConversationModel(
    id: '1',
    name: 'Rahul Sharma',
    lastMessage: 'Great session! 🎉',
    time: '10 May',
    unreadCount: 2,
    isOnline: true,
    isTyping: false,
    avatarColor: const Color(0xFF5C6BC0),
    role: 'Senior Flutter Developer',
  ),
  ConversationModel(
    id: '2',
    name: 'Amit Verma',
    lastMessage: 'Thanks!',
    time: '3:55 May',
    unreadCount: 0,
    isOnline: true,
    isTyping: true,
    avatarColor: const Color(0xFF26A69A),
    role: 'Full Stack Developer',
  ),
  ConversationModel(
    id: '3',
    name: 'Sneha Iyer',
    lastMessage: 'Sure?',
    time: '2:56 May',
    unreadCount: 1,
    isOnline: false,
    isTyping: false,
    avatarColor: const Color(0xFFEC407A),
    role: 'UI/UX Designer',
  ),
  ConversationModel(
    id: '4',
    name: 'Vikram Patel',
    lastMessage: 'See you!',
    time: '1st May',
    unreadCount: 0,
    isOnline: false,
    isTyping: false,
    avatarColor: const Color(0xFFFF7043),
    avatarText: 'A',
    role: 'AI/ML Engineer',
  ),
  ConversationModel(
    id: '5',
    name: 'Mentor Support',
    lastMessage: 'How can we help?',
    time: '3rd May',
    unreadCount: 0,
    isOnline: true,
    isTyping: false,
    avatarColor: AppColors.primary,
    isSupportChat: true,
    role: 'ExpertMentor Team',
  ),
  ConversationModel(
    id: '6',
    name: 'Priya Nair',
    lastMessage: 'Let\'s schedule for next week',
    time: '28 Apr',
    unreadCount: 3,
    isOnline: true,
    isTyping: false,
    avatarColor: const Color(0xFF7E57C2),
    role: 'Data Scientist',
  ),
  ConversationModel(
    id: '7',
    name: 'Arjun Mehta',
    lastMessage: 'Docker setup done ✅',
    time: '27 Apr',
    unreadCount: 0,
    isOnline: false,
    isTyping: false,
    avatarColor: const Color(0xFF29B6F6),
    role: 'DevOps Engineer',
  ),
];

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
      _dummyConversations.length,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animCtrl,
          curve: Interval(
            i * 0.08,
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
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  List<ConversationModel> get _filtered {
    if (_searchQuery.isEmpty) return _dummyConversations;
    return _dummyConversations
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.lastMessage.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              c.role.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  int get _totalUnread =>
      _dummyConversations.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────
              _buildTopBar(),

              // ── Online Experts Row ───────────────
              _buildOnlineRow(),

              // ── Search Bar ───────────────────────
              if (_isSearchVisible) ...[
                _buildSearchBar(),
                const SizedBox(height: 4),
              ],

              // ── List ─────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final conv = _filtered[i];
                          final animIndex = _dummyConversations.indexOf(conv);
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
        // ── FAB ──────────────────────────────────
        floatingActionButton: FloatingActionButton(
          onPressed: _showNewChatSheet,
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Title + unread count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              if (_totalUnread > 0)
                Text(
                  '$_totalUnread unread message${_totalUnread > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const Spacer(),

          // Search toggle
          _TopBarBtn(
            icon: _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            onTap: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchCtrl.clear();
                  _searchFocus.unfocus();
                }
              });
            },
          ),
          const SizedBox(width: 8),

          // Filter
          _TopBarBtn(icon: Icons.tune_rounded, onTap: _showFilterSheet),
        ],
      ),
    );
  }

  // ── Online Row ─────────────────────────────────────────────────
  Widget _buildOnlineRow() {
    final onlineConvs = _dummyConversations.where((c) => c.isOnline).toList();

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

  // ── Search Bar ─────────────────────────────────────────────────
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
                    color: AppColors.primary.withValues(alpha:  0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.04),
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
                    color: AppColors.muted.withValues(alpha:  0.7),
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
                      color: AppColors.muted.withValues(alpha:  0.2),
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

  // ── Empty State ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
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
            'Try searching with a different term',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────
  void _openChat(ConversationModel conv) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)));
  }

  void _deleteConversation(ConversationModel conv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation with ${conv.name} deleted'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {},
        ),
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
        onSelect: (conv) {
          Navigator.pop(context);
          _openChat(conv);
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

// ══════════════════════════════════════════════════════════════════
// Conversation Tile
// ══════════════════════════════════════════════════════════════════
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            const Text(
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
            color: conversation.unreadCount > 0
                ? AppColors.white
                : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: conversation.unreadCount > 0
                  ? AppColors.primary.withValues(alpha:  0.2)
                  : AppColors.line,
              width: conversation.unreadCount > 0 ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  
                  conversation.unreadCount > 0 ? 0.07 : 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Avatar ───────────────────────────
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
                          color: conversation.avatarColor.withValues(alpha:  0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _AvatarContent(conv: conversation),
                  ),
                  // Online dot
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

              // ── Content ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Time
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

                    // Subtitle + Role
                    Text(
                      conversation.role,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Last message + unread badge
                    Row(
                      children: [
                        Expanded(
                          child: conversation.isTyping
                              ? _TypingIndicator()
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
// Typing Indicator
// ══════════════════════════════════════════════════════════════════
class _TypingIndicator extends StatefulWidget {
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
        Text(
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

// ══════════════════════════════════════════════════════════════════
// Top Bar Button
// ══════════════════════════════════════════════════════════════════
class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _TopBarBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.line,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:  0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.ink,
          size: 20,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// New Chat Sheet
// ══════════════════════════════════════════════════════════════════
class _NewChatSheet extends StatelessWidget {
  final ValueChanged<ConversationModel> onSelect;

  const _NewChatSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          Text(
            'Select an expert to start chatting',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ..._dummyConversations.map(
            (conv) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: conv.avatarColor,
                child: _AvatarContent(conv: conv),
              ),
              title: Text(
                conv.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              subtitle: Text(
                conv.role,
                style: TextStyle(fontSize: 11, color: AppColors.primary),
              ),
              trailing: conv.isOnline
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
              onTap: () => onSelect(conv),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Filter Sheet
// ══════════════════════════════════════════════════════════════════
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
