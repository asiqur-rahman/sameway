import 'package:flutter_test/flutter_test.dart';
import 'package:sameway/core/constants/app_brand.dart';
import 'package:sameway/app.dart';

void main() {
  testWidgets('$kAppName app launches splash screen', (tester) async {
    await tester.pumpWidget(const SameWayApp());
    await tester.pumpAndSettle();

    expect(find.text(kAppName), findsOneWidget);
    expect(find.text('Get Started →'), findsOneWidget);
  });
}
