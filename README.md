A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.


# Student Grade Calculator

A console application built with Dart that reads student scores from an Excel file, calculates the average and grade for each subject, and writes the results automatically into a second sheet.

---

## Project Structure

```
grade_calculator/
│
├── pubspec.yaml
├── pubspec.lock
├── bin/
│    └── grade_calculator.dart
├── students.xlsx
└── test/
```

---

## How It Works

1. Opens `students.xlsx`
2. Reads all student scores from **Sheet 1 (Scores)**
3. For each student and each subject, calculates the subject average using the formula:
   ```
   Average = (CA × 0.8) + (Exam × 0.6)
   ```
4. Assigns a grade to each subject average
5. Writes all results automatically into **Sheet 2 (Grades)**
6. Displays everything in the terminal

---

## Grading Scale

| Average /20    | Grade |
| -------------- | ----- |
| 16.00 – 20.00 | A     |
| 14.00 – 15.99 | B     |
| 12.00 – 13.99 | C     |
| 10.00 – 11.99 | D     |
| 8.00  – 9.99  | E     |
| 0.00  – 7.99  | F     |

---

## Excel File Structure

### Sheet 1 — Scores (filled manually)

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths CA | Maths Exam | Geography CA | Geography Exam | ... |
| --------- | ---- | -------- | --- | --- | ----- | -------- | ---------- | ------------ | -------------- | --- |

* **CA** is marked out of **10**
* **Exam** is marked out of **20**
* Student data starts at **Row 5**
* Subject names are in **Row 3**

### Sheet 2 — Grades (filled automatically by Dart)

| Matricule | Name | Sur-Name | Sex | DOB | Class | Maths Avg | Maths Grade | Geography Avg | Geography Grade | ... |
| --------- | ---- | -------- | --- | --- | ----- | --------- | ----------- | ------------- | --------------- | --- |

* Sheet 2 is **never filled manually**
* Every run deletes old results and writes fresh ones

---

## Requirements

| Requirement | Details                                         |
| ----------- | ----------------------------------------------- |
| Dart SDK    | Version 3.x or above                            |
| VS Code     | With the Dart extension installed               |
| Excel file  | `students.xlsx`must be in the project root    |
| Internet    | Only needed the first time for `dart pub get` |

---

## Installation

1. Clone or download the project folder
2. Open the folder in **VS Code**
3. Open the terminal and run:

   ```
   dart pub get
   ```

   This downloads the `excel` package. Only needed once.

---

## How to Run

1. **Close** `students.xlsx` in Excel before running
2. Open the terminal in VS Code
3. Run the program:
   ```
   dart run
   ```
4. When finished, open `students.xlsx` and check the **Grades** sheet

> ⚠️ **Important:** Never open `students.xlsx` while the program is running. The file cannot be saved if it is open and all results will be lost.

---

## Dependencies

```yaml
dependencies:
  excel: ^4.0.2
```

---

## Author

* **Name:** Kenmogne Matchuekam Sergine
* **Course:** ICT
* **Year:** 2024 / 2025
* **Institution:** ICT University
