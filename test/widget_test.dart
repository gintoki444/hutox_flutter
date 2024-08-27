import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dml_verify_tags/main.dart';
// import 'package:your_project_name/main.dart'; // นำเข้า MyApp จาก main.dart

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Arrange
    bool isLoggedIn = false; // กำหนดสถานะล็อกอินที่ต้องการใช้ทดสอบ

    // Act
    await tester.pumpWidget(MyApp(isLoggedIn: isLoggedIn));

    // Assert
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
