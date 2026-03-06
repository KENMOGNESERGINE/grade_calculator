import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'calculator.dart';

// ════════════════════════════════════════════════════════════════
//  MAIN
// ════════════════════════════════════════════════════════════════
void main() => runApp(const GradeCalculatorApp());

class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D1B4B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const SplashScreen(),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.school,
                  size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('GRADE CALCULATOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text('ICT University — 2024/2025',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  HOME PAGE
// ════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GradeCalculator calculator = GradeCalculator();
  String status = '';
  bool   isLoading = false;

  // ── Import Excel File ─────────────────────────────────────────
  void importExcel() {
    final input = html.FileUploadInputElement()
      ..accept = '.xlsx'
      ..click();

    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file == null) return;

      setState(() { isLoading = true; status = 'Reading Excel file...'; });

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoad.listen((_) {
        try {
          final bytes  = reader.result as Uint8List;
          final excel  = Excel.decodeBytes(bytes);
          final sheet1 = excel['Scores'];
          final rows   = sheet1.rows;

          if (rows.length < 3) {
            setState(() {
              status = '❌ Excel file does not have enough rows!';
              isLoading = false;
            });
            return;
          }

          // Read subject names from Row 3 (index 2)
          List<String> subjects = [];
          final headerRow = rows[2];
          for (int col = 6; col < headerRow.length; col += 2) {
            final name = headerRow[col]?.value?.toString().trim() ?? '';
            if (name.isNotEmpty) subjects.add(name);
          }

          // Read student data starting from Row 5 (index 4)
          List<Map<String, dynamic>> rawStudents = [];
          for (int i = 4; i < rows.length; i++) {
            final row  = rows[i];
            if (row.isEmpty || row[1] == null) continue;
            final name = _cellStr(row[1]?.value);
            if (name.isEmpty) continue;

            List<double> caScores   = [];
            List<double> examScores = [];
            for (int s = 0; s < subjects.length; s++) {
              caScores.add(_cellDbl(
                  row.length > 6 + (s * 2) ? row[6 + (s * 2)]?.value : null));
              examScores.add(_cellDbl(
                  row.length > 7 + (s * 2) ? row[7 + (s * 2)]?.value : null));
            }

            rawStudents.add({
              'matricule': _cellStr(row[0]?.value),
              'name':      name,
              'surName':   _cellStr(row[2]?.value),
              'sex':       _cellStr(row[3]?.value),
              'dob':       _cellStr(row[4]?.value),
              'class':     _cellStr(row[5]?.value),
              'caScores':   caScores,
              'examScores': examScores,
            });
          }

          // Process through GradeCalculator (child class)
          calculator.processStudents(rawStudents, subjects);

          setState(() {
            isLoading = false;
            status = '✅ ${calculator.totalStudents} students loaded from ${file.name}';
          });

        } catch (e) {
          setState(() {
            status = '❌ Error reading file: $e';
            isLoading = false;
          });
        }
      });
    });
  }


  // ── Helper: cell to String ────────────────────────────────────
  String _cellStr(dynamic v) {
    if (v == null) return '';
    var s = v.toString().trim();
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    if (s.contains('T') && s.contains('-')) {
      s = s.split('T')[0];
      final p = s.split('-');
      if (p.length == 3) s = '${p[2]}/${p[1]}/${p[0]}';
    }
    return s;
  }

  // ── Helper: cell to double ────────────────────────────────────
  double _cellDbl(dynamic v) {
    if (v == null) return 0.0;
    var s = v.toString().trim();
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return double.tryParse(s) ?? 0.0;
  }


  // ════════════════════════════════════════════════════════════
  //  EXPORT — EXCEL
  // ════════════════════════════════════════════════════════════
  void exportExcel() {
    if (calculator.students.isEmpty) {
      _showError('No students to export!'); return;
    }

    var excelFile = Excel.createExcel();
    var sheet     = excelFile['Grades'];

    void wc(int col, int row, String val,
        {bool bold = false, String bg = 'FFFFFFFF', String fg = 'FF000000'}) {
      var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = TextCellValue(val);
      cell.cellStyle = CellStyle(
        bold: bold, fontSize: 11,
        backgroundColorHex: ExcelColor.fromHexString(bg),
        fontColorHex:       ExcelColor.fromHexString(fg),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign:   VerticalAlign.Center,
      );
    }

    int totalCols = 6 + (calculator.subjects.length * 2);

    // Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: totalCols - 1, rowIndex: 0),
    );
    wc(0, 0, 'STUDENT GRADE CALCULATOR — FINAL RESULTS',
        bold: true, bg: 'FF0D1B4B', fg: 'FFFFFFFF');

    // Headers
    final infoHeaders = ['Matricule','Name','Sur-Name','Sex','DOB','Class'];
    for (int c = 0; c < infoHeaders.length; c++) {
      wc(c, 1, infoHeaders[c], bold: true, bg: 'FF1565C0', fg: 'FFFFFFFF');
    }
    for (int s = 0; s < calculator.subjects.length; s++) {
      wc(6 + (s*2),   1, '${calculator.subjects[s]} Avg',
          bold: true, bg: 'FF1565C0', fg: 'FFFFFFFF');
      wc(6 + (s*2)+1, 1, '${calculator.subjects[s]} Grade',
          bold: true, bg: 'FF1565C0', fg: 'FFFFFFFF');
    }

    // Student rows
    for (int i = 0; i < calculator.students.length; i++) {
      final s = calculator.students[i];
      final r = s['subjectResults'] as List<Map<String, dynamic>>;
      final row = i + 2;
      wc(0, row, s['matricule']); wc(1, row, s['name']);
      wc(2, row, s['surName']);   wc(3, row, s['sex']);
      wc(4, row, s['dob']);       wc(5, row, s['class']);
      for (int j = 0; j < r.length; j++) {
        wc(6+(j*2),   row, '${r[j]['avg']}',   bold: true);
        wc(6+(j*2)+1, row, '${r[j]['grade']}', bold: true);
      }
    }

    // Summary
    int sum = calculator.totalStudents + 3;
    wc(0, sum, 'Total Students :', bold: true);
    wc(1, sum, '${calculator.totalStudents}', bold: true);

    final bytes = excelFile.encode();
    if (bytes != null) {
      _download(Uint8List.fromList(bytes), 'grades.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      _showSuccess('Excel downloaded!');
    }
  }


  // ════════════════════════════════════════════════════════════
  //  EXPORT — PDF
  // ════════════════════════════════════════════════════════════
  Future<void> exportPdf() async {
    if (calculator.students.isEmpty) {
      _showError('No students to export!'); return;
    }

    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      header: (_) => pw.Container(
        color: const PdfColor.fromInt(0xFF0D1B4B),
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('STUDENT GRADE CALCULATOR',
              style: pw.TextStyle(color: PdfColors.white,
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('ICT University — 2024/2025',
              style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
          ],
        ),
      ),
      build: (_) => [
        pw.SizedBox(height: 12),

        // One card per student
        ...calculator.students.map((student) {
          final results =
              student['subjectResults'] as List<Map<String, dynamic>>;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Student info bar
              pw.Container(
                color: const PdfColor.fromInt(0xFF1565C0),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '${student['name']} ${student['surName']}',
                      style: pw.TextStyle(color: PdfColors.white,
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Text(
                      'Mat: ${student['matricule']}  |  '
                      'Sex: ${student['sex']}  |  '
                      'DOB: ${student['dob']}  |  '
                      'Class: ${student['class']}',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 9),
                    ),
                  ],
                ),
              ),
              // Subject table
              pw.Table(
                border: pw.TableBorder.all(
                    color: PdfColors.blueGrey200, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF1976D2)),
                    children: ['Subject','CA /10','Exam /20','Avg /20','Grade']
                        .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(h,
                            style: pw.TextStyle(color: PdfColors.white,
                                fontSize: 9, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center),
                        )).toList(),
                  ),
                  // Collection operation — subject rows
                  ...results.asMap().entries.map((e) => pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: e.key % 2 == 0
                          ? PdfColors.white
                          : const PdfColor.fromInt(0xFFF5F9FF),
                    ),
                    children: [
                      e.value['subject'], '${e.value['ca']}',
                      '${e.value['exam']}', '${e.value['avg']}',
                      e.value['grade'],
                    ].map((val) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(val.toString(),
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center),
                    )).toList(),
                  )),
                ],
              ),
              pw.SizedBox(height: 16),
            ],
          );
        }),

        // Summary
        pw.Container(
          color: const PdfColor.fromInt(0xFFE3F2FD),
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(
            'CLASS SUMMARY — Total Students: ${calculator.totalStudents}',
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ));

    final bytes = await doc.save();
    _download(bytes, 'grades.pdf', 'application/pdf');
    _showSuccess('PDF downloaded!');
  }


  // ════════════════════════════════════════════════════════════
  //  EXPORT — WORD
  // ════════════════════════════════════════════════════════════
  void exportWord() {
    if (calculator.students.isEmpty) {
      _showError('No students to export!'); return;
    }

    final buf = StringBuffer();
    buf.write('''<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>
  body{font-family:Calibri,Arial,sans-serif;font-size:11pt;margin:2cm;}
  h1{color:#0D1B4B;font-size:18pt;text-align:center;border-bottom:3px solid #0D1B4B;padding-bottom:8px;}
  .student-header{background:#1565C0;color:white;padding:8px 12px;margin-top:20px;border-radius:4px 4px 0 0;}
  .student-name{font-size:13pt;font-weight:bold;}
  .student-info{font-size:9pt;opacity:0.85;margin-top:2px;}
  table{width:100%;border-collapse:collapse;margin-bottom:4px;}
  th{background:#1976D2;color:white;padding:7px;text-align:center;font-size:10pt;}
  td{border:1px solid #CFD8DC;padding:7px;text-align:center;font-size:10pt;}
  tr:nth-child(even){background:#F5F9FF;}
  .grade-A{color:#1B5E20;font-weight:bold;}
  .grade-B{color:#2E7D32;font-weight:bold;}
  .grade-C{color:#1565C0;font-weight:bold;}
  .grade-D{color:#E65100;font-weight:bold;}
  .grade-E{color:#BF360C;font-weight:bold;}
  .grade-F{color:#B71C1C;font-weight:bold;}
  .summary{background:#E3F2FD;border-left:4px solid #1565C0;padding:12px;margin-top:24px;font-weight:bold;}
  .footer{text-align:center;color:#90A4AE;font-size:9pt;margin-top:32px;border-top:1px solid #CFD8DC;padding-top:8px;}
</style></head><body>
<h1>&#127979; STUDENT GRADE CALCULATOR — FINAL RESULTS</h1>
<p style="text-align:center;color:#546E7A;font-size:10pt;">ICT University &nbsp;|&nbsp; Academic Year 2024/2025</p>
''');

    for (var student in calculator.students) {
      final results =
          student['subjectResults'] as List<Map<String, dynamic>>;
      buf.write('''
<div class="student-header">
  <div class="student-name">${student['name']} ${student['surName']}</div>
  <div class="student-info">
    Matricule: ${student['matricule']} &nbsp;&bull;&nbsp;
    Sex: ${student['sex']} &nbsp;&bull;&nbsp;
    DOB: ${student['dob']} &nbsp;&bull;&nbsp;
    Class: ${student['class']}
  </div>
</div>
<table>
  <tr><th>Subject</th><th>CA /10</th><th>Exam /20</th><th>Avg /20</th><th>Grade</th></tr>
''');
      for (var r in results) {
        buf.write('''
  <tr>
    <td>${r['subject']}</td>
    <td>${r['ca']}</td>
    <td>${r['exam']}</td>
    <td><b>${r['avg']}</b></td>
    <td class="grade-${r['grade']}">${r['grade']}</td>
  </tr>''');
      }
      buf.write('</table>\n');
    }

    buf.write('''
<div class="summary">&#128203; CLASS SUMMARY &nbsp;&mdash;&nbsp; Total Students: ${calculator.totalStudents}</div>
<div class="footer">Generated by Student Grade Calculator &mdash; ICT University 2024/2025</div>
</body></html>''');

    final bytes = Uint8List.fromList(buf.toString().codeUnits);
    _download(bytes, 'grades.doc', 'application/msword');
    _showSuccess('Word file downloaded!');
  }


  // ── Download helper ───────────────────────────────────────────
  void _download(Uint8List bytes, String name, String mime) {
    final blob   = html.Blob([bytes], mime);
    final url    = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', name)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3)));

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red[700]));


  // ════════════════════════════════════════════════════════════
  //  EXPORT DIALOG
  // ════════════════════════════════════════════════════════════
  void showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.download, color: Color(0xFF0D1B4B)),
          SizedBox(width: 8),
          Text('Export Results',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your export format:'),
            const SizedBox(height: 16),
            _exportBtn(Icons.table_chart, 'Excel (.xlsx)',
                Colors.green[700]!, () { Navigator.pop(context); exportExcel(); }),
            const SizedBox(height: 8),
            _exportBtn(Icons.picture_as_pdf, 'PDF',
                Colors.red[700]!, () { Navigator.pop(context); exportPdf(); }),
            const SizedBox(height: 8),
            _exportBtn(Icons.description, 'Word (.doc)',
                const Color(0xFF0D1B4B), () { Navigator.pop(context); exportWord(); }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _exportBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }


  // ════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B4B),
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.school, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Text('Student Grade Calculator',
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          if (calculator.students.isNotEmpty)
            TextButton.icon(
              onPressed: showExportDialog,
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Export',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: calculator.students.isEmpty
          ? buildWelcome()
          : buildResults(),
    );
  }


  // ── WELCOME SCREEN ────────────────────────────────────────────
  Widget buildWelcome() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B4B).withOpacity(0.07),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.upload_file,
                size: 80, color: Color(0xFF0D1B4B)),
          ),
          const SizedBox(height: 32),
          const Text('Import Your Excel File',
            style: TextStyle(fontSize: 24,
                fontWeight: FontWeight.bold, color: Color(0xFF0D1B4B))),
          const SizedBox(height: 12),
          Text(
            'Select your students.xlsx file\nto calculate and view all grades',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600],
                height: 1.6),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: importExcel,
            icon: const Icon(Icons.file_open, size: 22),
            label: const Text('Import students.xlsx',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B4B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const CircularProgressIndicator(color: Color(0xFF0D1B4B)),
          if (status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(status,
                style: TextStyle(
                  color: status.startsWith('❌')
                      ? Colors.red[700] : Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 40),
          // Info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Excel file must have:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _infoRow(Icons.check_circle, 'Sheet named "Scores"'),
                _infoRow(Icons.check_circle, 'Student info in columns A–F'),
                _infoRow(Icons.check_circle, 'Subject names in Row 3'),
                _infoRow(Icons.check_circle, 'Student data from Row 5'),
                _infoRow(Icons.check_circle, 'CA (/10) and Exam (/20) per subject'),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.green[600]),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 12)),
    ]),
  );


  // ── RESULTS SCREEN ────────────────────────────────────────────
  Widget buildResults() {
    return Column(
      children: [
        // Top stats bar
        Container(
          color: const Color(0xFF0D1B4B),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _statChip(Icons.people, '${calculator.totalStudents}', 'Students'),
              const SizedBox(width: 16),
              _statChip(Icons.menu_book,
                  '${calculator.subjects.length}', 'Subjects'),
              const Spacer(),
              // Import new file button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() { calculator.clear(); status = ''; });
                },
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                label: const Text('New File',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Student list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calculator.students.length,
            itemBuilder: (_, i) =>
                buildStudentCard(calculator.students[i], i),
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(width: 6),
      RichText(text: TextSpan(children: [
        TextSpan(text: value,
          style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 16)),
        TextSpan(text: ' $label',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
    ],
  );


  // ── STUDENT CARD ──────────────────────────────────────────────
  Widget buildStudentCard(Map<String, dynamic> student, int index) {
    final results =
        student['subjectResults'] as List<Map<String, dynamic>>;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Student header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: 20,
                  child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['name']} ${student['surName']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mat: ${student['matricule']}  •  '
                        'Sex: ${student['sex']}  •  '
                        'DOB: ${student['dob']}  •  '
                        'Class: ${student['class']}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subject table
          Padding(
            padding: const EdgeInsets.all(12),
            child: Table(
              border: TableBorder.all(
                  color: Colors.grey[200]!,
                  borderRadius: BorderRadius.circular(4)),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                      color: const Color(0xFF0D1B4B).withOpacity(0.06)),
                  children: ['Subject','CA /10','Exam /20','Avg /20','Grade']
                      .map((h) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Text(h,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF0D1B4B),
                          ),
                          textAlign: TextAlign.center),
                      )).toList(),
                ),
                // Collection operation — subject rows
                ...results.asMap().entries.map((e) => TableRow(
                  decoration: BoxDecoration(
                    color: e.key % 2 == 0
                        ? Colors.white
                        : const Color(0xFFF8FAFF),
                  ),
                  children: [
                    _td(e.value['subject'], align: TextAlign.left),
                    _td('${e.value['ca']}'),
                    _td('${e.value['exam']}'),
                    _td('${e.value['avg']}', bold: true),
                    _tdGrade(e.value['grade']),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _td(String text,
      {bool bold = false, TextAlign align = TextAlign.center}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(text,
        textAlign: align,
        style: TextStyle(fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    );

  Widget _tdGrade(String grade) {
    final colors = {
      'A': const Color(0xFF1B5E20),
      'B': const Color(0xFF2E7D32),
      'C': const Color(0xFF1565C0),
      'D': const Color(0xFFE65100),
      'E': const Color(0xFFBF360C),
      'F': const Color(0xFFB71C1C),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(grade,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors[grade] ?? Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}