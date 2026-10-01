import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../providers.dart';
import '../../presentation/onboarding/language_selection_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/accounts/accounts_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/debts/debts_screen.dart';
import '../../presentation/recurring/recurring_screen.dart';
import '../../presentation/categories/categories_screen.dart';
import '../../presentation/budgets/budgets_screen.dart';
import '../../presentation/reports/reports_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/shell/app_shell.dart';
import '../../presentation/shell/more_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final shellNavigatorTransactionsKey = GlobalKey<NavigatorState>(
  debugLabel: 'transactions',
);
final shellNavigatorReportsKey = GlobalKey<NavigatorState>(
  debugLabel: 'reports',
);
final shellNavigatorMoreKey = GlobalKey<NavigatorState>(debugLabel: 'more');

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingComplete ? '/dashboard' : '/onboarding/language',
    routes: [
      GoRoute(
        path: '/onboarding/language',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorTransactionsKey,
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorReportsKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorMoreKey,
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'accounts',
                    builder: (context, state) => const AccountsScreen(),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'debts',
                    builder: (context, state) => const DebtsScreen(),
                  ),
                  GoRoute(
                    path: 'recurring',
                    builder: (context, state) => const RecurringScreen(),
                  ),
                  GoRoute(
                    path: 'budgets',
                    builder: (context, state) => const BudgetsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
