package de.janbellenberg.timetable

import android.content.Context
import android.content.SharedPreferences
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import org.json.JSONArray
import org.json.JSONObject

class EventDataProvider {
    private fun getEvents(context: Context, date: String): MutableList<Event> {
        val returnList: MutableList<Event> = ArrayList()

        try {
            val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val unparsedJSONArray = prefs.getString(date, "")!!.toString()
            val parsedJSONArray = JSONArray(unparsedJSONArray)

            for (i in 0 until parsedJSONArray.length() - 1) {
                val event: JSONObject = parsedJSONArray.getJSONObject(i)

                val eventObject = Event(
                        event.getString("title"),
                        if (event.has("abbreviation")) event.getString("abbreviation") else "",
                        event.getString("start"),
                        event.getString("end"),
                        event.getString("room"),
                        event.getInt("weekday")
                )
                returnList.add(eventObject)
            }
        } catch (_: Throwable) {
        }

        return returnList
    }

    fun getTodayEvents(context: Context): List<Event> {
        val today = LocalDate.now()
        val monday = today.with(DayOfWeek.MONDAY)
        val date = monday.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
        val list = getEvents(context, "flutter.$date")

        //filter list for this weekday
        return list.filter { it.day == today.dayOfWeek.value - 1 }
    }

    fun getTomorrowEvents(context: Context): List<Event> {
        val tomorrow = LocalDate.now().plusDays(1)
        val monday = tomorrow.with(DayOfWeek.MONDAY)
        val date = monday.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
        val list = getEvents(context, "flutter.$date")

        //filter list for next weekday
        return list.filter { it.day == tomorrow.dayOfWeek.value - 1 }
    }
}
