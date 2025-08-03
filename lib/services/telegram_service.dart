import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/telegram_models.dart';

class TelegramService {
  static const String _baseUrl = 'https://api.telegram.org/bot';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  bool get isAuthenticated => _token != null;

  Future<Map<String, dynamic>> _makeRequest(String method, {Map<String, dynamic>? body}) async {
    if (_token == null) {
      throw Exception('Token not set');
    }

    final url = Uri.parse('$_baseUrl$_token/$method');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return data['result'];
        } else {
          throw Exception('Telegram API error: ${data['description']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get bot information
  Future<TelegramUser> getMe() async {
    final data = await _makeRequest('getMe');
    return TelegramUser.fromJson(data);
  }

  // Get updates (messages)
  Future<List<TelegramMessage>> getUpdates({int? offset, int limit = 100}) async {
    final params = <String, dynamic>{'limit': limit};
    if (offset != null) params['offset'] = offset;

    final data = await _makeRequest('getUpdates', body: params);
    
    if (data is List) {
      return data.map((update) {
        if (update['message'] != null) {
          return TelegramMessage.fromJson(update['message']);
        }
        throw Exception('Update does not contain message');
      }).toList();
    }
    
    return [];
  }

  // Send message
  Future<TelegramMessage> sendMessage(int chatId, String text, {int? replyToMessageId}) async {
    final params = <String, dynamic>{
      'chat_id': chatId,
      'text': text,
    };
    
    if (replyToMessageId != null) {
      params['reply_to_message_id'] = replyToMessageId;
    }

    final data = await _makeRequest('sendMessage', body: params);
    return TelegramMessage.fromJson(data);
  }

  // Get chat information
  Future<TelegramChat> getChat(int chatId) async {
    final data = await _makeRequest('getChat', body: {'chat_id': chatId});
    return TelegramChat.fromJson(data);
  }

  // Get chat history
  Future<List<TelegramMessage>> getChatHistory(int chatId, {int? limit}) async {
    final params = <String, dynamic>{
      'chat_id': chatId,
    };
    
    if (limit != null) params['limit'] = limit;

    final data = await _makeRequest('getChatHistory', body: params);
    
    if (data is List) {
      return data.map((message) => TelegramMessage.fromJson(message)).toList();
    }
    
    return [];
  }

  // Send photo
  Future<TelegramMessage> sendPhoto(int chatId, String photo, {String? caption}) async {
    final params = <String, dynamic>{
      'chat_id': chatId,
      'photo': photo,
    };
    
    if (caption != null) params['caption'] = caption;

    final data = await _makeRequest('sendPhoto', body: params);
    return TelegramMessage.fromJson(data);
  }

  // Send document
  Future<TelegramMessage> sendDocument(int chatId, String document, {String? caption}) async {
    final params = <String, dynamic>{
      'chat_id': chatId,
      'document': document,
    };
    
    if (caption != null) params['caption'] = caption;

    final data = await _makeRequest('sendDocument', body: params);
    return TelegramMessage.fromJson(data);
  }

  // Delete message
  Future<bool> deleteMessage(int chatId, int messageId) async {
    try {
      await _makeRequest('deleteMessage', body: {
        'chat_id': chatId,
        'message_id': messageId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get file
  Future<String> getFileUrl(String fileId) async {
    final data = await _makeRequest('getFile', body: {'file_id': fileId});
    final filePath = data['file_path'];
    return 'https://api.telegram.org/file/bot$_token/$filePath';
  }
}

// Singleton instance
final telegramService = TelegramService(); 