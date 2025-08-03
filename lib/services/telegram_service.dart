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

  // Get updates (messages) - SAFE VERSION
  Future<List<TelegramMessage>> getUpdates({int? offset, int limit = 100}) async {
    final params = <String, dynamic>{'limit': limit};
    if (offset != null) params['offset'] = offset;

    final data = await _makeRequest('getUpdates', body: params);
    
    if (data is List) {
      final messages = <TelegramMessage>[];
      
      for (int i = 0; i < data.length; i++) {
        try {
          final update = data[i];
          if (update is Map<String, dynamic> && 
              update['message'] != null && 
              update['message'] is Map<String, dynamic>) {
            messages.add(TelegramMessage.fromJson(update['message']));
          }
        } catch (e) {
          print('Error parsing update: $e');
          continue;
        }
      }
      
      return messages;
    }
    
    return [];
  }

  // Send message
  Future<TelegramMessage> sendMessage(int chatId, String text, {int? replyToMessageId}) async {
    final params = <String, dynamic>{
      'chat_id': chatId.toString(),
      'text': text,
    };
    
    if (replyToMessageId != null) {
      params['reply_to_message_id'] = replyToMessageId;
    }

    final data = await _makeRequest('sendMessage', body: params);
    if (data is Map<String, dynamic>) {
      return TelegramMessage.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  // Get chat information
  Future<TelegramChat> getChat(int chatId) async {
    final data = await _makeRequest('getChat', body: {'chat_id': chatId.toString()});
    if (data is Map<String, dynamic>) {
      return TelegramChat.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  // Get chat history
  Future<List<TelegramMessage>> getChatHistory(int chatId, {int? limit}) async {
    final params = <String, dynamic>{
      'chat_id': chatId.toString(),
    };
    
    if (limit != null) params['limit'] = limit;

    final data = await _makeRequest('getChatHistory', body: params);
    
    if (data is List) {
      final messages = <TelegramMessage>[];
      
      for (int i = 0; i < data.length; i++) {
        try {
          final message = data[i];
          if (message is Map<String, dynamic>) {
            messages.add(TelegramMessage.fromJson(message));
          }
        } catch (e) {
          print('Error parsing message: $e');
          continue;
        }
      }
      
      return messages;
    }
    
    return [];
  }

  // Send photo
  Future<TelegramMessage> sendPhoto(int chatId, String photo, {String? caption}) async {
    final params = <String, dynamic>{
      'chat_id': chatId.toString(),
      'photo': photo,
    };
    
    if (caption != null) params['caption'] = caption;

    final data = await _makeRequest('sendPhoto', body: params);
    if (data is Map<String, dynamic>) {
      return TelegramMessage.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  // Send document
  Future<TelegramMessage> sendDocument(int chatId, String document, {String? caption}) async {
    final params = <String, dynamic>{
      'chat_id': chatId.toString(),
      'document': document,
    };
    
    if (caption != null) params['caption'] = caption;

    final data = await _makeRequest('sendDocument', body: params);
    if (data is Map<String, dynamic>) {
      return TelegramMessage.fromJson(data);
    }
    throw Exception('Invalid response format');
  }

  // Delete message
  Future<bool> deleteMessage(int chatId, int messageId) async {
    try {
      await _makeRequest('deleteMessage', body: {
        'chat_id': chatId.toString(),
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