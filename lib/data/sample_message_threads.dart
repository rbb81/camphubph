import '../models/message_thread.dart';

/// Placeholder message threads between campers and campsites. There's no
/// `messages` schema in Supabase yet.
///
/// Mutated in place (`sampleMessageThreads.add(...)`, entries replaced via
/// `copyWith` when a message is sent), not copied-then-mutated — following
/// the same shared-mutable-list pattern as `sample_trips.dart` and
/// `sample_reservations.dart`, since Camp Details (camper) and the Camp
/// Owner Dashboard (owner) are independently-pushed screens that both need
/// to see every thread and stay in sync within a session.
final List<MessageThread> sampleMessageThreads = [
  MessageThread(
    id: 'thread_seed_1',
    campId: 'daraitan',
    campName: 'Mt. Daraitan campsite',
    guestName: 'Ana Dela Cruz',
    messages: [
      ChatMessage(
        id: 'msg_seed_1',
        senderIsOwner: false,
        text:
            'Hi! Is the river crossing open right now, or is the water too high this week?',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessage(
        id: 'msg_seed_2',
        senderIsOwner: true,
        text:
            'Hi Ana! It\'s open and calm this week. Bring water shoes just in case.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
    ],
  ),
];
