import 'package:flutter/material.dart';
import 'package:timetable/service/storage.dart';

import 'dialogs/info_dialog.dart';
import 'login_page.dart';
import 'model/redux/store.dart';
import 'model/redux/actions.dart' as redux;
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
                    builder: (context) =>
                        LoginPage(onLoginSuccessful: (args, cnsc) async {
                      Navigator.pop(context);
                      store.dispatch(redux.Action(
                        redux.ActionTypes.setCredentials,
                        payload: {"cnsc": cnsc, "args": args},
                      ));
                      await writeCredentialsToStorage();

                      loadFourWeekInterval();
                    }, onFailure: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Es ist ein Fehler aufgetreten!"),
                      ));
                    }),
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
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const InfoDialog(),
                  barrierColor: Colors.transparent,
                );
              },
              child: const Text("Über die App"),
            ),
          ],
        ),
      ),
    );
  }
}
