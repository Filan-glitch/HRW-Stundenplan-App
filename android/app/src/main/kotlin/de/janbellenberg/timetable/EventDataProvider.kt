package de.janbellenberg.timetable

import android.content.Context
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.format.DateTimeFormatter


class EventDataProvider {
    private fun getEvents(context: Context, date: String, weekday: String): MutableList<Event> {
        val dbHelper = DatabaseHelper(context)
        return dbHelper.queryEvents(date, weekday)
    }

    fun getTodayEvents(context: Context): List<Event> {
        val today = LocalDate.now()
        val monday = today.with(DayOfWeek.MONDAY)
        val date = monday.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))

        return getEvents(context, date, (today.dayOfWeek.value - 1).toString())
    }

    fun getTomorrowEvents(context: Context): List<Event> {
        val tomorrow = LocalDate.now().plusDays(1)
        val monday = tomorrow.with(DayOfWeek.MONDAY)
        val date = monday.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))

        return getEvents(context, date, (tomorrow.dayOfWeek.value - 1).toString())
    }
}
