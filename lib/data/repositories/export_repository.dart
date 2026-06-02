// lib/data/repositories/export_repository.dart
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../local/isar/schemas/schemas.dart';
import '../../presentation/providers/all_providers.dart';

class ExportRepository {
  // Run PDF generation in an isolate to avoid jank.
  static Future<Uint8List> generateProgressReport({
    required String name,
    required String targetExam,
    required DateTime examDate,
    required List<ChapterSchema> chapters,
    required List<StudyLogSchema> logs,
    required DashboardSummary summary,
  }) async {
    return compute(
      _buildPdf,
      _PdfParams(
        name: name,
        targetExam: targetExam,
        examDate: examDate,
        chapters: chapters,
        logs: logs,
        summary: summary,
      ),
    );
  }

  static Future<Uint8List> _buildPdf(_PdfParams p) async {
    final pdf = pw.Document(
      title: 'PrepSarthi Progress Report',
      author: 'PrepSarthi AI',
    );

    final subjectNames =
        p.chapters.map((c) => c.subjectName).toSet().toList()..sort();

    final stats = <String, _SubStat>{};
    for (final subject in subjectNames) {
      final subjectChapters =
          p.chapters.where((c) => c.subjectName == subject).toList();
      final learned = subjectChapters
          .where((c) =>
              c.status == 'learned' ||
              c.status == 'revised' ||
              c.status == 'tested')
          .length;
      final loggedHours = p.logs
          .where((l) => l.subjectName == subject)
          .fold(0.0, (sum, log) => sum + log.hoursStudied);
      final estimatedHours =
          subjectChapters.fold(0.0, (sum, c) => sum + c.estimatedHours);
      final spentHours =
          subjectChapters.fold(0.0, (sum, c) => sum + c.hoursSpent);

      stats[subject] = _SubStat(
        name: subject,
        total: subjectChapters.length,
        learned: learned,
        estH: estimatedHours,
        spentH: spentHours,
        loggedH: loggedHours,
        progress: estimatedHours > 0
            ? (spentHours / estimatedHours).clamp(0.0, 1.0)
            : 0.0,
      );
    }

    final teal = PdfColor.fromHex('#00C4B4');
    final green = PdfColor.fromHex('#4CAF50');
    final dark = PdfColor.fromHex('#1A202C');
    final muted = PdfColor.fromHex('#718096');
    final lightGrey = PdfColor.fromHex('#F8F9FA');
    final white70 = PdfColor.fromHex('#B3FFFFFF');
    final white38 = PdfColor.fromHex('#61FFFFFF');
    final tableHeader = PdfColor.fromHex('#F0FDF4');

    PdfColor subjectColor(String subject) {
      switch (subject) {
        case 'Physics':
          return PdfColor.fromHex('#6C63FF');
        case 'Chemistry':
          return PdfColor.fromHex('#FF6B6B');
        case 'Mathematics':
          return PdfColor.fromHex('#00C4B4');
        default:
          return PdfColor.fromHex('#4CAF50');
      }
    }

    final overallPct = (p.summary.overallProgress * 100).round();
    final totalHours =
        p.logs.fold<double>(0.0, (sum, log) => sum + log.hoursStudied);
    final daysLeft = p.examDate.difference(DateTime.now()).inDays;
    final dateStr =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [teal, green],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PrepSarthi',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'AI Study Planner - Progress Report',
                          style: pw.TextStyle(color: white70, fontSize: 11),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          dateStr,
                          style: pw.TextStyle(color: white70, fontSize: 10),
                        ),
                        pw.Text(
                          '$daysLeft days to exam',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                pw.Divider(color: white38, thickness: 0.5),
                pw.SizedBox(height: 14),
                pw.Text(
                  p.name,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  p.targetExam.replaceAll('_', ' ').toUpperCase(),
                  style: pw.TextStyle(color: white70, fontSize: 12),
                ),
                pw.SizedBox(height: 18),
                pw.Row(
                  children: [
                    _pStat('$overallPct%', 'Syllabus Done', white70),
                    _pStat('${totalHours.round()}h', 'Hours Logged', white70),
                    _pStat('${p.summary.streak}', 'Day Streak', white70),
                    _pStat(
                      '${p.summary.completedChapters}/${p.summary.totalChapters}',
                      'Chapters',
                      white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Overall Syllabus Progress',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Stack(
            children: [
              pw.Container(
                height: 16,
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
              ),
              pw.Container(
                height: 16,
                width: (p.summary.overallProgress * 500).clamp(0, 500),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(colors: [teal, green]),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
              ),
              pw.Positioned(
                right: 8,
                top: 2,
                child: pw.Text(
                  '$overallPct%',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: overallPct > 15 ? PdfColors.white : dark,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Subject Breakdown',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#E2E8F0'),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: tableHeader),
                children: ['Subject', 'Chapters', 'Learned', 'Hours', 'Progress']
                    .map((heading) => _pCell(heading, bold: true))
                    .toList(),
              ),
              ...stats.values.map(
                (stat) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: pw.BoxDecoration(
                              color: subjectColor(stat.name),
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text(
                            stat.name,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: subjectColor(stat.name),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _pCell('${stat.total}'),
                    _pCell('${stat.learned}'),
                    _pCell('${stat.loggedH.toStringAsFixed(1)}h'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                '${(stat.progress * 100).round()}%',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: subjectColor(stat.name),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Stack(
                            children: [
                              pw.Container(
                                height: 5,
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#E2E8F0'),
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                              ),
                              pw.Container(
                                height: 5,
                                width: (stat.progress * 100).clamp(0, 100),
                                decoration: pw.BoxDecoration(
                                  color: subjectColor(stat.name),
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Most Studied Chapters',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
          ),
          pw.SizedBox(height: 8),
          ...((p.chapters.where((c) => c.hoursSpent > 0).toList()
                ..sort((a, b) => b.hoursSpent.compareTo(a.hoursSpent)))
              .take(8)
              .map(
                (chapter) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 7,
                        height: 7,
                        decoration: pw.BoxDecoration(
                          color: subjectColor(chapter.subjectName),
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          chapter.name,
                          style: pw.TextStyle(fontSize: 11, color: dark),
                        ),
                      ),
                      pw.Text(
                        chapter.subjectName,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: subjectColor(chapter.subjectName),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        '${chapter.hoursSpent.toStringAsFixed(1)}h',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      _statusBadge(chapter.status),
                    ],
                  ),
                ),
              )),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0FFF4'),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: green, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Keep Going, ${p.name}!',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: green,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  _motivationalMessage(overallPct, p.summary.streak),
                  style: pw.TextStyle(fontSize: 10, color: dark, lineSpacing: 4),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by PrepSarthi AI',
                style: pw.TextStyle(fontSize: 9, color: muted),
              ),
              pw.Text(
                'prepsarthi.app',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: teal,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pStat(String value, String label, PdfColor mutedWhite) =>
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, color: mutedWhite),
            ),
          ],
        ),
      );

  static pw.Widget _pCell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : null,
            color: bold
                ? PdfColor.fromHex('#2D3748')
                : PdfColor.fromHex('#4A5568'),
          ),
        ),
      );

