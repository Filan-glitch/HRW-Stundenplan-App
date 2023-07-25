package de.janbellenberg.timetable

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(private val context: Context) : SQLiteOpenHelper(context,
    context.filesDir.parent?.plus("/databases/timetable.db"), null, 1) {
    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL("CREATE TABLE IF NOT EXISTS Grades(Identifier TEXT PRIMARY KEY, Title TEXT NOT NULL, Grade REAL, Credits_All INTEGER NOT NULL, Credits_Charged INTEGER, Status TEXT NOT NULL)")
        db?.execSQL("CREATE TABLE IF NOT EXISTS Events(EventID TEXT PRIMARY KEY, Title TEXT NOT NULL, Abbreviation TEXT, Start TEXT, End TEXT, Room TEXT, WeekFrom TEXT NOT NULL, Weekday TEXT NOT NULL)")
    }
    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
    }

    fun queryEvents(date: String, weekday: String) : MutableList<Event> {
        val db = this.readableDatabase
        val cursor = db.rawQuery("SELECT * FROM Events WHERE WeekFrom = ? AND Weekday = ?", arrayOf(date, weekday))
        val returnList: MutableList<Event> = ArrayList()
        while (cursor.moveToNext()) {
            returnList.add(
                Event(
                    cursor.getString(cursor.getColumnIndexOrThrow("Title")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Abbreviation")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Start")),
                    cursor.getString(cursor.getColumnIndexOrThrow("End")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Room"))
                ))
        }

        cursor.close()
        db.close()
        return returnList
    }
}
