import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_card/campsite_card.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_empty_state.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_filters/home_screen_filter_grid.dart';

class HomeScreenGrid extends StatelessWidget {
  const HomeScreenGrid(this.campsites, {super.key});
  final List<Campsite> campsites;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth ~/ 300).clamp(2, 3);
        final showFilter = crossAxisCount == 3;
        return Row(
          children: [
            if (showFilter)
              const Expanded(flex: 1, child: HomeScreenGridFilter()),
            if (campsites.isEmpty)
              const Expanded(flex: 3, child: HomeScreenEmptyState()),
            if (campsites.isNotEmpty)
              Expanded(
                flex: 3,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 4 / 5,
                  ),
                  itemCount: campsites.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: crossAxisCount,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 100.0,
                        child: FadeInAnimation(
                          child: CampsiteCard(
                            campsite: campsites.elementAt(index),
                            compressedView: showFilter,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
