package de.janbellenberg.timetable

import com.google.firebase.crashlytics.FirebaseCrashlytics
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    init {
        if (BuildConfig.DEBUG) {
            FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(false);
        }
    }
}
