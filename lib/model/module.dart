class Module implements Comparable<Module> {
  String identifier;
  String title;
  double grade;
  int creditsAll;
  int creditsCharged;
  Status status;

  Module({
    this.identifier = "",
    this.title = "",
    this.grade = 0,
    this.creditsAll = 0,
    this.creditsCharged = 0,
    this.status = Status.open,
  });

  Module.fromDB(Map<String, dynamic> item)
      : identifier = item['Identifier'] ?? "",
        title = item['Title'] ?? "",
        grade = item['Grade'] ?? 0,
        creditsAll = item['Credits_All'] ?? 0,
        creditsCharged = item['Credits_Charged'] ?? 0,
        status = Status.getByText(item["Status"] ?? "Offen");

  Map<String, dynamic> toDB() {
    return {
      "Identifier": identifier,
      "Title": title,
      "Grade": grade,
      "Credits_All": creditsAll,
      "Credits_Charged": creditsCharged,
      "Status": status.text
    };
  }

  @override
  int compareTo(Module other) {
    return grade.compareTo(other.grade);
  }
}

enum Status {
  passed("Bestanden"),
  failed("Durchgefallen"),
  open("Offen");

  const Status(this.text);
  final String text;

  static Status getByText(String text) {
    if (text.contains("Bestanden")) {
      return Status.passed;
    } else if (text.contains("Durchgefallen")) {
      return Status.failed;
    } else {
      return Status.open;
    }
  }
}
