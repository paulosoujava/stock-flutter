import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String route;

  const ActionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.route,
  });
}
