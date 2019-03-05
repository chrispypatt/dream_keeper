import 'dart:convert';

Journal journalFromJson(String str) {
    final jsonData = json.decode(str);
    return Journal.fromMap(jsonData);
}

String journalToJson(Journal data) {
    final dyn = data.toMap();
    return json.encode(dyn);
}

class Journal {
    int id;
    DateTime datetime;
    String title;
    String journalEntry;

    Journal({
        this.id,
        this.datetime,
        this.title,
        this.journalEntry,
    });

    factory Journal.fromMap(Map<String, dynamic> json) => new Journal(
        id: json["id"],
        datetime: DateTime.parse(json["datetime"]),
        title: json["title"],
        journalEntry: json["journal_entry"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "datetime": datetime.toIso8601String(),
        "title": title,
        "journal_entry": journalEntry,
    };
}
