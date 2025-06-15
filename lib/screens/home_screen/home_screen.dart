import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';
import 'package:roadsurfer_test/routing/routes.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_empty_state.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_error.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_filters/home_screen_filter_button.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_filters/home_screen_filter_display_info.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_grid.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_list.dart';
import 'package:roadsurfer_test/utils/app_icons.dart';
import 'package:roadsurfer_test/widgets/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const tag = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campsitesAsync = ref.watch(filteredCampsitesProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth ~/ 300).clamp(2, 3);
        final showFilter = crossAxisCount == 3;
        final isLargeScreen = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            title: SvgPicture.asset(
              AppIcons.roadsurferLogo,
              height: kToolbarHeight - 25,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.mapRoute),
                icon: const Icon(Icons.map),
              ),
              if (!showFilter) const SizedBox(width: 8),
              if (!showFilter) const HomeScreenFilterButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              const HomeScreenFilterDisplayInfo(),
              Expanded(
                child: campsitesAsync.when(
                  data: (campsites) {
                    if (campsites.isEmpty && !isLargeScreen) {
                      return const HomeScreenEmptyState();
                    }
                    return AnimationLimiter(
                      child:
                          isLargeScreen
                              ? HomeScreenGrid(campsites)
                              : HomeScreenList(campsites),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (error, stack) {
                    // log error
                    return HomeScreenError(error);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
