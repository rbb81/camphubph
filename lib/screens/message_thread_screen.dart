import 'package:flutter/material.dart';

import '../data/sample_message_threads.dart';
import '../models/message_thread.dart';
import '../theme/app_theme.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({
    super.key,
    required this.thread,
    required this.viewerName,
  });

  final MessageThread thread;

  /// The name of whoever is viewing this thread — determines which
  /// messages align as "mine", the app bar title (the other participant's
  /// name), and which name new messages are attributed to.
  final String viewerName;

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final _controller = TextEditingController();
  late MessageThread _thread;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      senderName: widget.viewerName,
      text: text,
      sentAt: DateTime.now(),
    );
    final updated = _thread.copyWith(messages: [..._thread.messages, message]);
    final index = sampleMessageThreads.indexWhere((t) => t.id == _thread.id);
    if (index != -1) {
      sampleMessageThreads[index] = updated;
    }
    setState(() => _thread = updated);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final title = _thread.otherParticipant(widget.viewerName);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: _thread.messages.isEmpty
                      ? const _EmptyThread()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final message in _thread.messages)
                              _MessageBubble(
                                message: message,
                                isMine: message.senderName == widget.viewerName,
                              ),
                          ],
                        ),
                ),
                _Composer(controller: _controller, onSend: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No messages yet. Say hello!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    final bubbleColor = isMine
        ? accent
        : (isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight);
    final textColor = isMine
        ? Colors.white
        : (isDark ? AppColors.foregroundDark : AppColors.foregroundLight);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  key: Key('messageBubble_${message.id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.sentAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('messageComposerField'),
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Type a message'),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('sendMessageButton'),
            tooltip: 'Send message',
            onPressed: onSend,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
