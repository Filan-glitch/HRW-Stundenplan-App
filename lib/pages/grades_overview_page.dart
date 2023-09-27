import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:local_auth/local_auth.dart';

import '../dialogs/confirm_refresh_dialog.dart';
import '../model/biometrics.dart';
import '../model/module.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../service/network_fetch.dart';
import '../widgets/page_wrapper.dart';
import 'login_page.dart';

class GradesOverviewPage extends StatefulWidget {
  const GradesOverviewPage({Key? key}) : super(key: key);

  @override
  State<GradesOverviewPage> createState() => _GradesOverviewPageState();
}

class _GradesOverviewPageState extends State<GradesOverviewPage> {
  @override
  void initState() {
    super.initState();

    if (store.state.biometrics == Biometrics.ONLY_EXAM_RESULTS) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setLockState,
          payload: true,
        ),
      );

      LocalAuthentication()
          .authenticate(localizedReason: 'Bitte App entsperren')
          .then((success) {
        if (success) {
          store.dispatch(redux.Action(
            redux.ActionTypes.setLockState,
            payload: false,
          ));
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (store.state.biometrics == Biometrics.ONLY_EXAM_RESULTS) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setLockState,
          payload: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      simpleDesign: true,
      title: "Prüfungsergebnisse",
      body: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                if (store.state.enableConfirmRefreshDialog) {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmRefreshDialog(),
                  );
                } else {
                  LoginPage.performLogin(onLoginSuccess: reloadAll);
                }
              },
              child: ListView.builder(
                itemCount: state.modules.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Gesamtnote: ${state.gpa.toString()}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    );
                  }

                  Module module = state.modules[index - 1];
                  if (module.status == Status.passed &&
                      module.creditsAll == 0) {
                    return Container();
                  }

                  return ListTile(
                    title: Text(
                      module.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (module.grade > 0)
                          Row(
                            children: [
                              const Text('Note: '),
                              Text(
                                module.grade.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        if (module.status != Status.open) ...[
                          if (module.creditsAll > 0)
                            Text(
                              'Mögliche Credits: ${module.creditsAll.toString()}',
                            ),
                          if (module.creditsCharged > 0)
                            Text(
                              'Angerechnete Credits: ${module.creditsCharged.toString()}',
                            ),
                        ],
                        if (module.status == Status.passed)
                          const Text(
                            'Status: Bestanden',
                            style: TextStyle(color: Colors.green),
                          ),
                        if (module.status == Status.failed)
                          const Text(
                            'Status: Durchgefallen',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (module.status == Status.open)
                          const Text(
                            'Status: Offen',
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
