import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_1/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows assignments and a fixed add button', (tester) async {
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('My Assignments'), findsOneWidget);
    expect(find.text('Essay: The Great Gatsby'), findsOneWidget);
    expect(find.text('English Literature'), findsOneWidget);
    expect(find.byKey(const Key('addAssignmentButton')), findsOneWidget);
  });

  testWidgets('completed assignments can be deleted', (tester) async {
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Delete assignment'), findsNothing);

    await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Delete assignment'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Essay: The Great Gatsby'), findsOneWidget);
    expect(find.byTooltip('Delete assignment'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete assignment'));
    await tester.pumpAndSettle();

    expect(find.text('Essay: The Great Gatsby'), findsNothing);
    expect(find.byTooltip('Delete assignment'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Essay: The Great Gatsby'), findsNothing);
  });

  testWidgets('adds an assignment from the form', (tester) async {
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addAssignmentButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('assignmentTitleField')),
      'Read chapter seven',
    );
    await tester.enterText(
      find.byKey(const Key('assignmentSubjectField')),
      'Science',
    );
    await tester.ensureVisible(find.byKey(const Key('saveAssignmentButton')));
    await tester.tap(find.byKey(const Key('saveAssignmentButton')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Read chapter seven'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('assignments'),
      contains('Read chapter seven'),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const AssignmentTrackerApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Read chapter seven'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
  });
}
