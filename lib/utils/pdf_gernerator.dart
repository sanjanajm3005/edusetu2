import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_html/html.dart' as html;


class PDFGenerator {
  static Future<File?> generateNotePDF(String topic, String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: "AI Notes: $topic"),
          pw.Paragraph(text: content),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$topic.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
      return null;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$topic.pdf');
      await file.writeAsBytes(bytes);
      return file;
    }
  }
}
