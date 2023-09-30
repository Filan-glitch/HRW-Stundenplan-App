import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:http/http.dart' as http;

class PdfWidget extends StatefulWidget {
  const PdfWidget({super.key, required this.url, required this.onError});

  final String url;
  final void Function() onError;

  @override
  State<PdfWidget> createState() => _PdfWidgetState();
}

class _PdfWidgetState extends State<PdfWidget> {
  String? _filePath;
  bool _hasError = false;
  final PdfViewerController _controller = PdfViewerController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();

    getTemporaryDirectory().then(
      (tempDir) async {
        try {
          http.Response response = await http.get(Uri.parse(widget.url));
          if (response.statusCode != 200) {
            _errorOccurred();
          }
          String path = '${tempDir.absolute.path}/food.pdf';
          File pdf = File(path);
          await pdf.writeAsBytes(response.bodyBytes);

          try {
            setState(() {
              _filePath = path;
            });
          } catch (e) {
            // page was left, before download was completed
            if (await pdf.exists()) {
              await pdf.delete();
            }
            return;
          }
        } on TimeoutException {
          _errorOccurred();
        } on SocketException {
          _errorOccurred();
        }
      },
    );
  }

  @override
  void dispose() {
    getTemporaryDirectory().then(
      (tempDir) async {
        if (_filePath != null) {
          File pdf = File(_filePath!);
          if (await pdf.exists()) {
            await pdf.delete();
          }
        }
      },
    );
    super.dispose();
  }

  void _errorOccurred() {
    setState(() {
      _hasError = true;
    });

    widget.onError();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text('Es ist ein Fehler aufgetreten.'),
      );
    }

    if (_filePath == null) {
      return Center(
        child: SizedBox(
          height: 150.0,
          width: 150.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            strokeWidth: 3.0,
          ),
        ),
      );
    }

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: () => _controller.ready?.setZoomRatio(
        zoomRatio: _controller.zoomRatio > 2.0 ? 1.0 : 2.5,
        center: _doubleTapDetails!.localPosition,
      ),
      child: PdfViewer.openFile(
        _filePath!,
        viewerController: _controller,
      ),
    );
  }
}
