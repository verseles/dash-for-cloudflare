import 'package:flutter_test/flutter_test.dart';

import 'package:cf/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DashForCloudflareApp());

    expect(find.text('Dash for Cloudflare - Setup Complete'), findsOneWidget);
  });
}
