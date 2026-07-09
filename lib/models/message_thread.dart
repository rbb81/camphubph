class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderIsOwner,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final bool senderIsOwner;
  final String text;
  final DateTime sentAt;
}

/// A conversation between one camper (guest) and one campsite. There's no
/// real `camps`-to-owner-account linkage in this app (see
/// docs/ux/wireframes.md "Camp Owner Dashboard"), so a thread is just
/// keyed by [campId] + [guestName] rather than real account ids.
class MessageThread {
  const MessageThread({
    required this.id,
    required this.campId,
    required this.campName,
    required this.guestName,
    required this.messages,
  });

  final String id;
  final String campId;
  final String campName;
  final String guestName;
  final List<ChatMessage> messages;

  MessageThread copyWith({List<ChatMessage>? messages}) => MessageThread(
    id: id,
    campId: campId,
    campName: campName,
    guestName: guestName,
    messages: messages ?? this.messages,
  );
}