  static pw.Widget _statusBadge(String status) {
    final (label, color) = switch (status) {
      'learned' => ('Learned', PdfColor.fromHex('#4CAF50')),
      'revised' => ('Revised', PdfColor.fromHex('#2196F3')),
      'tested' => ('Tested', PdfColor.fromHex('#FF9800')),
      _ => ('Progress', PdfColor.fromHex('#94A3B8')),
    };

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.15),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static String _motivationalMessage(int pct, int streak) {
    if (pct >= 80) {
      return 'Outstanding! You are in the top tier of aspirants who actually '
          'complete their syllabus. One final push and you will conquer your '
          'exam.';
    }
    if (pct >= 50) {
      return 'Over halfway through the syllabus and building momentum. Your '
          '$streak-day streak shows real discipline. Focus on the remaining '
          'high-weightage chapters.';
    }
    if (pct >= 25) {
      return 'Great start! You are building the foundation for your success. '
          'Stay consistent and let the progress compound.';
    }
    return 'The journey of a thousand miles begins with a single step, and '
        'you have already taken it. Every session logged compounds into your '
        'final rank.';
  }
}

class _PdfParams {
  final String name;
  final String targetExam;
  final DateTime examDate;
  final List<ChapterSchema> chapters;
  final List<StudyLogSchema> logs;
  final DashboardSummary summary;

  const _PdfParams({
    required this.name,
    required this.targetExam,
    required this.examDate,
    required this.chapters,
    required this.logs,
    required this.summary,
  });
}

class _SubStat {
  final String name;
  final int total;
  final int learned;
  final double estH;
  final double spentH;
  final double loggedH;
  final double progress;

  const _SubStat({
    required this.name,
    required this.total,
    required this.learned,
    required this.estH,
    required this.spentH,
    required this.loggedH,
    required this.progress,
  });
}
