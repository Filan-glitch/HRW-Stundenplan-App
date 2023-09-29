import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import '../model/constants.dart';
import '../service/db/grades.dart';
import '../service/network_fetch.dart';
import '../service/storage.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isChecked = false;

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
              Text("des Institut Informatik", style: TextStyle(fontSize: 17.0)),
            ],
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) return Colors.grey;
                  return null;
                },
              ),
              enableFeedback: (_isChecked) ? true : false,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            onPressed: (_isChecked)
                ? () async {
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
            }
                : null,
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    }),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            style: TextStyle(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.7),
                            ),
                            text: "Ich akzeptiere die "),
                        TextSpan(
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                            decoration: TextDecoration.underline,
                          ),
                          text: "Nutzungsbedingungen",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse(
                                  TERMS_URL,
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                        TextSpan(
                          style: TextStyle(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.7),
                          ),
                          text: " akzeptiert.",
                        ),
                      ]
                    ),
                  ),
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
