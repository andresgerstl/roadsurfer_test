import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/routing/router.dart';
import 'package:roadsurfer_test/utils/app_theme.dart';

void main() {
  // if (kIsWeb) {
  //   setUrlStrategy(PathUrlStrategy());
  // }
  runApp(const ProviderScope(child: CampsiteApp()));
}

class CampsiteApp extends StatelessWidget {
  const CampsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp.router(
          title: 'Roadsurfer Spots',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
