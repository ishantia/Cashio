import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    if (onTap != null) {
      return Card(
        color: backgroundColor,
        margin: margin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return Card(color: backgroundColor, margin: margin, child: content);
  }
}
