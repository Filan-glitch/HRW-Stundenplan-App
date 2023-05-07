import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../service/storage.dart';
import '../widgets/dialog_wrapper.dart';

class CrashlyticsDialog extends StatelessWidget {
  const CrashlyticsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: "Crash-Daten",
      children: [
        const Text(
          "Dürfen wir Daten zu Fehlern und Abstürzen an Firebase Crashlytics senden und auswerten?",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () {
                  FirebaseCrashlytics.instance
                      .setCrashlyticsCollectionEnabled(true);
                  crashlyticsDialogShown();

                  Navigator.pop(context);
                },
                child: const Text("Ja")),
            TextButton(
                onPressed: () {
                  FirebaseCrashlytics.instance
                      .setCrashlyticsCollectionEnabled(false);
                  crashlyticsDialogShown();

                  Navigator.pop(context);
                },
                child: const Text("Nein")),
          ],
        ),
        Text(
          "Deine Einstellung wird erst nach einem Neustart der App angewendet",
          style: TextStyle(
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
