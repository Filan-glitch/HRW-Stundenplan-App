import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timetable/service/storage.dart';
import 'package:yaml/yaml.dart';

import 'login_page.dart';
import 'model/redux/store.dart';
import 'model/redux/actions.dart' as redux;
import 'privacy_page.dart';
import 'service/network_fetch.dart';
import 'widgets/page_wrapper.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageWrapper(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: const [
                Text("Willkommen!", style: TextStyle(fontSize: 30.0)),
                Text("bei der inoffiziellen", style: TextStyle(fontSize: 20.0)),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onLoginSuccessful: (args, cnsc) async {
                        Navigator.pop(context);
                        store.dispatch(redux.Action(
                          redux.ActionTypes.setCredentials,
                          payload: {"cnsc": cnsc, "args": args},
                        ));
                        await writeCredentialsToStorage();

                        loadWeekInterval();
                      },
                      onFailure: () {
                        Navigator.pop(context);
                        showToast("Es ist ein Fehler aufgetreten");
                      },
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.black54,
                      ),
                      Text("  Datenschutz"),
                    ],
                  ),
                ),
                const Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      "Mit Nutzung dieser App akzeptieren Sie, dass etwaige Fehlermeldungen an Firebase Crashlytics gesendet werden.",
                    ),
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
                    )["version"].split("+")[0]}',
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
