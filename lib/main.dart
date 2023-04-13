import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/service/storage.dart';

import 'themes/dark.dart';
import 'home_page.dart';
import 'themes/light.dart';
import 'model/redux/app_state.dart';
import 'model/redux/store.dart';
import 'model/redux/actions.dart' as redux;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Future.wait([
    loadCredentials(),
    loadDataFromStorage(),
    loadDarkmode(),
  ]).then((value) {
    store.dispatch(redux.Action(redux.ActionTypes.setupCompleted));
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
            home: state.dataLoaded ? const HomePage() : const Scaffold(),
          );
        }),
      ),
    );
  }
}
