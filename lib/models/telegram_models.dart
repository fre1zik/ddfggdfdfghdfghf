// Telegram Models
class TelegramUser {
  final int id;
  final String firstName;
  final String? lastName;
  final String? username;
  final String? photoUrl;
  final bool isBot;

  TelegramUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.username,
    this.photoUrl,
    this.isBot = false,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      photoUrl: json['photo']?['small_file_id'],
      isBot: json['is_bot'] ?? false,
    );
  }

  String get displayName {
    if (lastName != null) {
      return '$firstName $lastName';
    }
    return firstName;
  }
}

class TelegramChat {
  final int id;
  final String type; // 'private', 'group', 'supergroup', 'channel'
  final String? title;
  final String? username;
  final TelegramUser? user;
  final String? photoUrl;
  final String? description;
  final int? memberCount;

  TelegramChat({
    required this.id,
    required this.type,
    this.title,
    this.username,
    this.user,
    this.photoUrl,
    this.description,
    this.memberCount,
  });

  factory TelegramChat.fromJson(Map<String, dynamic> json) {
    return TelegramChat(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      username: json['username'],
      user: json['user'] != null ? TelegramUser.fromJson(json['user']) : null,
      photoUrl: json['photo']?['small_file_id'],
      description: json['description'],
      memberCount: json['member_count'],
    );
  }

  String get displayName {
    if (type == 'private' && user != null) {
      return user!.displayName;
    }
    return title ?? 'Unknown Chat';
  }
}

class TelegramMessage {
  final int messageId;
  final TelegramUser from;
  final TelegramChat chat;
  final int date;
  final String? text;
  final List<TelegramMessageEntity>? entities;
  final TelegramMessage? replyToMessage;
  final List<TelegramPhoto>? photo;
  final TelegramDocument? document;
  final TelegramSticker? sticker;

  TelegramMessage({
    required this.messageId,
    required this.from,
    required this.chat,
    required this.date,
    this.text,
    this.entities,
    this.replyToMessage,
    this.photo,
    this.document,
    this.sticker,
  });

  factory TelegramMessage.fromJson(Map<String, dynamic> json) {
    return TelegramMessage(
      messageId: json['message_id'],
      from: TelegramUser.fromJson(json['from']),
      chat: TelegramChat.fromJson(json['chat']),
      date: json['date'],
      text: json['text'],
      entities: json['entities'] != null
          ? (json['entities'] as List)
              .map((e) => TelegramMessageEntity.fromJson(e))
              .toList()
          : null,
      replyToMessage: json['reply_to_message'] != null
          ? TelegramMessage.fromJson(json['reply_to_message'])
          : null,
      photo: json['photo'] != null
          ? (json['photo'] as List)
              .map((p) => TelegramPhoto.fromJson(p))
              .toList()
          : null,
      document: json['document'] != null
          ? TelegramDocument.fromJson(json['document'])
          : null,
      sticker: json['sticker'] != null
          ? TelegramSticker.fromJson(json['sticker'])
          : null,
    );
  }

  bool get hasMedia => photo != null || document != null || sticker != null;
}

class TelegramMessageEntity {
  final String type;
  final int offset;
  final int length;
  final String? url;
  final TelegramUser? user;

  TelegramMessageEntity({
    required this.type,
    required this.offset,
    required this.length,
    this.url,
    this.user,
  });

  factory TelegramMessageEntity.fromJson(Map<String, dynamic> json) {
    return TelegramMessageEntity(
      type: json['type'],
      offset: json['offset'],
      length: json['length'],
      url: json['url'],
      user: json['user'] != null ? TelegramUser.fromJson(json['user']) : null,
    );
  }
}

class TelegramPhoto {
  final String fileId;
  final String fileUniqueId;
  final int width;
  final int height;
  final int? fileSize;

  TelegramPhoto({
    required this.fileId,
    required this.fileUniqueId,
    required this.width,
    required this.height,
    this.fileSize,
  });

  factory TelegramPhoto.fromJson(Map<String, dynamic> json) {
    return TelegramPhoto(
      fileId: json['file_id'],
      fileUniqueId: json['file_unique_id'],
      width: json['width'],
      height: json['height'],
      fileSize: json['file_size'],
    );
  }
}

class TelegramDocument {
  final String fileId;
  final String fileUniqueId;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;

  TelegramDocument({
    required this.fileId,
    required this.fileUniqueId,
    this.fileName,
    this.mimeType,
    this.fileSize,
  });

  factory TelegramDocument.fromJson(Map<String, dynamic> json) {
    return TelegramDocument(
      fileId: json['file_id'],
      fileUniqueId: json['file_unique_id'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
    );
  }
}

class TelegramSticker {
  final String fileId;
  final String fileUniqueId;
  final int width;
  final int height;
  final bool isAnimated;
  final String? emoji;
  final String? setName;

  TelegramSticker({
    required this.fileId,
    required this.fileUniqueId,
    required this.width,
    required this.height,
    required this.isAnimated,
    this.emoji,
    this.setName,
  });

  factory TelegramSticker.fromJson(Map<String, dynamic> json) {
    return TelegramSticker(
      fileId: json['file_id'],
      fileUniqueId: json['file_unique_id'],
      width: json['width'],
      height: json['height'],
      isAnimated: json['is_animated'] ?? false,
      emoji: json['emoji'],
      setName: json['set_name'],
    );
  }
} 