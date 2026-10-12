import 'package:flutter/widgets.dart';

/// Tracks route changes and notifies via callback.
///
/// Defers notifications to avoid modifying providers during build.
class NavigationObserver extends NavigatorObserver {
  /// Creates the observer with a route change callback.
  NavigationObserver(this._onRouteChanged);

  final void Function(String routeName) _onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _notify(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _notify(newRoute);
  }

  void _notify(Route<dynamic> route) {
    final name = route.settings.name ?? '/easy-mode';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRouteChanged(name);
    });
  }
}
