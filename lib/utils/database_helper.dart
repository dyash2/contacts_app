import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        phone       TEXT    NOT NULL,
        email       TEXT,
        address     TEXT,
        company     TEXT,
        notes       TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        avatar_color TEXT
      )
    ''');
  }

  //  CRUD

  Future<int> insertContact(Contact contact) async {
    final db = await database;
    final map = contact.toMap()..remove('id');
    return await db.insert(
      'contacts',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Contact.fromMap).toList();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final rows = await db.query(
      'contacts',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Contact.fromMap).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final rows = await db.query(
      'contacts',
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Contact.fromMap).toList();
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(int id, bool currentValue) async {
    final db = await database;
    return await db.update(
      'contacts',
      {'is_favorite': currentValue ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isDuplicate(String name, String phone, {int? excludeId}) async {
    final db = await database;
    final where = excludeId != null
        ? 'name = ? AND phone = ? AND id != ?'
        : 'name = ? AND phone = ?';
    final args = excludeId != null
        ? [name.trim(), phone.trim(), excludeId]
        : [name.trim(), phone.trim()];

    final rows = await db.query(
      'contacts',
      columns: ['id'],
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
