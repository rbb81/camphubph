import '../models/message_thread.dart';

/// Placeholder message threads — both camper<->campsite (Camp Details'
/// "Message Campsite") and camper<->camper (Other User Profile's
/// "Message") conversations live in this same list, distinguished by
/// whether [MessageThread.campId] is set. There's no `messages` schema in
/// Supabase yet.
///
/// Mutated in place (`sampleMessageThreads.add(...)`, entries replaced via
/// `copyWith` when a message is sent), not copied-then-mutated — following
/// the same shared-mutable-list pattern as `sample_trips.dart` and
/// `sample_reservations.dart`, since Camp Details/Other User Profile
/// (camper side) and the Camp Owner Dashboard (owner side) are
/// independently-pushed screens that both need to see every thread and
/// stay in sync within a session.
final List<MessageThread> sampleMessageThreads = [
  MessageThread(
    id: 'thread_seed_1',
    participantA: 'Ana Dela Cruz',
    participantB: 'Mt. Daraitan campsite',
    campId: 'daraitan',
    messages: [
      ChatMessage(
        id: 'msg_seed_1',
        senderName: 'Ana Dela Cruz',
        text:
            'Hi! Is the river crossing open right now, or is the water too high this week?',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: 'msg_seed_2',
        senderName: 'Mang Rodel',
        text:
            'Hi Ana! It\'s open and calm this week. Bring water shoes just in case.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
    ],
  ),
  MessageThread(
    id: 'thread_seed_2',
    participantA: 'Ana Dela Cruz',
    participantB: 'Jasmine Reyes',
    messages: [
      ChatMessage(
        id: 'msg_seed_3',
        senderName: 'Jasmine Reyes',
        text: 'That sunrise shot you saved from my post — was it Batangas Ridge?',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
  ),
];
