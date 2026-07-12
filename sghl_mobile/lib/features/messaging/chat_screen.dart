import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/empty_state.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';
import 'package:sghl_mobile/features/messaging/messaging_models.dart';
import 'package:sghl_mobile/features/messaging/messaging_notifier.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isSending = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        ref.read(chatProviderFamily(widget.conversationId).notifier).refresh();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await ref
          .read(chatProviderFamily(widget.conversationId).notifier)
          .sendMessage(text);
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de l'envoi du message."),
            backgroundColor: AppColors.error,
          ),
        );
        _messageController.text = text;
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatProviderFamily(widget.conversationId));
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id ?? '';

    // Auto-scroll when new messages arrive
    messagesAsync.whenData((messages) {
      if (messages.length != _previousMessageCount) {
        _previousMessageCount = messages.length;
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const LoadingWidget(message: 'Chargement des messages…'),
              error: (error, _) => ErrorCard(
                message: 'Impossible de charger les messages.',
                onRetry: () => ref
                    .read(chatProviderFamily(widget.conversationId).notifier)
                    .refresh(),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Aucun message',
                    subtitle: 'Envoyez le premier message !',
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = message.isMine(currentUserId);
                    final showDate = index == 0 ||
                        !_isSameDay(
                          messages[index - 1].createdAt,
                          message.createdAt,
                        );
                    return Column(
                      children: [
                        if (showDate)
                          _DateDivider(date: message.createdAt),
                        _MessageBubble(
                          message: message,
                          isMine: mine,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------------
// Date divider
// ---------------------------------------------------------------------------

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              DateFormatter.formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = Radius.circular(16);
    const sharpRadius = Radius.circular(4);

    final borderRadius = isMine
        ? const BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: sharpRadius,
          )
        : const BorderRadius.only(
            topLeft: sharpRadius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMine ? 60 : 0,
          right: isMine ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : Colors.grey[200],
                borderRadius: borderRadius,
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                DateFormatter.formatTime(message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message input bar
// ---------------------------------------------------------------------------

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Écrivez un message…',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: onSend,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
