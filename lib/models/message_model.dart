import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, voice, location }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    this.type = MessageType.text,
    required this.content,
    this.mediaUrl,
    this.latitude,
    this.longitude,
    DateTime? timestamp,
    this.isRead = false,
    this.readAt,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrl': mediaUrl,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      readAt:
          map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? receiverId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
