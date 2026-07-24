import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Full-screen swipeable photo viewer, shared across Camp Details' and
/// Other User Profile's Photos tabs — a generic reusable screen rather than
/// a per-screen widget, since duplicating it would duplicate real logic
/// (page/index tracking, swipe transitions, pinch-to-zoom), not just a
/// similar-looking layout. See CLAUDE.md's `lib/widgets/` guidance for the
/// same reasoning applied to a pushed screen instead of an embedded widget.
class PhotoLightboxScreen extends StatefulWidget {
  const PhotoLightboxScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  final List<Uint8List> photos;
  final int initialIndex;

  @override
  State<PhotoLightboxScreen> createState() => _PhotoLightboxScreenState();
}

class _PhotoLightboxScreenState extends State<PhotoLightboxScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} of ${widget.photos.length}'),
      ),
      body: PageView.builder(
        key: const Key('photoLightboxPageView'),
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(
            child: Image.memory(widget.photos[index], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
