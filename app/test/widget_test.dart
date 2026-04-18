import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sme_cashflow_dashboard/app/app.dart';

void main() {
  testWidgets('shows login page by default', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmeCashflowApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
