package de.janbellenberg.timetable

class Event(
    val title: String,
    val abbreviation: String,
    val start: String,
    val end: String,
    val room: String

) {
    override fun toString(): String {
        val timespan: String = "${formatTime(start)} - ${formatTime(end)}";
        if (abbreviation == "") return "$title\n $timespan\n $room"
        return "$abbreviation\n $timespan\n $room"
    }

    fun formatTime(date: String): String {
        val hours: String = date.split(":")[0].padStart(2, '0')
        val minutes: String = date.split(":")[1].padStart(2, '0')

        return "$hours:$minutes"
    }
}
