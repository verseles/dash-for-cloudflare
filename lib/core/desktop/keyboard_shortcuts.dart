import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut handler for desktop
class KeyboardShortcuts extends StatelessWidget {
  const KeyboardShortcuts({
    super.key,
    required this.child,
    this.onSave,
    this.onNew,
    this.onRefresh,
    this.onSearch,
    this.onEscape,
  });

  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onNew;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;
  final VoidCallback? onEscape;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl/Cmd + S for save
        if (onSave != null)
          const SingleActivator(LogicalKeyboardKey.keyS, control: true):
              onSave!,

        // Ctrl/Cmd + N for new
        if (onNew != null)
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): onNew!,

        // F5 for refresh
        if (onRefresh != null)
          const SingleActivator(LogicalKeyboardKey.f5): onRefresh!,

        // Ctrl/Cmd + R for refresh (alternative)
        if (onRefresh != null)
          const SingleActivator(LogicalKeyboardKey.keyR, control: true):
              onRefresh!,

        // Ctrl/Cmd + F for search
        if (onSearch != null)
          const SingleActivator(LogicalKeyboardKey.keyF, control: true):
              onSearch!,

        // Escape to close dialogs/cancel
        if (onEscape != null)
          const SingleActivator(LogicalKeyboardKey.escape): onEscape!,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// Shortcuts intent definitions
class SaveIntent extends Intent {
  const SaveIntent();
}

class NewIntent extends Intent {
  const NewIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

/// Shortcut actions for use with Actions widget
class ShortcutActions {
  static Map<Type, Action<Intent>> actions({
    VoidCallback? onSave,
    VoidCallback? onNew,
    VoidCallback? onRefresh,
    VoidCallback? onSearch,
  }) {
    return {
      if (onSave != null)
        SaveIntent: CallbackAction<SaveIntent>(onInvoke: (_) => onSave()),
      if (onNew != null)
        NewIntent: CallbackAction<NewIntent>(onInvoke: (_) => onNew()),
      if (onRefresh != null)
        RefreshIntent: CallbackAction<RefreshIntent>(
          onInvoke: (_) => onRefresh(),
        ),
      if (onSearch != null)
        SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) => onSearch()),
    };
  }

  static Map<ShortcutActivator, Intent> get shortcuts => {
    const SingleActivator(LogicalKeyboardKey.keyS, control: true):
        const SaveIntent(),
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        const NewIntent(),
    const SingleActivator(LogicalKeyboardKey.f5): const RefreshIntent(),
    const SingleActivator(LogicalKeyboardKey.keyR, control: true):
        const RefreshIntent(),
    const SingleActivator(LogicalKeyboardKey.keyF, control: true):
        const SearchIntent(),
  };
}
