import 'package:flutter_test/flutter_test.dart';
import 'package:music_manager/main.dart';

void main() {
  testWidgets('App pumps and renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
