import 'package:flutter_test/flutter_test.dart';
import 'package:moneybuddy/main.dart';

void main() {
  testWidgets('MoneyBuddy smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyBuddyApp(showPinLock: false));
    expect(find.byType(Object), findsWidgets);
  });
}