import 'package:flutter_test/flutter_test.dart';
import 'package:sameway/app.dart';

void main() {
  testWidgets('SameWay app launches splash screen', (tester) async {
    await tester.pumpWidget(const SameWayApp());
    await tester.pumpAndSettle();

    expect(find.text('SameWay'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
