import 'dart:async';
import 'dart:js_interop';

@JS('window.reloadForUpdate')
external void _reloadForUpdate();

@JS('window._flutterSwUpdateCallback')
external set _flutterSwUpdateCallback(JSFunction? callback);

class PwaUpdateService {
  PwaUpdateService._();
  static final instance = PwaUpdateService._();

  final _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateController.stream;

  bool _hasUpdate = false;
  bool get hasUpdate => _hasUpdate;

  void initialize() {
    _flutterSwUpdateCallback = _onUpdateAvailable.toJS;
  }

  void _onUpdateAvailable() {
    _hasUpdate = true;
    _updateController.add(true);
  }

  void reloadForUpdate() {
    _reloadForUpdate();
  }

  void dispose() {
    _flutterSwUpdateCallback = null;
    _updateController.close();
  }
}
