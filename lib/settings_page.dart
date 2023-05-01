import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/dialogs/changelog_dialog.dart';
import 'package:timetable/privacy_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import 'model/redux/app_state.dart';
import 'model/redux/actions.dart' as redux;
import 'model/redux/store.dart';
import 'service/storage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (context, state) {
                  return ListTile(
                    leading: const Icon(
                      Icons.lightbulb,
                    ),
                    title: state.darkmode
                        ? const Text("Helles Design")
                        : const Text("Dunkles Design"),
                    onTap: () {
                      store.dispatch(
                        redux.Action(
                          redux.ActionTypes.setDarkmode,
                          payload: !state.darkmode,
                        ),
                      );
                      writeDarkmodeToStorage();
                    },
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Divider(
                  color: Color.fromARGB(255, 117, 117, 117),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text("Was ist neu?"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangelogDialog(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text("Lizenzen"),
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text("Quellcode"),
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      "https://gitlab.janbellenberg.de/janbellenberg/timetable",
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text("Feedback"),
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      "https://docs.google.com/forms/d/e/1FAIpQLSd6d3cobkONv1Rq94OpSGmQNv0WWu51b3ZOyV5Yv02q4BPNwQ/viewform",
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text("Datenschutz"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPage(),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Divider(
                  color: Color.fromARGB(255, 117, 117, 117),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red.withOpacity(0.7)),
                title: const Text("Abmelden"),
                onTap: () {
                  Navigator.pop(context);
                  clearStorage();
                  store.dispatch(redux.Action(redux.ActionTypes.clear));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
