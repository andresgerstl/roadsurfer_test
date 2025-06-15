import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_card/campsite_card.dart';
import 'package:roadsurfer_test/utils/app_theme.dart';

class HomeScreenList extends StatelessWidget {
  const HomeScreenList(this.campsites, {super.key});
  final List<Campsite> campsites;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: horizontalPadding,
      ),
      itemCount: campsites.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 100.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CampsiteCard(campsite: campsites[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}
