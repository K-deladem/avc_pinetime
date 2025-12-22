// ui/home/widget/animated_chart_wrapper.dart

import 'package:flutter/material.dart';

/// Wrapper pour animer les transitions des graphiques de manière douce
///
/// Ce widget ajoute une animation de fondu (fade) lorsque les données
/// des graphiques changent, évitant ainsi les mises à jour brusques
class AnimatedChartWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedChartWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedChartWrapper> createState() => _AnimatedChartWrapperState();
}

class _AnimatedChartWrapperState extends State<AnimatedChartWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Démarrer l'animation au montage
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChartWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le child change, refaire l'animation de fondu
    if (oldWidget.child != widget.child) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}

/// Wrapper pour animer les transitions avec un effet de glissement
///
/// Ce widget combine un fondu et un glissement vertical pour
/// des transitions encore plus douces
class AnimatedChartSlideWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedChartSlideWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedChartSlideWrapper> createState() =>
      _AnimatedChartSlideWrapperState();
}

class _AnimatedChartSlideWrapperState extends State<AnimatedChartSlideWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // Petit glissement de 5%
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Démarrer l'animation au montage
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChartSlideWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le child change, refaire l'animation
    if (oldWidget.child != widget.child) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Extension pour faciliter l'utilisation des wrappers
extension AnimatedChartExtension on Widget {
  /// Ajoute une animation de fondu au widget
  Widget withFadeAnimation({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedChartWrapper(
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Ajoute une animation de fondu + glissement au widget
  Widget withSlideAnimation({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return AnimatedChartSlideWrapper(
      duration: duration,
      curve: curve,
      child: this,
    );
  }
}
