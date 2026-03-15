// ============================================================
// calculator.dart  —  BASE CLASS (Abstract)
// All calculators in this app inherit from this class.
// Demonstrates: abstract class, polymorphism, inheritance
// ============================================================

abstract class Calculator {
  // Abstract method — every subclass MUST implement this
  double calculate(List<double> values);

  // Concrete shared method available to all subclasses
  double average(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.fold(0.0, (prev, val) => prev + val);
    return sum / values.length;
  }

  // Lazy / Delayed initialisation example using late keyword
  late final String calculatorName;

  // Factory constructor — polymorphism entry point
  factory Calculator.ofType(String type) {
    switch (type) {
      case 'grade':
        return GradeCalculator();
      default:
        throw ArgumentError('Unknown calculator type: $type');
    }
  }
}

// ============================================================
// StudentRecord — Data model for one student
// ============================================================
class StudentRecord {
  final String studentId;
  final String studentName;
  final double examMark;

  // Computed properties using lambdas
  late final double _percentage;
  late final String _grade;
  late final String _result;

  // Delayed init — computed only when first needed
  StudentRecord({
    required this.studentId,
    required this.studentName,
    required this.examMark,
  }) {
    // Delayed initialisation of derived fields
    _percentage = examMark;
    _grade = GradeCalculator._computeGrade(examMark);
    _result = GradeCalculator._computeResult(examMark);
  }

  double get percentage => _percentage;
  String get grade => _grade;
  String get result => _result;

  // Convert to map for Excel export (lambda)
  Map<String, dynamic> toMap() => {
        'Student ID': studentId,
        'Student Name': studentName,
        'Exam Mark': examMark,
        'Percentage': '${examMark.toStringAsFixed(1)}%',
        'Grade': _grade,
        'Result': _result,
      };
}

// ============================================================
// GradeCalculator — DERIVED CLASS (extends Calculator)
// Demonstrates: inheritance, polymorphism, abstract override
// ============================================================
class GradeCalculator extends Calculator {
  // Delayed initialisation of calculator name
  GradeCalculator() {
    calculatorName = 'Grade Calculator'; // late field assigned here
  }

  // ---- Override abstract method (Polymorphism) ----
  @override
  double calculate(List<double> values) => average(values);

  // ---- Static helpers (Lambdas / arrow functions) ----

  static String _computeGrade(double mark) => switch (mark) {
        >= 75 => 'A',
        >= 70 => 'A-',
        >= 65 => 'B+',
        >= 60 => 'B',
        >= 55 => 'B-',
        >= 50 => 'C+',
        >= 45 => 'C',
        >= 40 => 'D',
        _ => 'F',
      };

  static String _computeResult(double mark) =>
      mark >= 40 ? 'PASS' : 'FAIL';

  // Process a list of raw row data into StudentRecords
  // Uses a lambda map transform
  List<StudentRecord> processStudents(List<Map<String, dynamic>> rawData) =>
      rawData
          .map((row) => StudentRecord(
                studentId: row['studentId']?.toString() ?? '',
                studentName: row['studentName']?.toString() ?? '',
                examMark: double.tryParse(row['examMark'].toString()) ?? 0,
              ))
          .toList();

  // Summary stats — using lambdas
  double classAverage(List<StudentRecord> students) =>
      students.isEmpty
          ? 0
          : calculate(students.map((s) => s.examMark).toList());

  int passCount(List<StudentRecord> students) =>
      students.where((s) => s.result == 'PASS').length;

  int failCount(List<StudentRecord> students) =>
      students.where((s) => s.result == 'FAIL').length;

  double highestMark(List<StudentRecord> students) =>
      students.isEmpty ? 0 : students.map((s) => s.examMark).reduce((a, b) => a > b ? a : b);

  double lowestMark(List<StudentRecord> students) =>
      students.isEmpty ? 0 : students.map((s) => s.examMark).reduce((a, b) => a < b ? a : b);
}
