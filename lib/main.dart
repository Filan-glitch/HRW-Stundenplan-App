import 'dart:developer';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:local_auth/local_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/firebase_api.dart';
import 'dialogs/crashlytics_dialog.dart';
import 'firebase_options.dart';

import 'loading_page.dart';
import 'model/biometrics.dart';
import 'service/db/events.dart';
import 'service/db/grades.dart';
import 'service/storage.dart';
import 'service/update.dart';
import 'themes/dark.dart';
import 'home_page.dart';
import 'themes/light.dart';
import 'model/redux/app_state.dart';
import 'model/redux/store.dart';
import 'model/redux/actions.dart' as redux;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) async {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    if (!kDebugMode) {
      FlutterError.onError = (errorDetails) {
        try {
          showToast("Unbekannter Fehler");
        } catch (e) {
          log(e.toString());
        }
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        try {
          showToast("Unbekannter Fehler");
        } catch (e) {
          log(e.toString());
        }
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
    await FirebaseApi().initNotifications();

    await loadBiometrics();
    if (store.state.biometrics == Biometrics.ON) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setLockState,
          payload: true,
        ),
      );
    }

    Future.wait([
      loadCredentials(),
      loadDataFromStorage().then((_) async {
        await loadGradesFromStorage();
      }),
      loadGPA(),
      loadDesign(),
      loadCampus(),
    ]).then((value) {
      store.dispatch(redux.Action(redux.ActionTypes.setupCompleted));
    });
    shouldShowChangelogIcon();
  });

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static bool dialogShown = false;

  @override
  Widget build(BuildContext context) {
    if (!dialogShown) {
      dialogShown = true;
      didShowCrashlyticsDialog().then((value) {
        if (!value) {
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => const CrashlyticsDialog(),
          );
        }
      });
    }

    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, AppState>(
        converter: ((store) => store.state),
        builder: ((context, state) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: state.darkmode
                  ? darkTheme.colorScheme.primary
                  : lightTheme.colorScheme.primary,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: state.darkmode
                  ? darkTheme.colorScheme.background
                  : lightTheme.colorScheme.background,
              systemNavigationBarIconBrightness:
                  state.darkmode ? Brightness.light : Brightness.dark,
            ),
          );

          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

          if (state.appLocked && state.biometrics == Biometrics.ON) {
            LocalAuthentication()
                .authenticate(
              localizedReason: 'Bitte App entsperren',
            )
                .then((success) {
              if (success) {
                store.dispatch(redux.Action(
                  redux.ActionTypes.setLockState,
                  payload: false,
                ));
              }
            });
          }

          return MaterialApp(
            title: 'Stundenplan',
            theme: lightTheme,
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            themeMode: state.darkmode ? ThemeMode.dark : ThemeMode.light,
            supportedLocales: const [Locale("de", "DE")],
            navigatorKey: navigatorKey,
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: OKToast(
              position: ToastPosition.bottom,
              child: state.dataLoaded
                  ? const HomePage()
                  : const Scaffold(body: LoadingPage()),
            ),
          );
        }),
      ),
    );
  }
}
