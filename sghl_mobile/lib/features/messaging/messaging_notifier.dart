import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/features/messaging/messaging_models.dart';
import 'package:sghl_mobile/features/messaging/messaging_repository.dart';

// ---------------------------------------------------------------------------
// Conversations
// ---------------------------------------------------------------------------

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<ConversationModel>>> {
  final MessagingRepository _repo;

  ConversationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repo.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();
}

final conversationsProvider = StateNotifierProvider<ConversationsNotifier,
    AsyncValue<List<ConversationModel>>>((ref) {
  return ConversationsNotifier(ref.watch(messagingRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Chat (messages for a specific conversation)
// ---------------------------------------------------------------------------

class ChatNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final MessagingRepository _repo;
  final String conversationId;

  ChatNotifier(this._repo, this.conversationId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final messages = await _repo.getMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final messages = await _repo.getMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      // Keep existing data on poll error — only update if we had data
      if (state is! AsyncData) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      await _repo.sendMessage(conversationId, content);
      await refresh();
    } catch (e, st) {
      // Re-throw so the UI can show a snackbar
      throw AsyncValue.error(e, st);
    }
  }
}

final chatProviderFamily = StateNotifierProvider.family<ChatNotifier,
    AsyncValue<List<MessageModel>>, String>((ref, conversationId) {
  return ChatNotifier(ref.watch(messagingRepositoryProvider), conversationId);
});
