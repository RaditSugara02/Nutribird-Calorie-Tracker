import 'package:flutter/material.dart';

/// Custom page route dengan transisi fade yang smooth tanpa flash putih
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Color? backgroundColor;

  CustomPageRoute({
    required this.child,
    this.backgroundColor,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition yang smooth
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );

  @override
  Color? get barrierColor => backgroundColor ?? Colors.transparent;
}

