import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/telegram_models.dart';
import '../services/telegram_service.dart';

class TelegramProvider extends ChangeNotifier {
  final TelegramService _service = telegramService;
  
  TelegramUser? _currentUser;
  List<TelegramChat> _chats = [];
  Map<int, List<TelegramMessage>> _messages = {};
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;
  int _lastUpdateId = 0;

  // Getters
  TelegramUser? get currentUser => _currentUser;
  List<TelegramChat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TelegramMessage> getMessages(int chatId) {
    return _messages[chatId] ?? [];
  }

  // Initialize with token
  Future<bool> initialize(String token) async {
    try {
      _setLoading(true);
      _clearError();
      
      _service.setToken(token);
      _currentUser = await _service.getMe();
      
      // Start polling for updates
      _startPolling();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Start polling for updates
  void _startPolling() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _pollUpdates();
    });
  }

  // Poll for updates
  Future<void> _pollUpdates() async {
    try {
      final updates = await _service.getUpdates(offset: _lastUpdateId + 1);
      
      for (final message in updates) {
        _lastUpdateId = message.messageId;
        
        // Add chat if not exists
        if (!_chats.any((chat) => chat.id == message.chat.id)) {
          _chats.add(message.chat);
        }
        
        // Add message to chat
        if (!_messages.containsKey(message.chat.id)) {
          _messages[message.chat.id] = [];
        }
        _messages[message.chat.id]!.insert(0, message);
        
        // Keep only last 100 messages per chat
        if (_messages[message.chat.id]!.length > 100) {
          _messages[message.chat.id] = _messages[message.chat.id]!.take(100).toList();
        }
      }
      
      if (updates.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error polling updates: $e');
    }
  }

  // Send message
  Future<bool> sendMessage(int chatId, String text, {int? replyToMessageId}) async {
    try {
      final message = await _service.sendMessage(chatId, text, replyToMessageId: replyToMessageId);
      
      // Add message to local storage
      if (!_messages.containsKey(chatId)) {
        _messages[chatId] = [];
      }
      _messages[chatId]!.insert(0, message);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Load chat history
  Future<void> loadChatHistory(int chatId) async {
    try {
      _setLoading(true);
      
      final messages = await _service.getChatHistory(chatId, limit: 50);
      _messages[chatId] = messages;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Delete message
  Future<bool> deleteMessage(int chatId, int messageId) async {
    try {
      final success = await _service.deleteMessage(chatId, messageId);
      
      if (success) {
        _messages[chatId]?.removeWhere((msg) => msg.messageId == messageId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get chat info
  Future<TelegramChat?> getChatInfo(int chatId) async {
    try {
      return await _service.getChat(chatId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
} 