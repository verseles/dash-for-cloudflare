import 'package:flutter/material.dart';

/// A wrapper widget that makes an empty state pull-to-refreshable when placed
/// inside a [RefreshIndicator].
///
/// Standard project UI practice dictates that this wrapper should be used around
/// empty state views (like [EmptyState] or empty text centers) in lists.
class RefreshableEmptyState extends StatelessWidget {
  const RefreshableEmptyState({
    super.key,
    required this.child,
  });

  /// The empty state view to display.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}
