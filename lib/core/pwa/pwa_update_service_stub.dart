import 'dart:async';

class PwaUpdateService {
  PwaUpdateService._();
  static final instance = PwaUpdateService._();

  final _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateController.stream;

  bool get hasUpdate => false;

  void initialize() {}

  void reloadForUpdate() {}

  void dispose() {
    _updateController.close();
  }
}
