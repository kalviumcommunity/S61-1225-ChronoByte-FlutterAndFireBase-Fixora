import 'package:flutter/material.dart';

class AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AnimatedSection({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection> {
  bool _visible = false;
  ScrollPosition? _scrollPosition;

  @override
  void dispose() {
    _removeScrollListener();
    super.dispose();
  }

  void _addScrollListenerIfNeeded() {
    final pos = Scrollable.of(context)?.position;
    if (pos != null && pos != _scrollPosition) {
      _removeScrollListener();
      _scrollPosition = pos;
      _scrollPosition!.addListener(_checkVisibility);
    }
  }

  void _removeScrollListener() {
    try {
      _scrollPosition?.removeListener(_checkVisibility);
    } catch (_) {}
    _scrollPosition = null;
  }

  bool _scheduled = false;

  void _checkVisibility() {
    if (!mounted || _visible || _scheduled) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final top = renderBox.localToGlobal(Offset.zero).dy;
    final bottom = top + renderBox.size.height;
    final screenHeight = MediaQuery.of(context).size.height;

    // Trigger when any part of the widget is within the first 85% of the screen
    if ((top < screenHeight * 0.85) && (bottom > 0)) {
      _scheduled = true;
      Future.delayed(widget.delay, () {
        if (!mounted) return;
        setState(() {
          _visible = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we attach to scroll controller if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addScrollListenerIfNeeded();
      // Do an initial check in case the widget is already on-screen
      _checkVisibility();
    });

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _visible ? 1 : 0,
      curve: Curves.easeInOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 500),
          scale: _visible ? 1.0 : 0.98,
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}
