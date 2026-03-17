# Student Grade Calculator

A complete student grade management system built with **Dart** and  **Flutter** .

It runs as both a **console application** (with Excel) and a **Flutter GUI application** (web & Android).

---



## Project Structure

```
grade_calculator/
│
├── bin/
│    └── grade_calculator.dart     ← Console version (reads/writes Excel)
│
├── lib/
│    └── calculator.dart           ← Shared OOP logic
│
├── grade_calculator_app/          ← Flutter GUI version
│    ├── lib/
│    │    ├── calculator.dart      ← OOP logic (copy)
│    │    └── main.dart            ← Flutter UI
│    └── pubspec.yaml
│
├── students.xlsx                  ← Excel file with student scores
├── pubspec.yaml
└── README.md
```

---

## 🏗️ OOP Architecture

The project uses full Object Oriented Programming as required:

```
abstract class Calculator          ← Interface (contract)
        ↑
class BaseCalculator               ← Parent class (shared logic)
        ↑
class GradeCalculator              ← Child class (student management)
```

### Concepts used:

| Concept                              | Where                                                             |
| ------------------------------------ | ----------------------------------------------------------------- |
| **Abstract class / Interface** | `abstract class Calculator`                                     |
| **Parent class**               | `class BaseCalculator implements Calculator`                    |
| **Child class / Inheritance**  | `class GradeCalculator extends BaseCalculator`                  |
| **Lambda**                     | `final formula = (double a, double b) => (a * 0.8) + (b * 0.6)` |
| **Higher order function**      | Formula passed as a variable inside `calculate()`               |
| **Collection operations**      | `.map()`,`.asMap()`,`.where()`,`.toList()`,`.fold()`    |

---

## ⚙️ How It Works

### Formula

```
Subject Average = (CA × 0.8) + (Exam × 0.6)
```

| Component       | Max Score | Weight         | Max Contribution    |
| --------------- | --------- | -------------- | ------------------- |
| CA              | 10        | 40%            | 8 points            |
| Exam            | 20        | 60%            | 12 points           |
| **Total** |           | **100%** | **20 points** |

### Grading Scale

| Average /20    | Grade       |
| -------------- | ----------- |
| 16.00 – 20.00 | **A** |
| 14.00 – 15.99 | **B** |
| 12.00 – 13.99 | **C** |
| 10.00 – 11.99 | **D** |
| 8.00 – 9.99   | **E** |
| 0.00 – 7.99   | **F** |

---

## 🖥️ Version 1 — Console Application

Reads student scores from **Sheet 1 (Scores)** of the Excel file,

calculates grades for each subject, and writes results to  **Sheet 2 (Grades)** .

### Excel File Structure

**Sheet 1 — Scores** (filled manually):

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths CA | Maths Exam | ... |
| --------- | ---- | -------- | --- | --- | ----- | -------- | ---------- | --- |

* Subject names are in **Row 3**
* Student data starts from **Row 5**
* CA is out of  **10** , Exam is out of **20**

**Sheet 2 — Grades** (filled automatically):

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths Avg | Maths Grade | ... |
| --------- | ---- | -------- | --- | --- | ----- | --------- | ----------- | --- |

### How to Run Console Version

```bash
# Make sure students.xlsx is closed in Excel first!
dart run
```

---

## 📱 Version 2 — Flutter GUI Application

A beautiful dark blue mobile and web application that:

* 📂 Imports any `students.xlsx` file
* 📊 Calculates and displays grades per subject in beautiful cards
* 💾 Exports results as  **Excel** ,  **PDF** , or **Word**

### How to Run Flutter Version

```bash
cd grade_calculator_app

# Run on Chrome (web)
flutter run -d chrome

# Run on Android phone (connect phone via USB first)
flutter run -d android

# Install packages first if needed
flutter pub get
```

### Features

| Feature            | Description                                        |
| ------------------ | -------------------------------------------------- |
| 📂 Import Excel    | Load any students.xlsx file                        |
| 📊 Results table   | Beautiful card per student with all subject grades |
| 📈 Export Excel    | Download grades as .xlsx file                      |
| 📄 Export PDF      | Download grades as PDF                             |
| 📝 Export Word     | Download grades as .doc file                       |
| 🎨 Dark blue theme | Professional UI design                             |

---

## 🔧 Requirements

| Tool           | Version                               |
| -------------- | ------------------------------------- |
| Dart SDK       | 3.x or above                          |
| Flutter SDK    | 3.x or above                          |
| VS Code        | Latest with Dart & Flutter extensions |
| Android Studio | For Android builds                    |

---

## 📦 Dependencies

### Console version (`pubspec.yaml`)

```yaml
dependencies:
  excel: ^4.0.2
```

### Flutter version (`grade_calculator_app/pubspec.yaml`)

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

## 🚀 Installation

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

## 📌 Important Notes

> ⚠️ Always **close** `students.xlsx` in Excel before running the console version.
>
> The file cannot be saved if it is open elsewhere.

> ✅ The Flutter app works on **Web, Android, iOS and Desktop** from the same codebase.

---

*Generated for ICT University — Academic Year 2024/2025*
