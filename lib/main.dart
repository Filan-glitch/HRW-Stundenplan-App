import 'dart:developer';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timetable/service/storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
  ).then((value) {
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

    Future.wait([
      loadCredentials(),
      loadDataFromStorage(),
      loadDarkmode(),
    ]).then((value) {
      store.dispatch(redux.Action(redux.ActionTypes.setupCompleted));
    });
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, AppState>(
        converter: ((store) => store.state),
        builder: ((context, state) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: lightTheme.colorScheme.primary,
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

          return MaterialApp(
            title: 'Stundenplan',
            theme: lightTheme,
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            themeMode: state.darkmode ? ThemeMode.dark : ThemeMode.light,
            supportedLocales: const [Locale("de", "DE")],
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: OKToast(
              child: state.dataLoaded ? const HomePage() : const Scaffold(),
              position: ToastPosition.bottom,
            ),
          );
        }),
      ),
    );
  }
}
