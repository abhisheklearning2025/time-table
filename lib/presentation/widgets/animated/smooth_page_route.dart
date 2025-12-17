import 'package:flutter/material.dart';

/// Smooth page transition with slide and fade
class SmoothPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final Duration duration;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide from right with fade
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    final offsetAnimation = animation.drive(tween);
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Smooth navigation helper
class SmoothNavigator {
  /// Navigate with smooth transition
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      SmoothPageRoute(page: page),
    );
  }

  /// Replace with smooth transition
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, TO>(
      SmoothPageRoute(page: page),
    );
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      SmoothPageRoute(page: page),
      predicate,
    );
  }
}
