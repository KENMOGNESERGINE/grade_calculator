# Student Grade Calculator (Dart + Flutter)

This repository contains:
- a Dart console app (Excel input/output),
- a Flutter web/mobile app version,
- collection and higher-order function exercises.

---

## Project Structure

```
grade_calculator/
├── bin/
│    ├── grade_calculator.dart     ← Console application
│    ├── exercise1.dart            ← Exercise 1: Higher Order Function
│    ├── exercise2.dart            ← Exercise 2: Collection Transformations
│    └── exercise3.dart            ← Exercise 3: Complex Data Processing
├── lib/
│    └── calculator.dart           ← Shared OOP logic
├── grade_calculator_app/          ← Flutter GUI application
│    ├── lib/
│    │    ├── calculator.dart      ← OOP logic
│    │    └── main.dart            ← Flutter UI
│    └── pubspec.yaml
├── students.xlsx                  ← Sample Excel input file
├── pubspec.yaml
└── README.md
```

---

## Console App Features

- Manual grading from Excel file.
- Excel mode:
  - reads local `.xlsx` file (Sheet: `Scores`),
  - calculates average and grade per subject per student,
  - writes results to Sheet `Grades` in the same file,
  - prints both input and grades to console.

---

## GradeCalculator Class (OOP Structure)

```
abstract class Calculator          ← Interface (contract)
        ↑
class BaseCalculator               ← Parent class (shared logic)
        ↑
class GradeCalculator              ← Child class (student management)
```

### Properties and Methods

| Member | Description |
|--------|-------------|
| `formula` | Lambda: `(double a, double b) => (a * 0.8) + (b * 0.6)` |
| `calculate(ca, exam)` | Applies formula to get subject average |
| `getGrade(average)` | Returns letter grade A–F |
| `processStudents(data)` | Processes all students using collection operations |

### Collection Operations Used

| Operation | Where used |
|-----------|-----------|
| `.map()` | Transform student rows into result objects |
| `.where()` | Filter valid student entries |
| `.fold()` | Calculate totals and averages |
| `.toList()` | Convert iterables to lists |
| `.asMap()` | Index subject columns |

---

## Grade Calculation Formula

```
Subject Average = (CA × 0.8) + (Exam × 0.6)
```

| Component | Max Score | Weight | Max Points |
|-----------|-----------|--------|------------|
| CA | /10 | 40% | 8 pts |
| Exam | /20 | 60% | 12 pts |
| **Total** | | | **20 pts** |

### Grading Scale

| Average /20 | Grade |
|-------------|-------|
| 16.00 – 20.00 | A |
| 14.00 – 15.99 | B |
| 12.00 – 13.99 | C |
| 10.00 – 11.99 | D |
| 8.00 – 9.99 | E |
| 0.00 – 7.99 | F |

---

## Excel File Structure

**Sheet 1 — Scores** (input, filled manually):

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths CA | Maths Exam | ... |
|-----------|------|----------|-----|-----|-------|----------|------------|-----|

- Subject names are in **Row 3**
- Student data starts from **Row 5**
- CA columns are out of **10**
- Exam columns are out of **20**

**Sheet 2 — Grades** (output, generated automatically):

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths Avg /20 | Maths Grade | ... |
|-----------|------|----------|-----|-----|-------|--------------|-------------|-----|

---

## Run Console App

```bash
# Make sure students.xlsx is closed in Excel first!
dart pub get
dart run
```

---

## Flutter Mobile/Web App

### Features

- Import any `students.xlsx` file
- Display grades in beautiful student cards
- Color coded grades (A=green, B=light green, C=blue, D=orange, F=red)
- Export results as **Excel**, **PDF**, or **Word**
- Dark blue professional UI

### Run Flutter App

```bash
cd grade_calculator_app
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android (connect phone via USB with USB debugging enabled)
flutter run -d android
```

---

## Exercises

### Exercise 1 — Higher Order Function
**File:** `bin/exercise1.dart`

**Task:** Write a function `processList` that takes a list of integers and a lambda as parameter, and returns only elements that satisfy the condition.

```dart
List<int> processList(List<int> numbers, bool Function(int) predicate) {
  return numbers.where(predicate).toList();
}

void main() {
  var nums = [1, 2, 3, 4, 5, 6];
  var even = processList(nums, (n) => n % 2 == 0);
  print(even); // [2, 4, 6]
}
```

**Output:**
```
[2, 4, 6]
```

---

### Exercise 2 — Transforming Between Collection Types
**File:** `bin/exercise2.dart`

**Task:** Given a list of strings, create a map where keys are the strings and values are their lengths. Print only entries where length is greater than 4.

```dart
void main() {
  var words = ['apple', 'cat', 'banana', 'dog', 'elephant'];

  var wordLengths = Map.fromIterable(
    words,
    key:   (word) => word,
    value: (word) => (word as String).length,
  );

  wordLengths.entries
    .where((entry) => entry.value > 4)
    .forEach((entry) {
      print('${entry.key} has length ${entry.value}');
    });
}
```

**Output:**
```
apple has length 5
banana has length 6
elephant has length 7
```

---

### Exercise 3 — Complex Data Processing
**File:** `bin/exercise3.dart`

**Task:** Find the average age of people whose names start with 'A' or 'B'. Print rounded to 1 decimal place.

```dart
class Person {
  final String name;
  final int age;
  Person(this.name, this.age);
}

void main() {
  var people = [
    Person('Alice', 25), Person('Bob', 30),
    Person('Charlie', 35), Person('Anna', 22), Person('Ben', 28),
  ];

  // Step 1 - Filter people whose name starts with A or B
  var filtered = people
    .where((p) => p.name.startsWith('A') || p.name.startsWith('B'))
    .toList();

  // Step 2 - Extract ages
  var ages = filtered.map((p) => p.age).toList();

  // Step 3 - Calculate average
  double total   = ages.fold(0.0, (sum, age) => sum + age);
  double average = total / ages.length;

  // Step 4 - Format and print
  print('Average age: ${average.toStringAsFixed(1)}');
}
```

**Output:**
```
Average age: 26.2
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/KENMOGNESERGINE/grade_calculator.git

# Go into the project
cd grade_calculator

# Install console dependencies
dart pub get

# Install Flutter dependencies
cd grade_calculator_app
flutter pub get
```

---

## Dependencies

### Console (`pubspec.yaml`)
```yaml
dependencies:
  excel: ^4.0.2
```

### Flutter (`grade_calculator_app/pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  excel: ^4.0.2
  pdf: ^3.10.4
  printing: ^5.11.0
  path_provider: ^2.1.2
  universal_html: ^2.2.4
```

---

## Important Notes

> ⚠️ Always **close** `students.xlsx` in Excel before running the console app.

> ✅ The Flutter app runs on **Web, Android, iOS and Desktop** from the same codebase.

---

## About

A calculator that reads student scores from an Excel file, calculates the grade per subject for each student, and returns results both to the console and to a new Excel sheet.

---

*Kenmogne Matchuekam Sergine — ICT University — 2024/2025*
