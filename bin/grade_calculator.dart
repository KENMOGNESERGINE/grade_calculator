import 'dart:io';
import 'package:excel/excel.dart';

class GradeCalculator {

  String filePath;
  GradeCalculator(this.filePath);


  // ──────────────────────────────────────────────────────────────
  //  SECTION A — GRADE LOGIC METHODS
  // ──────────────────────────────────────────────────────────────

  // Returns a grade letter based on the average
  String getGrade(double average) {
    if (average >= 16) return 'A';
    if (average >= 14) return 'B';
    if (average >= 12) return 'C';
    if (average >= 10) return 'D';
    if (average >= 8)  return 'E';
    return 'F';
  }

  // Calculates subject average from CA (/10) and Exam (/20)
  // Formula: (CA x 0.8) + (Exam x 0.6)
  double calculateSubjectAverage(double ca, double exam) {
    if (ca   > 10) ca   = 10;
    if (exam > 20) exam = 20;
    return double.parse(
      ((ca * 0.8) + (exam * 0.6)).toStringAsFixed(2)
    );
  }


  // ──────────────────────────────────────────────────────────────
  //  SECTION B — HELPER METHODS
  // ──────────────────────────────────────────────────────────────

  // Converts any Excel cell value to a clean String
  String cellToString(dynamic cellValue) {
    if (cellValue == null) return '';
    var raw = cellValue.toString().trim();
    if (raw.endsWith('.0')) raw = raw.substring(0, raw.length - 2);
    if (raw.contains('T') && raw.contains('-')) {
      raw = raw.split('T')[0];
      var parts = raw.split('-');
      if (parts.length == 3) raw = '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return raw;
  }

  // Converts any Excel cell value to a double number
  double cellToDouble(dynamic cellValue) {
    if (cellValue == null) return 0.0;
    var raw = cellValue.toString().trim();
    if (raw.endsWith('.0')) raw = raw.substring(0, raw.length - 2);
    return double.tryParse(raw) ?? 0.0;
  }

  // Writes a value into a cell with font size 12
  void writeCell(
    Sheet sheet,
    int col,
    int row,
    String value, {
    String bgColor   = 'FFFFFFFF',
    String fontColor = 'FF000000',
    bool   bold      = false,
  }) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = TextCellValue(value.isEmpty ? ' ' : value);
    cell.cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(bgColor),
      fontColorHex:       ExcelColor.fromHexString(fontColor),
      bold:               bold,
      fontSize:           12,
      horizontalAlign:    HorizontalAlign.Center,
      verticalAlign:      VerticalAlign.Center,
    );
  }


  // ──────────────────────────────────────────────────────────────
  //  SECTION C — SHEET 2 HEADER BUILDER
  //  Builds headers dynamically based on number of subjects
  //  Returns totalCols so summary knows how wide to merge
  //  ✅ Final Average column REMOVED
  // ──────────────────────────────────────────────────────────────

  int buildSheet2Headers(Sheet sheet2, List<String> subjects) {

    // Fixed info column widths
    sheet2.setColumnWidth(0, 14);  // Matricule
    sheet2.setColumnWidth(1, 16);  // Name
    sheet2.setColumnWidth(2, 16);  // Sur-Name
    sheet2.setColumnWidth(3, 8);   // Sex
    sheet2.setColumnWidth(4, 14);  // DOB
    sheet2.setColumnWidth(5, 10);  // Class

    // Subject column widths — 2 per subject (Avg then Grade)
    for (int s = 0; s < subjects.length; s++) {
      sheet2.setColumnWidth(6 + (s * 2),     14);  // Avg
      sheet2.setColumnWidth(6 + (s * 2) + 1, 10);  // Grade
    }

    // Total columns — last subject grade column + 1
    int totalCols = 6 + (subjects.length * 2);

    // Row 0 — Title merged across ALL columns
    sheet2.merge(
      CellIndex.indexByColumnRow(columnIndex: 0,             rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: totalCols - 1, rowIndex: 0),
    );
    writeCell(sheet2, 0, 0, 'SHEET 2 — FINAL RESULTS', bold: true);

    // Row 1 — Basic info headers merged across rows 1 and 2
    List<String> infoHeaders = [
      'Matricule', 'Name', 'Sur-Name', 'Sex', 'DOB', 'Class'
    ];
    for (int c = 0; c < infoHeaders.length; c++) {
      sheet2.merge(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 2),
      );
      writeCell(sheet2, c, 1, infoHeaders[c], bold: true);
    }

    // Row 1 — Subject group headers merged across 2 columns each
    for (int s = 0; s < subjects.length; s++) {
      int avgCol   = 6 + (s * 2);
      int gradeCol = 6 + (s * 2) + 1;
      sheet2.merge(
        CellIndex.indexByColumnRow(columnIndex: avgCol,   rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: gradeCol, rowIndex: 1),
      );
      writeCell(sheet2, avgCol, 1, subjects[s], bold: true);
    }

    // Row 2 — Sub-headers under each subject
    for (int s = 0; s < subjects.length; s++) {
      int avgCol   = 6 + (s * 2);
      int gradeCol = 6 + (s * 2) + 1;
      writeCell(sheet2, avgCol,   2, 'Avg /20', bold: true);
      writeCell(sheet2, gradeCol, 2, 'Grade',   bold: true);
    }

    return totalCols;
  }


  // ──────────────────────────────────────────────────────────────
  //  SECTION D — SUMMARY WRITER
  //  Writes the class summary at the bottom of Sheet 2
  // ──────────────────────────────────────────────────────────────

  void writeSummary(Sheet sheet2, int totalStudents, int totalCols) {
    int summaryStart = totalStudents + 5;

    // Summary title merged across ALL columns
    sheet2.merge(
      CellIndex.indexByColumnRow(columnIndex: 0,             rowIndex: summaryStart),
      CellIndex.indexByColumnRow(columnIndex: totalCols - 1, rowIndex: summaryStart),
    );
    writeCell(sheet2, 0, summaryStart, 'CLASS SUMMARY', bold: true);

    // Total students row
    writeCell(sheet2, 0, summaryStart + 1, 'Total Students :', bold: true);
    writeCell(sheet2, 1, summaryStart + 1, '$totalStudents',   bold: true);
  }


  // ──────────────────────────────────────────────────────────────
  //  SECTION E — MAIN RUN METHOD
  //  Controls everything from start to finish
  //  ✅ Final Average calculation and writing REMOVED
  // ──────────────────────────────────────────────────────────────

  void run() {

    print('');
    print('============================================');
    print('   GRADE CALCULATOR — Starting...          ');
    print('============================================');
    print('');

    // Open the Excel file
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    print('✅ Excel file opened: $filePath');

    // Get Sheet 1
    var sheet1 = excel['Scores'];
    print('✅ Sheet 1 (Scores) loaded');

    // Reset Sheet 2 — delete and create fresh empty one
    excel.delete('Grades');
    var sheet2 = excel['Grades'];
    print('✅ Sheet 2 (Grades) reset — fresh and empty');
    print('');

    // Read subject names from Row 3 (index 2 in Dart)
    List<String> subjects = [];
    var headerRow = sheet1.rows[2];
    for (int col = 6; col < headerRow.length; col += 2) {
      var subjectName = headerRow[col]?.value?.toString().trim() ?? '';
      if (subjectName.isNotEmpty) subjects.add(subjectName);
    }

    print('📚 Subjects found (${subjects.length}):');
    for (var s in subjects) { print('   - $s'); }
    print('');

    // Build Sheet 2 headers — returns total column count
    int totalCols = buildSheet2Headers(sheet2, subjects);

    // Print Sheet 1 in terminal
    print('📋 SHEET 1 — STUDENT SCORES:');
    print('─────────────────────────────────────────────────────');

    int studentCount = 0;
    for (int i = 4; i < sheet1.rows.length; i++) {
      var row = sheet1.rows[i];
      if (row.isEmpty || row[1] == null) continue;
      var name = cellToString(row[1]?.value);
      if (name.isEmpty) continue;
      studentCount++;
      print('$studentCount. [${cellToString(row[0]?.value)}] '
            '$name ${cellToString(row[2]?.value)} | '
            'Sex: ${cellToString(row[3]?.value)} | '
            'DOB: ${cellToString(row[4]?.value)} | '
            'Class: ${cellToString(row[5]?.value)}');
    }
    print('─────────────────────────────────────────────────────');
    print('Total students: $studentCount');
    print('');

    // Calculate grades and write to Sheet 2
    print('⚙️  Calculating grades...');
    print('');
    print('📊 SHEET 2 — FINAL RESULTS:');
    print('─────────────────────────────────────────────────────');

    int totalStudents = 0;

    for (int i = 4; i < sheet1.rows.length; i++) {
      var row = sheet1.rows[i];
      if (row.isEmpty || row[1] == null) continue;
      var name = cellToString(row[1]?.value);
      if (name.isEmpty) continue;

      // Read student basic information
      var matricule = row.length > 0 ? cellToString(row[0]?.value) : '';
      var surName   = row.length > 2 ? cellToString(row[2]?.value) : '';
      var sex       = row.length > 3 ? cellToString(row[3]?.value) : '';
      var dob       = row.length > 4 ? cellToString(row[4]?.value) : '';
      var classe    = row.length > 5 ? cellToString(row[5]?.value) : '';

      // Calculate avg and grade for EACH subject
      List<Map<String, dynamic>> subjectResults = [];

      for (int s = 0; s < subjects.length; s++) {
        int caCol   = 6 + (s * 2);
        int examCol = 6 + (s * 2) + 1;

        var ca   = caCol   < row.length ? cellToDouble(row[caCol]?.value)   : 0.0;
        var exam = examCol < row.length ? cellToDouble(row[examCol]?.value) : 0.0;

        var subjectAvg   = calculateSubjectAverage(ca, exam);
        var subjectGrade = getGrade(subjectAvg);

        subjectResults.add({'avg': subjectAvg, 'grade': subjectGrade});
      }

      totalStudents++;

      // Print in terminal — each subject avg and grade
      print('$totalStudents. $name $surName');
      for (int s = 0; s < subjects.length; s++) {
        print('   ${subjects[s]}: ${subjectResults[s]['avg']}/20 — ${subjectResults[s]['grade']}');
      }
      print('');

      // Write to Sheet 2
      // Row 0 = title, Row 1 = subject headers
      // Row 2 = sub-headers, Row 3+ = student data
      int writeRow = totalStudents + 2;

      // Write basic student info
      writeCell(sheet2, 0, writeRow, matricule.isEmpty ? '-' : matricule);
      writeCell(sheet2, 1, writeRow, name.isEmpty      ? '-' : name);
      writeCell(sheet2, 2, writeRow, surName.isEmpty   ? '-' : surName);
      writeCell(sheet2, 3, writeRow, sex.isEmpty       ? '-' : sex);
      writeCell(sheet2, 4, writeRow, dob.isEmpty       ? '-' : dob);
      writeCell(sheet2, 5, writeRow, classe.isEmpty    ? '-' : classe);

      // Write each subject average and grade
      for (int s = 0; s < subjectResults.length; s++) {
        int avgCol   = 6 + (s * 2);
        int gradeCol = 6 + (s * 2) + 1;
        writeCell(sheet2, avgCol,   writeRow, '${subjectResults[s]['avg']}',   bold: true);
        writeCell(sheet2, gradeCol, writeRow, '${subjectResults[s]['grade']}', bold: true);
      }
    }

    print('─────────────────────────────────────────────────────');
    print('');
    print('📊 SUMMARY:');
    print('   Total students : $totalStudents');
    print('');

    // Write summary to Sheet 2
    writeSummary(sheet2, totalStudents, totalCols);

    // Save the Excel file
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath).writeAsBytesSync(fileBytes);
      print('✅ File saved!');
      print('✅ Open students.xlsx → check the GRADES sheet');
    } else {
      print('❌ Error: Could not save the file.');
    }

    print('');
    print('============================================');
    print('   Program finished!                       ');
    print('============================================');
  }

} // ← class ends here


// ════════════════════════════════════════════════════════════════
//  MAIN — where the program starts
// ════════════════════════════════════════════════════════════════
void main() {
  GradeCalculator calculator = GradeCalculator('students.xlsx');
  calculator.run();
}