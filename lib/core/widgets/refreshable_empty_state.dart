import 'package:flutter/material.dart';

/// A wrapper widget to make empty states pull-to-refreshable inside a RefreshIndicator.
class RefreshableEmptyState extends StatelessWidget {
  const RefreshableEmptyState({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
