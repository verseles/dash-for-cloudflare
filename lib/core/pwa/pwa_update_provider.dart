import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pwa_update_service.dart';

final pwaUpdateAvailableProvider = StreamProvider<bool>((ref) {
  return PwaUpdateService.instance.updateAvailable;
});
