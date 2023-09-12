import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mutex/mutex.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timetable/dialogs/changelog_dialog.dart';
import 'package:timetable/model/biometrics.dart';
import 'package:timetable/service/background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import 'dialogs/crashlytics_dialog.dart';
import 'dialogs/select_campus_dialog.dart';
import 'dialogs/select_default_view.dart';
import 'dialogs/select_lock_dialog.dart';
import 'login_page.dart';
import 'model/constants.dart';
import 'model/redux/actions.dart' as redux;
import 'model/redux/app_state.dart';
import 'model/redux/store.dart';
import 'service/db/events.dart';
import 'service/db/grades.dart';
import 'service/network_fetch.dart';
import 'service/storage.dart';
import 'widgets/page_wrapper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final m = Mutex();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return PageWrapper(
            simpleDesign: true,
            title: "Einstellungen",
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
                        "Jan Bellenberg\nFinn Dilan",
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListTile(
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
                        writeDesign();
                      },
                    ),
                    ListTile(
                        leading: const Icon(
                          Icons.download,
                        ),
                        title: const Text("Daten aktualisieren"),
                        onTap: () {
                          _isLoading = false;
                          LoginPage.performLogin(onLoginSuccess: _loadData);
                        }),
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(
                        "Campus: ${state.campus.text}",
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SelectCampusDialog(),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.view_comfortable_rounded),
                      title: Text(
                        "Startansicht: ${state.defaultView.text}",
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SelectDefaultViewDialog(),
                        );
                      },
                    ),
                    if (Platform.isAndroid)
                      ListTile(
                        leading: const Icon(
                          Icons.lightbulb,
                        ),
                        title: state.notificationsEnabled
                            ? const Text("Benachrichtigungen: aktiviert")
                            : const Text("Benachrichtigungen: deaktiviert"),
                        onTap: () {
                          bool newValue = !state.notificationsEnabled;

                          if (newValue) {
                            registerBackgroundService();
                            showToast(
                              "Aufgrund von Batterie-Optimierung werden Benachrichtigungen ggf. nicht immer korrekt angezeigt.",
                              duration: const Duration(seconds: 5),
                            );
                          } else {
                            unregisterBackgroundService();
                          }

                          store.dispatch(
                            redux.Action(
                              redux.ActionTypes.setNotificationsEnabled,
                              payload: newValue,
                            ),
                          );
                          writeNotificationsEnabled();
                        },
                      ),
                    FutureBuilder(
                      future: DisableBatteryOptimization
                          .isBatteryOptimizationDisabled,
                      builder: (context, snapshot) {
                        if (snapshot.data == false && Platform.isAndroid) {
                          return ListTile(
                            leading: const Icon(Icons.battery_alert),
                            title: const Text("Akku-Optimierung deaktivieren"),
                            onTap: () {
                              DisableBatteryOptimization
                                  .showDisableBatteryOptimizationSettings();
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    FutureBuilder(
                      future: Future.wait([
                        LocalAuthentication().canCheckBiometrics,
                        LocalAuthentication().isDeviceSupported(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.data?[0] == true &&
                            snapshot.data?[1] == true) {
                          return ListTile(
                            leading: const Icon(Icons.security),
                            title: Row(
                              children: [
                                const Text(
                                  "Biometrie: ",
                                ),
                                if (state.biometrics == Biometrics.OFF)
                                  const Text("Nicht aktiv"),
                                if (state.biometrics == Biometrics.ON)
                                  const Text("Aktiv"),
                                if (state.biometrics ==
                                    Biometrics.ONLY_EXAM_RESULTS)
                                  const Text("Nur Prüfungsergebnisse"),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const SelectLockDialog(),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.report,
                      ),
                      title: const Text("Crashlytics-Zustimmung"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CrashlyticsDialog(),
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
                      leading: const Icon(Icons.badge),
                      title: const Text("Offizielles CampusNet"),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            CAMPUS_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text("Was ist neu?"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ChangelogDialog(),
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
                      leading: const Icon(Icons.local_police),
                      title: const Text("Disclaimer"),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            DISCLAIMER_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text("Datenschutz"),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            PRIVACY_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text("Quellcode"),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            SOURCE_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text("Feedback"),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            FEEDBACK_URL,
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
                      leading: Icon(Icons.logout,
                          color: Colors.red.withOpacity(0.7)),
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
        });
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    _isLoading = true;
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    await m.acquire();
    try {
      List<Future> futures = store.state.events.keys
          .map((week) => fetchTimetableData(formatter.parse(week)))
          .toList();
      futures.add(fetchGradeData());
      await Future.wait(futures);

      await writeDataToStorage();
      await writeGradesToStorage();
      await writeGPA();
    } finally {
      m.release();
    }
  }
}
