import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/sample_other_users.dart';
import '../data/sample_profile.dart';
import '../models/followable_user.dart';
import '../models/profile.dart';
import '../screens/other_user_profile_screen.dart';
import '../screens/search_screen.dart';
import '../theme/app_theme.dart';

final _tokenPattern = RegExp(r'[#@][A-Za-z0-9_]+');

/// Renders [text] with `#hashtag`/`@mention` tokens as tappable, accent-
/// colored spans — the first inline-tappable-text primitive in this
/// codebase, so it's a `StatefulWidget` rather than stateless: each tagged
/// span owns a [TapGestureRecognizer], which must be disposed, not
/// recreated silently on every rebuild.
class HashtagMentionText extends StatefulWidget {
  const HashtagMentionText(
    this.text, {
    super.key,
    this.style,
    this.onHashtagTap,
    this.onMentionTap,
  });

  final String text;
  final TextStyle? style;

  /// Called with the tag text, without its leading `#`.
  final ValueChanged<String>? onHashtagTap;

  /// Called with the handle text, without its leading `@`.
  final ValueChanged<String>? onMentionTap;

  @override
  State<HashtagMentionText> createState() => _HashtagMentionTextState();
}

class _HashtagMentionTextState extends State<HashtagMentionText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _rebuildRecognizers();
  }

  @override
  void didUpdateWidget(HashtagMentionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _rebuildRecognizers();
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  void _rebuildRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    for (final match in _tokenPattern.allMatches(widget.text)) {
      final token = match.group(0)!;
      final body = token.substring(1);
      final recognizer = TapGestureRecognizer();
      if (token.startsWith('#')) {
        recognizer.onTap = widget.onHashtagTap == null
            ? null
            : () => widget.onHashtagTap!(body);
      } else {
        recognizer.onTap = widget.onMentionTap == null
            ? null
            : () => widget.onMentionTap!(body);
      }
      _recognizers.add(recognizer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    final tagStyle = TextStyle(color: accent, fontWeight: FontWeight.w500);

    final spans = <InlineSpan>[];
    var cursor = 0;
    var recognizerIndex = 0;
    for (final match in _tokenPattern.allMatches(widget.text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: tagStyle,
          recognizer: _recognizers[recognizerIndex],
        ),
      );
      recognizerIndex++;
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Text.rich(TextSpan(children: spans), style: widget.style);
  }
}

/// Opens Search pre-filled with [tag] and already showing matching results.
void openHashtagSearch(BuildContext context, String tag) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: tag)));
}

/// Resolves [handle] (a display name with spaces stripped, e.g.
/// "MiguelIbarra" for "Miguel Ibarra") and opens that person's profile.
/// Self-mentions route to the current user's own Profile tab instead of
/// resolving through `sampleOtherUsers`. An unrecognized handle still opens
/// a profile, backed by a synthesized placeholder — same fallback
/// convention as `home_screen.dart`'s `_openUserProfile`, since this app has
/// no "not found" error state.
void openMentionedProfile(BuildContext context, String handle) {
  final normalized = handle.toLowerCase();
  if (normalized == sampleProfile.name.replaceAll(' ', '').toLowerCase()) {
    Navigator.of(context).pushNamed('/profile');
    return;
  }

  final user = sampleOtherUsers.firstWhere(
    (u) => u.profile.name.replaceAll(' ', '').toLowerCase() == normalized,
    orElse: () => FollowableUser(
      profile: UserProfile(
        name: handle,
        initials: handle.substring(0, handle.length < 2 ? handle.length : 2).toUpperCase(),
        bio: '',
        experienceLevel: ExperienceLevel.beginner,
        favoriteStyles: const [],
        followerCount: 0,
        followingCount: 0,
      ),
    ),
  );
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user)));
}
