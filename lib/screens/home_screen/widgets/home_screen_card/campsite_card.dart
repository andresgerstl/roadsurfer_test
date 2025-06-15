import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/routing/routes.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_card/widgets/feature_chip.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class CampsiteCard extends StatefulWidget {
  final Campsite campsite;

  const CampsiteCard({
    super.key,
    required this.campsite,
    this.compressedView = false,
  });
  final bool compressedView;

  @override
  State<CampsiteCard> createState() => _CampsiteCardState();
}

class _CampsiteCardState extends State<CampsiteCard> {
  bool saved = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallCard = constraints.constrainWidth() < 250;
        return InkWell(
          onTap:
              () => context.push(
                AppRoutes.campsiteDetailRoute.replaceFirst(
                  AppRoutes.idConstant,
                  widget.campsite.id,
                ),
                extra: widget.campsite,
              ),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: CachedNetworkImage(
                        imageUrl: widget.campsite.photo,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.black.withValues(alpha: .5),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          saved = !saved;
                          if (saved) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.campsite.label.capitalize()} Saved',
                                ),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        });
                      },
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.campsite.label.capitalize(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          flex: 0,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.campsite.formattedPrice,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '/night',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Features Row
                    Row(
                      children: [
                        FeatureChip(
                          icon: Icons.water_drop,
                          label:
                              widget.campsite.isCloseToWater
                                  ? 'Close to water'
                                  : 'No water',
                          isActive: widget.campsite.isCloseToWater,
                          color: Colors.blue,
                          compressedView: widget.compressedView && smallCard,
                        ),
                        const SizedBox(width: 8),
                        FeatureChip(
                          icon: Icons.local_fire_department,
                          label:
                              widget.campsite.isCampFireAllowed
                                  ? 'Campfire OK'
                                  : 'No campfire',
                          isActive: widget.campsite.isCampFireAllowed,
                          color: Colors.orange,
                          compressedView: widget.compressedView && smallCard,
                        ),
                        if (widget.compressedView && smallCard)
                          const SizedBox(width: 8),
                        if (widget.compressedView && smallCard)
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 16,
                                color: context.theme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.campsite.languagesString,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.compressedView && !smallCard)
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 16,
                            color: context.theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.campsite.languagesString,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
