import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerEntry {
  const DrawerEntry({
    this.icon,
    required this.label,
    required this.onTap,
    this.faIcon,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final FaIcon? faIcon;
}
