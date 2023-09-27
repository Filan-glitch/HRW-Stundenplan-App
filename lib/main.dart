import 'dart:developer';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:local_auth/local_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:workmanager/workmanager.dart';

import 'dialogs/crashlytics_dialog.dart';
import 'firebase_options.dart';
import 'model/biometrics.dart';
import 'model/redux/actions.dart' as redux;
import 'model/redux/app_state.dart';
import 'model/redux/store.dart';
import 'pages/home_page.dart';
import 'pages/loading_page.dart';
import 'service/background.dart';
import 'service/db/events.dart';
import 'service/db/grades.dart';
import 'service/storage.dart';
import 'service/update.dart';
import 'themes/dark.dart';
import 'themes/light.dart';

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

    await loadBiometrics();
    if (store.state.biometrics == Biometrics.ON) {
      store.dispatch(
        redux.Action(
          redux.ActionTypes.setLockState,
          payload: true,
        ),
      );
    }

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    Future.wait([
      loadCredentials(),
      loadDataFromStorage().then((_) async {
        await loadGradesFromStorage();
      }),
      loadGPA(),
      loadDesign(),
      loadCampus(),
      loadNotificationsEnabled(),
      loadDefaultView(),
      loadAccount(),
      loadLastUpdated(),
      loadEnableConfirmRefreshDialog(),
    ]).then((value) {
      store.dispatch(redux.Action(redux.ActionTypes.setupCompleted));

      if (store.state.notificationsEnabled) registerBackgroundService();
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
              statusBarColor: state.effectiveTheme == ThemeMode.dark
                  ? darkTheme.colorScheme.primary
                  : lightTheme.colorScheme.primary,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: state.effectiveTheme == ThemeMode.dark
                  ? darkTheme.colorScheme.background
                  : lightTheme.colorScheme.background,
              systemNavigationBarIconBrightness:
                  state.effectiveTheme == ThemeMode.dark
                      ? Brightness.light
                      : Brightness.dark,
            ),
          );

          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);

          if (state.appLocked && state.biometrics == Biometrics.ON) {
            Future.wait([LocalAuthentication().stopAuthentication()]);
            LocalAuthentication()
                .authenticate(
              localizedReason: 'Bitte App entsperren',
              options: const AuthenticationOptions(
                stickyAuth: true,
                sensitiveTransaction: false,
                biometricOnly: true,
                useErrorDialogs: false,
              ),
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
            themeMode: state.activeTheme,
            debugShowCheckedModeBanner: false,
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
