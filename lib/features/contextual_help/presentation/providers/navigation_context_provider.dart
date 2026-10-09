import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/screen_name_map.dart';
import 'package:meta/meta.dart';

/// Current navigation state.
@immutable
class NavigationState {
  /// Creates a navigation state.
  const NavigationState({
    required this.currentRoute,
    required this.screenName,
    this.flowStep,
  });

  /// Route path.
  final String currentRoute;

  /// Human-readable Spanish name.
  final String screenName;

  /// Step within a flow, if applicable.
  final String? flowStep;
}

/// Notifier that tracks the current screen.
class NavigationContextNotifier extends StateNotifier<NavigationState> {
  /// Creates the notifier with the home screen as default.
  NavigationContextNotifier()
    : super(
        const NavigationState(
          currentRoute: '/easy-mode',
          screenName: 'Pantalla principal',
        ),
      );

  /// Updates state from a route name.
  void updateFromRoute(String routeName) {
    final screenName = resolveScreenName(routeName);
    String? flowStep;
    if (routeName.contains('/confirm')) {
      flowStep = 'Paso 2 de 2';
    }
    state = NavigationState(
      currentRoute: routeName,
      screenName: screenName,
      flowStep: flowStep,
    );
  }
}

/// Provides current navigation context.
final navigationContextProvider =
    StateNotifierProvider<NavigationContextNotifier, NavigationState>(
      (ref) => NavigationContextNotifier(),
    );
