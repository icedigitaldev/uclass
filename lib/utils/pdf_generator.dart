import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../utils/logger.dart';

class PdfGenerator {
  Future<String> generatePdf({
    required Map<String, dynamic> studentData,
    required Map<String, dynamic> teacherData,
    String? courseName,
    String? teacherName,
  }) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    try {
      final evaluationData = _processScores(studentData['scores']);

      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
            italic: ttf,
            boldItalic: ttf,
          ),
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              pw.SizedBox(height: 20),
              _buildStudentInfo(studentData),
              pw.SizedBox(height: 20),
              _buildTeacherInfo(teacherData),
              pw.SizedBox(height: 20),
              _buildEvaluationTable(evaluationData),
              pw.SizedBox(height: 20),
              _buildSummary(evaluationData),
              pw.Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      );

      final String fileName = 'reporte_${studentData['fullName']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final bytes = await pdf.save();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        return fileName;
      } else {
        final String filePath = await _getFilePath(fileName, courseName, teacherName);
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      }

    } catch (e) {
      AppLogger.log('Error generando PDF: $e', prefix: 'PDF_GENERATOR:');
      throw Exception('Error al generar el PDF');
    }
  }

  List<Map<String, dynamic>> _processScores(Map<String, dynamic>? scores) {
    if (scores == null) return [];
    List<Map<String, dynamic>> evaluationData = [];
    scores.forEach((key, value) {
      String date = value['date'] ?? '';
      value.forEach((criterionKey, criterionValue) {
        if (criterionKey != 'date') {
          evaluationData.add({
            'date': date,
            'criterion': _formatCriterion(criterionKey),
            'score': criterionValue,
          });
        }
      });
    });
    return evaluationData;
  }

  String _formatCriterion(String criterion) {
    return criterion.toString()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  pw.Widget _buildTitle() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Center(
        child: pw.Text(
          'REPORTE DE EVALUACIÓN\n${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildStudentInfo(Map<String, dynamic> studentData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('INFORMACIÓN DEL ESTUDIANTE',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 8),
          _buildInfoRow('Nombre:', studentData['fullName']),
          _buildInfoRow('Código:', studentData['studentId']),
          _buildInfoRow('Área:', studentData['designatedArea']),
          _buildInfoRow('Lugar:', studentData['internshipLocation']),
        ],
      ),
    );
  }

  pw.Widget _buildTeacherInfo(Map<String, dynamic> teacherData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('INFORMACIÓN DEL DOCENTE',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 8),
          _buildInfoRow('Nombre:', teacherData['nombre']),
          _buildInfoRow('DNI:', teacherData['dni']),
          _buildInfoRow('Email:', teacherData['email']),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 12, color: PdfColors.blue800)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEvaluationTable(List<Map<String, dynamic>> evaluationData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(5)),
            ),
            child: pw.Text('EVALUACIÓN DE DESEMPEÑO',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          ),
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: pw.BorderSide(color: PdfColors.blue200),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              _buildTableHeader(),
              ...evaluationData.map((item) => _buildTableRow(item)),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildTableHeader() {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: ['Fecha', 'Criterio', 'Puntaje'].map((text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      )).toList(),
    );
  }

  pw.TableRow _buildTableRow(Map<String, dynamic> item) {
    return pw.TableRow(
      children: [
        item['date'],
        item['criterion'],
        item['score'].toString(),
      ].map((text) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 12),
          textAlign: pw.TextAlign.center,
        ),
      )).toList(),
    );
  }

  pw.Widget _buildSummary(List<Map<String, dynamic>> evaluationData) {
    if (evaluationData.isEmpty) return pw.Container();

    final totalScore = evaluationData.fold<int>(0, (sum, item) => sum + (item['score'] as int));
    final average100 = evaluationData.isEmpty ? 0.0 : totalScore / evaluationData.length;
    final average20 = average100 * 0.2;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('RESUMEN DE CALIFICACIONES',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 8),
          _buildInfoRow('Total:', totalScore.toString()),
          _buildInfoRow('Promedio (100):', average100.toStringAsFixed(1)),
          _buildInfoRow('Promedio (20):', average20.toStringAsFixed(2)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.blue200)),
      ),
      child: pw.Center(
        child: pw.Text(
          'Documento generado automáticamente',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.blue800,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Future<String> _getFilePath(String fileName, String? courseName, String? teacherName) async {
    if (kIsWeb) return fileName;

    String basePath = '/storage/emulated/0/Documents/uclass';

    if (courseName != null) {
      basePath = '$basePath/$courseName';
      if (teacherName != null) {
        basePath = '$basePath/$teacherName';
      }
    }

    Directory directory = Directory(basePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return '${directory.path}/$fileName';
  }
}