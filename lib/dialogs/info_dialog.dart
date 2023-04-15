import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import '../widgets/dialog_wrapper.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: "Über Stundenplan",
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
          child: SizedBox(
            height: 75.0,
            child: Image.asset(
              "assets/images/icon.png",
            ),
          ),
        ),
        FutureBuilder(
          future: rootBundle.loadString("pubspec.yaml"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                'Version: ${loadYaml(
                  snapshot.data.toString(),
                )["version"].split("+")[0]}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              );
            }
            return Container();
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Jan Bellenberg",
            style: TextStyle(fontSize: 15.0),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () {
            launchUrl(Uri.parse(
                "https://gitlab.janbellenberg.de/janbellenberg/timetable"));
          },
          child: const Text("Zum Git-Repository"),
        ),
        TextButton(
          onPressed: () {
            showLicensePage(context: context);
          },
          child: const Text("Lizenzen"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text(
              "Made with",
              style: TextStyle(fontSize: 15.0),
            ),
            FlutterLogo(
              size: 80.0,
              style: FlutterLogoStyle.horizontal,
            )
          ],
        ),
      ],
    );
  }
}
