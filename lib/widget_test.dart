import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_1/main.dart';

void main() {
  testWidgets('Assignment tracker skeleton renders a task form', (WidgetTester tester) async {
    await tester.pumpWidget(const AssignmentTrackerApp());

    expect(find.text('Assignment Tracking Skeleton'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
  });
}
