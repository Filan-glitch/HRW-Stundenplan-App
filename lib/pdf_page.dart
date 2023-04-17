import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

class PdfPage extends StatelessWidget {
  PdfPage({required this.url, this.title = "PDF Viewer", super.key}) {
    _controller = PdfControllerPinch(
      document: PdfDocument.openData(InternetFile.get(url)),
    );
  }
  final String url;
  final String title;
  late final PdfControllerPinch _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PdfViewPinch(
        controller: _controller,
      ),
    );
  }
}
