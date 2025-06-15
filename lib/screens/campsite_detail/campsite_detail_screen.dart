import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';
import 'package:roadsurfer_test/screens/campsite_detail/widget/campsite_detail_narrow.dart';
import 'package:roadsurfer_test/screens/campsite_detail/widget/campsite_detail_wide.dart';
import 'package:roadsurfer_test/utils/app_icons.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class CampsiteDetailScreen extends ConsumerWidget {
  const CampsiteDetailScreen({super.key, required this.id, this.campsite});
  static const tag = 'campsite_detail';
  final Campsite? campsite;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campsiteAsync =
        campsite != null
            ? AsyncValue.data(campsite!)
            : ref.watch(campsiteDetailProvider(id));

    return campsiteAsync.when(
      data:
          (campsite) => LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              return Scaffold(
                backgroundColor: context.theme.canvasColor,
                appBar:
                    !isNarrow
                        ? AppBar(
                          title: SvgPicture.asset(
                            AppIcons.roadsurferLogo,
                            height: kToolbarHeight - 25,
                          ),
                          centerTitle: true,
                        )
                        : null,
                body:
                    isNarrow
                        ? CampsiteDetailNarrow(campsite)
                        : CampsiteDetailWide(campsite),
              );
            },
          ),
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
