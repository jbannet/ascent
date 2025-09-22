import 'package:go_router/go_router.dart';
import '../../temporary_navigator_view.dart';

/// Home routes for the application
///
/// Currently serves as the development entry point, providing access to all
/// views and functionality for testing purposes. In production, users would
/// typically access the app through the '/real' route which provides
/// intelligent navigation based on their saved state.
class HomeRoutes {
  static List<RouteBase> routes = [
    // Root route (/) - Development navigation hub
    // This is the app's initial location and serves as a development tool
    GoRoute(
      path: '/',
      name: 'home',

      // Shows the TemporaryNavigatorView which provides:
      // - Quick access to all app views for testing
      // - Mock data scenarios for different user states
      // - Direct navigation to specific workflows
      // - Development tools and utilities
      builder: (context, state) => const TemporaryNavigatorView(),
    ),
  ];
}