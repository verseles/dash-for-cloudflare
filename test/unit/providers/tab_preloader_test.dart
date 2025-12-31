import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cf/features/dns/providers/tab_preloader_provider.dart';

void main() {
  group('ActiveTabIndex', () {
    test('initial value is 0 (Records tab)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tabIndex = container.read(activeTabIndexProvider);

      expect(tabIndex, 0);
    });

    test('setIndex updates the active tab', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeTabIndexProvider.notifier).setIndex(1);

      expect(container.read(activeTabIndexProvider), 1);
    });

    test('setIndex to Analytics tab (1)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeTabIndexProvider.notifier).setIndex(1);

      expect(container.read(activeTabIndexProvider), 1);
    });

    test('setIndex to Settings tab (2)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(activeTabIndexProvider.notifier).setIndex(2);

      expect(container.read(activeTabIndexProvider), 2);
    });

    test('setIndex back to Records tab (0)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start at different tab
      container.read(activeTabIndexProvider.notifier).setIndex(2);
      expect(container.read(activeTabIndexProvider), 2);

      // Go back to records
      container.read(activeTabIndexProvider.notifier).setIndex(0);
      expect(container.read(activeTabIndexProvider), 0);
    });
  });
}
