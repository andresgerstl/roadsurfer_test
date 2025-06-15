import 'package:flutter/material.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.compressedView,
    super.key,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final bool compressedView;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? color.withValues(alpha: .1)
                : Colors.grey.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color : Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? color : Colors.grey),
          if (!compressedView) const SizedBox(width: 4),
          if (!compressedView)
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
