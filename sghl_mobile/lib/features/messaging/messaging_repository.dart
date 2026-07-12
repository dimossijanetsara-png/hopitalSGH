import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/features/messaging/messaging_models.dart';

class MessagingRepository {
  final ApiClient _client;

  MessagingRepository(this._client);

  Future<List<ConversationModel>> getConversations() async {
    final response = await _client.get(ApiConstants.conversations);
    final raw = response.data;
    final List list = raw is List ? raw : (raw['items'] ?? []);
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _client.get(
      '${ApiConstants.conversations}/$conversationId/messages',
      queryParams: {
        'page': page,
        'per_page': perPage,
      },
    );
    final raw = response.data;
    final List list = raw is List ? raw : (raw['items'] ?? []);
    return list
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage(
    String conversationId,
    String content,
  ) async {
    final response = await _client.post(
      ApiConstants.messages,
      data: {
        'conversation_id': conversationId,
        'content': content,
      },
    );
    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ConversationModel> createConversation(
    List<String> participantIds, {
    String? subject,
  }) async {
    final body = <String, dynamic>{
      'participant_ids': participantIds,
    };
    if (subject != null && subject.isNotEmpty) {
      body['subject'] = subject;
    }
    final response = await _client.post(ApiConstants.conversations, data: body);
    return ConversationModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(ref.watch(apiClientProvider));
});
