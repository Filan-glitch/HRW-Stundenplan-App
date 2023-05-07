package de.janbellenberg.timetable

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.widget.RemoteViews
import android.content.Context
import android.widget.RemoteViewsService
import java.time.LocalDateTime

class TimetableWidgetTodayService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        return TimetableWidgetTodayItemFactory(applicationContext, intent!!)
    }

    class TimetableWidgetTodayItemFactory(private val context: Context, intent: Intent) : RemoteViewsFactory {
        private val appWidgetId: Int
        private lateinit var timetableData: List<String>
        private var dataProvider: EventDataProvider = EventDataProvider()

        init {
            this.appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        }

        override fun onCreate() {
            val tempList = dataProvider.getTodayEvents(context).filter { Integer.parseInt(it.end.split(":")[0]) > LocalDateTime.now().hour || Integer.parseInt(it.end.split(":")[0]) == LocalDateTime.now().hour && Integer.parseInt(it.end.split(":")[1]) > LocalDateTime.now().minute }
            timetableData = tempList.map { it.toString() }
        }

        override fun onDataSetChanged() {
            val tempList = dataProvider.getTodayEvents(context).filter { Integer.parseInt(it.end.split(":")[0]) > LocalDateTime.now().hour || Integer.parseInt(it.end.split(":")[0]) == LocalDateTime.now().hour && Integer.parseInt(it.end.split(":")[1]) > LocalDateTime.now().minute }
            timetableData = tempList.map { it.toString() }
        }

        override fun onDestroy() {
            // nothing
        }

        override fun getCount(): Int {
            return timetableData.size
        }

        override fun getViewAt(position: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.timetable_widget_item)
            views.setTextViewText(R.id.timetable_widget_item_info, timetableData[position])
            return views
        }

        override fun getLoadingView(): RemoteViews? {
            return null
        }

        override fun getViewTypeCount(): Int {
            return 1
        }

        override fun getItemId(position: Int): Long {
            return position.toLong()
        }

        override fun hasStableIds(): Boolean {
            return true
        }
    }
}