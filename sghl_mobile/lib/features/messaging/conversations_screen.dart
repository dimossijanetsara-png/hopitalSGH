import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/utils/date_formatter.dart';
import 'package:sghl_mobile/core/widgets/empty_state.dart';
import 'package:sghl_mobile/core/widgets/error_card.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/features/messaging/messaging_models.dart';
import 'package:sghl_mobile/features/messaging/messaging_notifier.dart';
import 'package:sghl_mobile/features/messaging/messaging_repository.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConversationDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Nouvelle conversation',
        child: const Icon(Icons.edit_outlined),
      ),
      body: conversationsAsync.when(
        loading: () => const LoadingWidget(message: 'Chargement des messages…'),
        error: (error, _) => ErrorCard(
          message: 'Impossible de charger les conversations.',
          onRetry: () => ref.read(conversationsProvider.notifier).refresh(),
        ),
        data: (conversations) => _ConversationsList(
          conversations: conversations,
          onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Future<void> _showCreateConversationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final subjectController = TextEditingController();
    final participantController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Sujet (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: participantController,
              decoration: const InputDecoration(
                labelText: 'ID du participant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add_outlined),
                hintText: 'UUID du participant',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final participantId = participantController.text.trim();
      if (participantId.isEmpty) return;

      try {
        final repo = ref.read(messagingRepositoryProvider);
        final conv = await repo.createConversation(
          [participantId],
          subject: subjectController.text.trim().isEmpty
              ? null
              : subjectController.text.trim(),
        );
        await ref.read(conversationsProvider.notifier).refresh();
        if (context.mounted) {
          context.go('/messages/${conv.id}');
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de créer la conversation.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _ConversationsList extends StatelessWidget {
  final List<ConversationModel> conversations;
  final Future<void> Function() onRefresh;

  const _ConversationsList({
    required this.conversations,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Aucune conversation',
        subtitle: 'Démarrez une nouvelle conversation en appuyant sur le bouton +',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final conv = conversations[index];
          return _ConversationTile(conversation: conv);
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = conversation.subject.isNotEmpty
        ? conversation.subject
        : 'Conversation sans titre';
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: hasUnread ? AppColors.primary : AppColors.border,
        child: Icon(
          Icons.chat_bubble_outline,
          color: hasUnread ? Colors.white : AppColors.textSecondary,
          size: 22,
        ),
      ),
      title: Text(
        subject,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              conversation.lastMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasUnread
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight:
                    hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormatter.timeAgo(conversation.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: hasUnread ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.go('/messages/${conversation.id}'),
    );
  }
}
