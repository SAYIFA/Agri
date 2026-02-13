import 'package:flutter_test/flutter_test.dart';
import 'package:agrishare/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriShareApp());
    // Verify the app builds without errors
    expect(find.text('AgriShare'), findsAny);
  });
}
