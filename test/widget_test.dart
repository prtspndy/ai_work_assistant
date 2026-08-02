import 'package:flutter_test/flutter_test.dart';
import 'package:ai_work_assistant/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VyaparMitraApp());
    expect(find.byType(VyaparMitraApp), findsOneWidget);
  });
}
