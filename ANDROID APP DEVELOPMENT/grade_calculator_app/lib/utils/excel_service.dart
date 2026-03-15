// ============================================================
// excel_service.dart — Excel read/write utility
// Handles uploading student Excel file and downloading result
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/calculator.dart';

class ExcelService {
  // Delayed init — decoder only created when first needed
  late final Excel _decoder;

  // ---- Upload: read student Excel file ----
  Future<List<StudentRecord>?> pickAndReadFile(
      GradeCalculator calc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
      dialogTitle: 'Select Student Marks File',
    );

    if (result == null || result.files.isEmpty) return null;

    final Uint8List? bytes = result.files.first.bytes;
    final String? path = result.files.first.path;

    Uint8List fileBytes;
    if (bytes != null) {
      fileBytes = bytes;
    } else if (path != null) {
      fileBytes = await File(path).readAsBytes();
    } else {
      return null;
    }

    // Delayed init — only now do we decode
    _decoder = Excel.decodeBytes(fileBytes);

    final List<Map<String, dynamic>> rawRows = [];

    // Read the first sheet
    final sheet = _decoder.tables[_decoder.tables.keys.first];
    if (sheet == null) return null;

    final rows = sheet.rows;
    if (rows.isEmpty) return null;

    // First row = headers — use lambda to extract
    final headers = rows.first.map((c) => c?.value?.toString() ?? '').toList();

    // Map column names to our fields (flexible header matching)
    final idCol = _findColumn(headers, ['student id', 'id', 'student_id', 'studentid']);
    final nameCol = _findColumn(headers, ['student name', 'name', 'student_name', 'studentname', 'full name']);
    final markCol = _findColumn(headers, ['exam mark', 'mark', 'marks', 'score', 'exam_mark', 'exam score']);

    // Process data rows (skip header)
    for (final row in rows.skip(1)) {
      if (row.every((c) => c == null || c.value == null)) continue;

      rawRows.add({
        'studentId': idCol >= 0 ? (row[idCol]?.value?.toString() ?? '') : '',
        'studentName': nameCol >= 0 ? (row[nameCol]?.value?.toString() ?? '') : '',
        'examMark': markCol >= 0 ? (row[markCol]?.value?.toString() ?? '0') : '0',
      });
    }

    return calc.processStudents(rawRows);
  }

  int _findColumn(List<String> headers, List<String> candidates) {
    for (int i = 0; i < headers.length; i++) {
      if (candidates.contains(headers[i].toLowerCase().trim())) return i;
    }
    return -1;
  }

  // ---- Download: write result Excel file ----
  Future<String?> downloadResults(List<StudentRecord> students, GradeCalculator calc) async {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Grade Results');
    final sheet = excel['Grade Results'];

    // ---- Style helpers (lambdas) ----
    CellStyle headerStyle() => CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#1A3A5C'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: HorizontalAlign.Center,
        );

    CellStyle passStyle() => CellStyle(
          fontColorHex: ExcelColor.fromHexString('#27AE60'),
          bold: true,
        );

    CellStyle failStyle() => CellStyle(
          fontColorHex: ExcelColor.fromHexString('#E74C3C'),
          bold: true,
        );

    // ---- Write headers ----
    final headers = ['Student ID', 'Student Name', 'Exam Mark', 'Percentage', 'Grade', 'Result'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle();
    }

    // ---- Write student rows ----
    for (int r = 0; r < students.length; r++) {
      final s = students[r];
      final rowData = [
        s.studentId,
        s.studentName,
        s.examMark.toStringAsFixed(1),
        '${s.examMark.toStringAsFixed(1)}%',
        s.grade,
        s.result,
      ];
      for (int c = 0; c < rowData.length; c++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        cell.value = TextCellValue(rowData[c]);
        if (c == 5) {
          cell.cellStyle = s.result == 'PASS' ? passStyle() : failStyle();
        }
      }
    }

    // ---- Write summary section ----
    final summaryRow = students.length + 3;
    void writeSummaryRow(int row, String label, String value) {
      final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      labelCell.value = TextCellValue(label);
      labelCell.cellStyle = CellStyle(bold: true);
      final valCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      valCell.value = TextCellValue(value);
    }

    writeSummaryRow(summaryRow, 'Total Students', students.length.toString());
    writeSummaryRow(summaryRow + 1, 'Class Average', '${calc.classAverage(students).toStringAsFixed(2)}%');
    writeSummaryRow(summaryRow + 2, 'Highest Mark', '${calc.highestMark(students).toStringAsFixed(1)}%');
    writeSummaryRow(summaryRow + 3, 'Lowest Mark', '${calc.lowestMark(students).toStringAsFixed(1)}%');
    writeSummaryRow(summaryRow + 4, 'Total Pass', calc.passCount(students).toString());
    writeSummaryRow(summaryRow + 5, 'Total Fail', calc.failCount(students).toString());

    // ---- Save file ----
    final bytes = excel.save();
    if (bytes == null) return null;

    // Let user choose where to save
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Grade Results',
      fileName: 'grade_results_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );

    if (savePath == null) {
      // Fallback to documents directory
      final dir = await getApplicationDocumentsDirectory();
      savePath = '${dir.path}/grade_results_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    }

    final file = File(savePath);
    await file.writeAsBytes(bytes, flush: true);
    return savePath;
  }
}
