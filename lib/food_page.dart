import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfPage extends StatelessWidget {
  const PdfPage({required this.url, this.title = "PDF Viewer", super.key});
  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const PDF(
        autoSpacing: false,
      ).cachedFromUrl(url),
    );
  }
}
