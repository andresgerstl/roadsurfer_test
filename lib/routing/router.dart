import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/routing/routes.dart';
import 'package:roadsurfer_test/screens/map_screen/map_screen.dart';

import '../screens/campsite_detail/campsite_detail_screen.dart';
import '../screens/home_screen/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.root,
  routes: [
    GoRoute(
      path: AppRoutes.root,
      name: HomeScreen.tag,
      builder:
          (BuildContext context, GoRouterState state) => const HomeScreen(),
      routes: <GoRoute>[
        GoRoute(
          path: AppRoutes.campsiteDetail,
          name: CampsiteDetailScreen.tag,
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.params['id']!;
            Campsite? campsite;
            try {
              if (state.extra != null) {
                campsite = Campsite.fromJson(
                  state.extra as Map<String, dynamic>,
                );
              }
            } catch (_) {
              // log parsing error
            }
            return CampsiteDetailScreen(id: id, campsite: campsite);
          },
        ),

        GoRoute(
          path: AppRoutes.map,
          name: 'a',
          builder: (BuildContext context, GoRouterState state) {
            return const MapScreen();
          },
        ),
      ],
    ),
  ],
);
