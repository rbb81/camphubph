import 'package:flutter/material.dart';

import '../data/sample_community_join_requests.dart';
import '../data/sample_community_members.dart';
import '../models/community.dart';
import '../models/community_join_request.dart';
import '../models/community_member.dart';
import '../theme/app_theme.dart';

/// Moderator-only review queue for a private community's pending join
/// requests. Reached from `CommunityFeedScreen`'s Members tab.
class PendingJoinRequestsScreen extends StatefulWidget {
  const PendingJoinRequestsScreen({super.key, required this.community});

  final Community community;

  @override
  State<PendingJoinRequestsScreen> createState() =>
      _PendingJoinRequestsScreenState();
}

class _PendingJoinRequestsScreenState
    extends State<PendingJoinRequestsScreen> {
  late Community _community;
  late List<CommunityJoinRequest> _requests;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _syncRequests();
  }

  void _syncRequests() {
    _requests = sampleCommunityJoinRequests
        .where((r) => r.communityId == _community.id)
        .toList();
  }

  void _approve(CommunityJoinRequest request) {
    sampleCommunityJoinRequests.removeWhere((r) => r.id == request.id);
    sampleCommunityMembers.add(
      CommunityMember(
        communityId: _community.id,
        name: request.requesterName,
        initials: request.requesterInitials,
        role: CommunityRole.member,
      ),
    );
    setState(() {
      _community = _community.copyWith(memberCount: _community.memberCount + 1);
      _changed = true;
      _syncRequests();
    });
  }

  void _decline(CommunityJoinRequest request) {
    sampleCommunityJoinRequests.removeWhere((r) => r.id == request.id);
    setState(_syncRequests);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed ? _community : null);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Pending join requests')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _requests.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return _JoinRequestCard(
                          request: request,
                          onApprove: () => _approve(request),
                          onDecline: () => _decline(request),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  final CommunityJoinRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Text(
                  request.requesterInitials,
                  style: TextStyle(fontWeight: FontWeight.w500, color: accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Requested ${request.timeAgo}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: Key('approveJoinRequestButton_${request.id}'),
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: Key('declineJoinRequestButton_${request.id}'),
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No pending requests.', style: TextStyle(color: Colors.grey)),
    );
  }
}
