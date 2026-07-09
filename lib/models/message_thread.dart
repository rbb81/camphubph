class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderName;
  final String text;
  final DateTime sentAt;
}

/// A conversation between two named parties — either a camper and a
/// campsite (Camp Details' "Message Campsite") or two campers (Other User
/// Profile's "Message" button). There's no real backend/account system, so
/// participants are identified by name rather than an account id.
///
/// [campId] is set (and used for lookup) only for camper<->campsite
/// threads; it's null for camper<->camper threads.
class MessageThread {
  const MessageThread({
    required this.id,
    required this.participantA,
    required this.participantB,
    this.campId,
    required this.messages,
  });

  final String id;
  final String participantA;
  final String participantB;
  final String? campId;
  final List<ChatMessage> messages;

  /// The name of whichever participant isn't [viewerName] — used as the
  /// thread's title from that viewer's perspective.
  String otherParticipant(String viewerName) =>
      viewerName == participantA ? participantB : participantA;

  MessageThread copyWith({List<ChatMessage>? messages}) => MessageThread(
    id: id,
    participantA: participantA,
    participantB: participantB,
    campId: campId,
    messages: messages ?? this.messages,
  );
}
