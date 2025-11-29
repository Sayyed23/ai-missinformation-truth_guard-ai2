import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truth_guard_ai/core/navigation/scaffold_with_navbar.dart';
import 'package:truth_guard_ai/features/home/presentation/home_screen.dart';
import 'package:truth_guard_ai/features/home/presentation/claim_detail_screen.dart';
import 'package:truth_guard_ai/features/home/presentation/saved_claims_screen.dart';
import 'package:truth_guard_ai/features/fact_check_feed/presentation/feed_screen.dart';
import 'package:truth_guard_ai/features/fact_check_feed/presentation/fact_check_detail_screen.dart';
import 'package:truth_guard_ai/features/fact_check_feed/presentation/submit_content_screen.dart';
import 'package:truth_guard_ai/features/fact_check_feed/presentation/submission_status_screen.dart';
import 'package:truth_guard_ai/features/trends_analytics/presentation/trends_screen.dart';
import 'package:truth_guard_ai/features/trends_analytics/presentation/trend_detail_screen.dart';
import 'package:truth_guard_ai/features/trends_analytics/presentation/b2b_dashboard_screen.dart';
import 'package:truth_guard_ai/features/alerts/presentation/alerts_screen.dart';
import 'package:truth_guard_ai/features/alerts/presentation/alert_detail_screen.dart';
import 'package:truth_guard_ai/features/alerts/presentation/notification_preferences_screen.dart';
import 'package:truth_guard_ai/features/profile_settings/presentation/profile_screen.dart';
import 'package:truth_guard_ai/features/profile_settings/presentation/settings_screen.dart';
import 'package:truth_guard_ai/features/profile_settings/presentation/support_screen.dart';
import 'package:truth_guard_ai/features/profile_settings/presentation/about_screen.dart';
import 'package:truth_guard_ai/features/verification/presentation/pages/verification_screen.dart';
import 'package:truth_guard_ai/features/chat/presentation/pages/chat_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return ScaffoldWithNavbar(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'claim/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    return ClaimDetailScreen(claimId: id);
                  },
                ),
                GoRoute(
                  path: 'saved',
                  builder: (BuildContext context, GoRouterState state) =>
                      const SavedClaimsScreen(),
                ),
                GoRoute(
                  path: 'verify',
                  builder: (BuildContext context, GoRouterState state) =>
                      const VerificationScreen(),
                ),
                GoRoute(
                  path: 'chat',
                  builder: (BuildContext context, GoRouterState state) =>
                      const ChatScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/feed',
              builder: (BuildContext context, GoRouterState state) =>
                  const FeedScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    return FactCheckDetailScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'submit',
                  builder: (BuildContext context, GoRouterState state) =>
                      const SubmitContentScreen(),
                ),
                GoRoute(
                  path: 'status',
                  builder: (BuildContext context, GoRouterState state) =>
                      const SubmissionStatusScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/trends',
              builder: (BuildContext context, GoRouterState state) =>
                  const TrendsScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    return TrendDetailScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'b2b',
                  builder: (BuildContext context, GoRouterState state) =>
                      const B2BDashboardScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/alerts',
              builder: (BuildContext context, GoRouterState state) =>
                  const AlertsScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id']!;
                    return AlertDetailScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'preferences',
                  builder: (BuildContext context, GoRouterState state) =>
                      const NotificationPreferencesScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (BuildContext context, GoRouterState state) =>
                      const SettingsScreen(),
                ),
                GoRoute(
                  path: 'support',
                  builder: (BuildContext context, GoRouterState state) =>
                      const SupportScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (BuildContext context, GoRouterState state) =>
                      const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
