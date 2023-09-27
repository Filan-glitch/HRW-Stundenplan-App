import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import '../model/constants.dart';
import '../service/db/grades.dart';
import '../service/network_fetch.dart';
import '../service/storage.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Column(
            children: [
              Text("Willkommen!", style: TextStyle(fontSize: 30.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("bei der ", style: TextStyle(fontSize: 20.0)),
                  Text("inoffiziellen",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ],
              ),
              Text(
                "CampusNet",
                style: TextStyle(
                  fontSize: 32.0,
                ),
              ),
              Text("Stundenplan App", style: TextStyle(fontSize: 22.0)),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              LoginPage.performLogin(onLoginSuccess: () async {
                await loadWeekInterval();
                await fetchGradeData().then((_) {
                  writeGradesToStorage();
                  writeGPA();
                });
                await fetchAccountData().then((_) {
                  writeAccount();
                });
              });
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward),
                Padding(
                  padding: EdgeInsets.all(
                    10.0,
                  ),
                  child: Text("CampusNet Login"),
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      PRIVACY_URL,
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Theme.of(context).dividerColor.withOpacity(0.7),
                    ),
                    const Text("  Datenschutz"),
                  ],
                ),
              )
            ],
          ),
          FutureBuilder(
            future: rootBundle.loadString("pubspec.yaml"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'Version: ${loadYaml(
                    snapshot.data.toString(),
                  )["version"].split("+").first}',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context).dividerColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
