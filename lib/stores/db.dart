
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dream_keeper/models/journal.dart';
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
    return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;

    
  }
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "journalDBtest1.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Journal ("
          "id INTEGER PRIMARY KEY,"
          "datetime TEXT,"
          "title TEXT,"
          "journal_entry TEXT"
          ")");
    });
  }

  newJournal(Journal newJournal) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Journal");
    newJournal.id = table.first["id"];
    var res = await db.insert("Journal", newJournal.toMap()); 
    return res;
  }

  updateJournal(Journal newJournal) async {
    final db = await database;
    var res = await db.update("Journal", newJournal.toMap(),
        where: "id = ?", whereArgs: [newJournal.id]);
    return res;
  }

  getJournal(int id) async {
    final db = await database;
    var res = await db.query("Journal", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Journal.fromMap(res.first) : null;
  }

  Future<List<Journal>> getAllJournals() async {
    final db = await database;
    var res = await db.query("Journal");
    List<Journal> list =
        res.isNotEmpty ? res.map((c) => Journal.fromMap(c)).toList() : [];
    return list;
  }

  deleteJournal(int id) async {
    final db = await database;
    return db.delete("Journal", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawQuery('DELETE * FROM "Journal"');
  }
}



