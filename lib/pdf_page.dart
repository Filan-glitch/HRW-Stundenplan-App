import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_render/pdf_render_widgets.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({required this.url, this.title = "PDF Viewer", super.key});
  final String url;
  final String title;

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  String? filePath;
  bool hasError = false;
  final PdfViewerController controller = PdfViewerController();
  TapDownDetails? doubleTapDetails;

  @override
  void initState() {
    super.initState();

    getTemporaryDirectory().then(
      (tempDir) async {
        try {
          http.Response response = await http.get(Uri.parse(widget.url));
          if (response.statusCode != 200) {
            setState(() {
              hasError = true;
            });
          }
          String path = '${tempDir.absolute.path}/food.pdf';
          File pdf = File(path);
          await pdf.writeAsBytes(response.bodyBytes);

          try {
            setState(() {
              filePath = path;
            });
          } catch (e) {
            // page was left, before download was completed
            pdf.delete();
            return;
          }
        } on TimeoutException {
          setState(() {
            hasError = true;
          });
        } on SocketException {
          setState(() {
            hasError = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (filePath != null) {
      getTemporaryDirectory().then(
        (tempDir) async {
          File pdf = File(filePath!);
          await pdf.delete();
        },
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      showToast("Keine Verbindung");
      Navigator.pop(context);
      return Container();
    }

    return filePath == null
        ? Container()
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: GestureDetector(
              onDoubleTapDown: (details) => doubleTapDetails = details,
              onDoubleTap: () => controller.ready?.setZoomRatio(
                zoomRatio: controller.zoomRatio * 1.5,
                center: doubleTapDetails!.localPosition,
              ),
              child: PdfViewer.openFile(
                filePath!,
                viewerController: controller,
              ),
            ),
          );
  }
}
