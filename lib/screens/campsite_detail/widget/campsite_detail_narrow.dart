import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/screens/campsite_detail/widget/campsite_detail_feature.dart';
import 'package:roadsurfer_test/screens/campsite_detail/widget/campsite_detail_map.dart';
import 'package:roadsurfer_test/utils/app_theme.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class CampsiteDetailNarrow extends StatelessWidget {
  const CampsiteDetailNarrow(this.campsite, {super.key});
  final Campsite campsite;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: context.theme.canvasColor,
                  surfaceTintColor: context.theme.canvasColor,
                  elevation: 0,
                  stretch: true,
                  pinned: true,
                  leading: BackButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        _,
                      ) {
                        return Colors.white.withValues(alpha: .6);
                      }),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: CachedNetworkImage(
                      imageUrl: campsite.photo,
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ),
                    title: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: context.theme.canvasColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  expandedHeight: 450,
                ),
              ];
            },
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Center(
                    child: Text(
                      campsite.label.capitalize(),
                      style: context.theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CampsiteDetailFeature(
                      title: 'Campfire',
                      icon: Icon(
                        Icons.local_fire_department,
                        color:
                            campsite.isCampFireAllowed
                                ? Colors.orange
                                : Colors.grey,
                      ),
                      child: Text(
                        campsite.isCampFireAllowed
                            ? 'Campfire allowed'
                            : 'No campfire allowed',
                        style: TextStyle(
                          color:
                              campsite.isCampFireAllowed ? Colors.orange : null,
                        ),
                      ),
                    ),
                    CampsiteDetailFeature(
                      title: 'Close to water',
                      icon: Icon(
                        Icons.water_drop,
                        color:
                            campsite.isCloseToWater ? Colors.blue : Colors.grey,
                      ),
                      child: Text(
                        campsite.isCloseToWater ? 'Close to water' : 'No water',
                        style: TextStyle(
                          color: campsite.isCloseToWater ? Colors.blue : null,
                        ),
                      ),
                    ),
                    CampsiteDetailFeature(
                      title: 'Host language',
                      icon: Icon(
                        Icons.language,
                        color: context.theme.primaryColor,
                      ),
                      child: Wrap(
                        spacing: 8,

                        children:
                            campsite.hostLanguages
                                .map(
                                  (lang) => Chip(
                                    label: Text(lang.toUpperCase()),
                                    backgroundColor: context.theme.primaryColor
                                        .withValues(alpha: .1),
                                    labelStyle: TextStyle(
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: CampsiteDetailMap(campsite),
                ),
                const SizedBox(height: 24),
                // Details Section
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: campsite.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: '/night',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking for ${campsite.label}'),
                      action: SnackBarAction(label: 'OK', onPressed: () {}),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
