import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_provider.g.dart';

/// Loading state for multiple parallel operations
@riverpod
class LoadingNotifier extends _$LoadingNotifier {
  @override
  Set<String> build() => {};

  /// Start loading for an operation
  void startLoading(String operationId) {
    state = {...state, operationId};
  }

  /// Stop loading for an operation
  void stopLoading(String operationId) {
    state = state.difference({operationId});
  }

  /// Check if any operation is loading
  bool get isAnyLoading => state.isNotEmpty;

  /// Check if a specific operation is loading
  bool isLoading(String operationId) => state.contains(operationId);
}

/// Provider for checking if any loading is active
@riverpod
bool isAnyLoading(Ref ref) {
  return ref.watch(loadingNotifierProvider).isNotEmpty;
}
