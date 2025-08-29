import 'package:go_router/go_router.dart';
import '../../temporary_navigator_view.dart';

/// Home routes for the application
class HomeRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const TemporaryNavigatorView(),
    ),
  ];
}