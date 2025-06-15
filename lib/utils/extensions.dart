import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DoubleExtension on double {
  String formattedPrice() {
    final formatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    return formatter.format(this);
  }
}
