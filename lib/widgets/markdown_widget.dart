import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart' as renderer;
import 'package:http/http.dart' as http;

class MarkdownWidget extends StatelessWidget {
  const MarkdownWidget({
    required this.source,
    this.isUrl = false,
    super.key,
  });

  final String source;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isUrl
          ? http.get(Uri.parse(source))
          : rootBundle.loadString("assets/documents/$source"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) return Container();

          String content = isUrl
              ? (snapshot.data as http.Response).body
              : snapshot.data as String;

          return renderer.MarkdownWidget(
            data: content,
          );
        }
        return const Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
