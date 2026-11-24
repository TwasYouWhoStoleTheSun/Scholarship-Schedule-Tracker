import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AssignmentTrackerApp());
}

class AssignmentTrackerApp extends StatelessWidget {
  const AssignmentTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment Tracker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3478F6)),
        fontFamily: 'Roboto',
      ),
      home: const AssignmentTrackerScreen(),
    );
  }
}

class Assignment {
  Assignment({
    required this.title,
    required this.subject,
    required this.dueDate,
    this.isComplete = false,
  });

  final String title;
  final String subject;
  final DateTime dueDate;
  bool isComplete;

  Map<String, Object> toJson() => {
    'title': title,
    'subject': subject,
    'dueDate': dueDate.toIso8601String(),
    'isComplete': isComplete,
  };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    title: json['title'] as String,
    subject: json['subject'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    isComplete: json['isComplete'] as bool? ?? false,
  );
}

class AssignmentTrackerScreen extends StatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  State<AssignmentTrackerScreen> createState() =>
      _AssignmentTrackerScreenState();
}

class _AssignmentTrackerScreenState extends State<AssignmentTrackerScreen> {
  static const _assignmentsStorageKey = 'assignments';

  final List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _loadError;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    unawaited(_loadAssignments());
  }

  List<Assignment> _defaultAssignments() => [
    Assignment(
      title: 'Essay: The Great Gatsby',
      subject: 'English Literature',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Assignment(
      title: 'Chapter 6 Problem Set',
      subject: 'Mathematics',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Assignment(
      title: 'Cell Structure Lab Report',
      subject: 'Biology',
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Assignment(
      title: 'World War II Presentation',
      subject: 'History',
      dueDate: DateTime.now().add(const Duration(days: 8)),
    ),
  ];

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final preferences = await SharedPreferences.getInstance();
      final savedAssignments = preferences.getString(_assignmentsStorageKey);
      final assignments = savedAssignments == null
          ? _defaultAssignments()
          : (jsonDecode(savedAssignments) as List<dynamic>).map((item) {
              if (item is! Map<String, dynamic>) {
                throw const FormatException(
                  'Saved assignment has an invalid format.',
                );
              }
              return Assignment.fromJson(item);
            }).toList();

      if (!mounted) return;
      setState(() {
        _assignments
          ..clear()
          ..addAll(assignments);
        _isLoading = false;
      });

      if (savedAssignments == null) {
        await _saveAssignments();
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'assignment storage',
          context: ErrorDescription('while loading saved assignments'),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load saved assignments. Please try again.';
      });
    }
  }

  Future<void> _saveAssignments() {
    final snapshot = jsonEncode(
      _assignments.map((assignment) => assignment.toJson()).toList(),
    );
    final save = _saveQueue.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _assignmentsStorageKey,
        snapshot,
      );
      if (!saved) {
        throw StateError('SharedPreferences did not save assignments.');
      }
    });
    _saveQueue = save.catchError((Object error, StackTrace stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'assignment storage',
          context: ErrorDescription('while saving assignments'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your assignments.')),
        );
      }
    });
    return _saveQueue;
  }

  int get _upcomingCount =>
      _assignments.where((assignment) => !assignment.isComplete).length;

  Future<void> _showAddAssignmentSheet() async {
    final assignment = await showModalBottomSheet<Assignment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddAssignmentSheet(),
    );

    if (assignment != null) {
      setState(() => _assignments.add(assignment));
      await _saveAssignments();
    }
  }

  Future<void> _showEditAssignmentSheet(Assignment assignment) async {
    final updatedAssignment = await showModalBottomSheet<Assignment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAssignmentSheet(assignment: assignment),
    );

    if (updatedAssignment != null) {
      final index = _assignments.indexOf(assignment);
      if (index >= 0) {
        setState(() => _assignments[index] = updatedAssignment);
        await _saveAssignments();
      }
    }
  }

  void _toggleAssignment(Assignment assignment) {
    setState(() => assignment.isComplete = !assignment.isComplete);
    unawaited(_saveAssignments());
  }

  void _deleteAssignment(Assignment assignment) {
    setState(() => _assignments.remove(assignment));
    unawaited(_saveAssignments());
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7EFFF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFF3478F6),
                          size: 25,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF4A5262),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'My Assignments',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: Color(0xFF192235),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stay on top of your schoolwork.',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF637087).withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Due soon',
                          value: '$_upcomingCount',
                          icon: Icons.schedule_rounded,
                          accent: const Color(0xFFFF9B54),
                          background: const Color(0xFFFFF1E7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Completed',
                          value:
                              '${_assignments.where((assignment) => assignment.isComplete).length}',
                          icon: Icons.check_circle_outline_rounded,
                          accent: const Color(0xFF39AE87),
                          background: const Color(0xFFE7F7F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Upcoming work',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF192235),
                          ),
                        ),
                      ),
                      Text(
                        _formatFullDate(today),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C8799),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_loadError!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _loadAssignments,
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _assignments.isEmpty
                  ? const _EmptyAssignments()
                  : LayoutBuilder(
    builder: (context, constraints) {
      final columnCount = constraints.maxWidth > 400 ? 3 : 1;

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        itemCount: _assignments.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 180,
        ),
        itemBuilder: (context, index) {
          final assignment = _assignments[index];
          return _AssignmentCard(
            assignment: assignment,
            onToggle: () => _toggleAssignment(assignment),
            onDelete: () => _deleteAssignment(assignment),
            onEdit: () => _showEditAssignmentSheet(assignment),
          );
        },
      );
    },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              key: const Key('addAssignmentButton'),
              onPressed: _isLoading || _loadError != null
                  ? null
                  : _showAddAssignmentSheet,
              icon: const Icon(Icons.add_rounded, size: 23),
              label: const Text(
                'Add assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3478F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                elevation: 3,
                shadowColor: const Color(0x663478F6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF192235),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C8799),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final Assignment assignment;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dueText = _formatDueDate(assignment.dueDate);
    final isOverdue =
        !assignment.isComplete && assignment.dueDate.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1D37),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                assignment.isComplete
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: assignment.isComplete
                    ? const Color(0xFF39AE87)
                    : const Color(0xFFB7C0CF),
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: assignment.isComplete
                        ? const Color(0xFF929BAA)
                        : const Color(0xFF263248),
                    decoration: assignment.isComplete
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  assignment.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C8799),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: isOverdue
                          ? const Color(0xFFE36B69)
                          : const Color(0xFF71809A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      assignment.isComplete ? 'Completed' : dueText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? const Color(0xFFE36B69)
                            : const Color(0xFF71809A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Assignment actions',
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF9AA4B3),
              size: 22,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit assignment'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFE36B69),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Delete assignment',
                      style: TextStyle(color: Color(0xFFE36B69)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 34,
                color: Color(0xFF3478F6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF192235),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add an assignment to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF7C8799)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAssignmentSheet extends StatefulWidget {
  const _AddAssignmentSheet({this.assignment});

  final Assignment? assignment;

  @override
  State<_AddAssignmentSheet> createState() => _AddAssignmentSheetState();
}

class _AddAssignmentSheetState extends State<_AddAssignmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.assignment!.title;
      _subjectController.text = widget.assignment!.subject;
      _dueDate = widget.assignment!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _chooseDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (selectedDate != null) {
      setState(() => _dueDate = selectedDate);
    }
  }

  void _saveAssignment() {
    if (!_formKey.currentState!.validate()) return;

    final updatedAssignment = Assignment(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      dueDate: _dueDate,
      isComplete: widget.assignment?.isComplete ?? false,
    );

    Navigator.of(context).pop(updatedAssignment);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE1EA),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _isEditing ? 'Edit assignment' : 'New assignment',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF192235),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isEditing
                      ? 'Update the assignment details and due date.'
                      : 'Add the details and due date for your task.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7C8799),
                  ),
                ),
                const SizedBox(height: 22),
                _fieldLabel('Assignment name'),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('assignmentTitleField'),
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration('e.g. Chapter 4 worksheet'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an assignment name'
                      : null,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Subject'),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('assignmentSubjectField'),
                  controller: _subjectController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('e.g. Biology'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a subject'
                      : null,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Due date'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _chooseDueDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: _inputDecoration(null),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF3478F6),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatFullDate(_dueDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF263248),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7C8799),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    key: const Key('saveAssignmentButton'),
                    onPressed: _saveAssignment,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3478F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Save changes' : 'Add assignment',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF364258),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA3ACBA)),
      filled: true,
      fillColor: const Color(0xFFF7F8FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6EAF1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6EAF1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3478F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE36B69)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE36B69), width: 1.5),
      ),
    );
  }
}

String _formatDueDate(DateTime date) {
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  final difference = dateOnly.difference(todayOnly).inDays;

  if (difference == 0) return 'Due today';
  if (difference == 1) return 'Due tomorrow';
  if (difference < 0) return 'Overdue';
  return 'Due ${_formatFullDate(date)}';
}

String _formatFullDate(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}
