

// ──────────────────────────────────────────────────────────────
//  ABSTRACT CLASS — Calculator (Interface)
//  Defines the contract — every calculator MUST implement these
// ──────────────────────────────────────────────────────────────
abstract class Calculator {
  double calculate(double ca, double exam);
  String getGrade(double average);
}


// ──────────────────────────────────────────────────────────────
//  PARENT CLASS — BaseCalculator
//  Implements Calculator interface
//  Contains shared logic used by all calculators
// ──────────────────────────────────────────────────────────────
class BaseCalculator implements Calculator {

  // Lambda passed as higher order function
  // The formula is a variable that holds a function
  @override
  double calculate(double ca, double exam) {
    if (ca   > 10) ca   = 10;
    if (exam > 20) exam = 20;

    // Lambda — formula written as one-line function
    final formula = (double a, double b) => (a * 0.8) + (b * 0.6);

    return double.parse(formula(ca, exam).toStringAsFixed(2));
  }

  // Grade assignment based on average
  @override
  String getGrade(double average) {
    if (average >= 16) return 'A';
    if (average >= 14) return 'B';
    if (average >= 12) return 'C';
    if (average >= 10) return 'D';
    if (average >= 8)  return 'E';
    return 'F';
  }
}


// ──────────────────────────────────────────────────────────────
//  CHILD CLASS — GradeCalculator
//  Extends BaseCalculator — inherits calculate() and getGrade()
//  Adds student management using collection operations
// ──────────────────────────────────────────────────────────────
class GradeCalculator extends BaseCalculator {

  // Collection of all students
  List<Map<String, dynamic>> students = [];

  // List of subjects
  List<String> subjects = [];

  // ── Process students read from Excel ─────────────────────────
  // Takes raw rows from Excel and calculates all grades
  void processStudents(
    List<Map<String, dynamic>> rawStudents,
    List<String> subjectNames,
  ) {
    subjects = subjectNames;
    students.clear();

    // Collection operation — map over raw students
    students = rawStudents.map((raw) {
      final caScores   = raw['caScores']   as List<double>;
      final examScores = raw['examScores'] as List<double>;

      // Collection operation — calculate result for each subject
      final subjectResults = subjects.asMap().entries.map((entry) {
        int    index   = entry.key;
        String subject = entry.value;

        double ca   = index < caScores.length   ? caScores[index]   : 0.0;
        double exam = index < examScores.length ? examScores[index] : 0.0;

        // Uses inherited calculate() and getGrade() from BaseCalculator
        double avg   = calculate(ca, exam);
        String grade = getGrade(avg);

        return <String, dynamic>{
          'subject': subject,
          'ca':      ca,
          'exam':    exam,
          'avg':     avg,
          'grade':   grade,
        };
      }).toList();

      return <String, dynamic>{
        'matricule':      raw['matricule']      ?? '',
        'name':           raw['name']           ?? '',
        'surName':        raw['surName']        ?? '',
        'sex':            raw['sex']            ?? '',
        'dob':            raw['dob']            ?? '',
        'class':          raw['class']          ?? '',
        'subjectResults': subjectResults,
      };
    }).toList();
  }

  // Clear all data
  void clear() {
    students.clear();
    subjects.clear();
  }

  // Total student count
  int get totalStudents => students.length;
}