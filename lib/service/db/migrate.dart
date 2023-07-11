const dbInit = [
  'CREATE TABLE IF NOT EXISTS Grades (Identifier TEXT PRIMARY KEY, Title TEXT NOT NULL, Grade REAL, Credits_All INTEGER NOT NULL, Credits_Charged INTEGER, Status TEXT NOT NULL)',
  'CREATE TABLE IF NOT EXISTS Events (EventID TEXT PRIMARY KEY, Title TEXT NOT NULL, Abbreviation TEXT, Start TEXT, End TEXT, Room TEXT, WeekFrom TEXT NOT NULL, Weekday TEXT NOT NULL)',
];

const dbMigrate = [];
