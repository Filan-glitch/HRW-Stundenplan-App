package de.janbellenberg.timetable

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.time.LocalDateTime

/**
 * Implementation of App Widget functionality.
 */
class TimetableAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    //Initialaizing the list view
    val todayServiceIntent = Intent(context, TimetableWidgetTodayService::class.java)
    todayServiceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    todayServiceIntent.data = Uri.parse(todayServiceIntent.toUri(Intent.URI_INTENT_SCHEME))

    val tomorrowServiceIntent = Intent(context, TimetableWidgetTomorrowService::class.java)
    tomorrowServiceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    tomorrowServiceIntent.data = Uri.parse(tomorrowServiceIntent.toUri(Intent.URI_INTENT_SCHEME))

    // Set the data of list view
    val views = RemoteViews(context.packageName, R.layout.timetable_app_widget)
    views.setTextViewText(R.id.last_update_text, "Stand: " + LocalDateTime.now().hour.toString().padStart(2, '0') + ":" + LocalDateTime.now().minute.toString().padStart(2, '0'))
    views.setRemoteAdapter(R.id.today_list_view, todayServiceIntent)
    views.setEmptyView(R.id.today_list_view, R.id.today_empty)

    views.setRemoteAdapter(R.id.tomorrow_list_view, tomorrowServiceIntent)
    views.setEmptyView(R.id.tomorrow_list_view, R.id.tomorrow_empty)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)

    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.today_list_view)
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.tomorrow_list_view)
}