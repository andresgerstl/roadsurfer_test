import 'package:flutter/material.dart';

class CampsiteDetailFeature extends StatelessWidget {
  const CampsiteDetailFeature({
    required this.icon,
    required this.title,
    required this.child,
    super.key,
  });
  final Widget icon;
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
