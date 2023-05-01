import 'package:flutter/material.dart';

import 'widgets/markdown_widget.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datenschutz"),
      ),
      body: const MarkdownWidget(
        source: "privacy.md",
      ),
    );
  }
}
