package de.janbellenberg.timetable

import com.google.firebase.crashlytics.FirebaseCrashlytics
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    init {
        if (BuildConfig.DEBUG) {
            FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(false);
        }
    }
}
