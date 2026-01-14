import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entry.dart';
import '../models/language.dart';
import '../models/rich_doc.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'dictionary.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create entries table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY,
        notes TEXT,
        is_user_added INTEGER DEFAULT 0
      )
    ''');

    // Create translations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        lang_code TEXT NOT NULL,
        word TEXT NOT NULL,
        FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE,
        UNIQUE(entry_id, lang_code)
      )
    ''');

    // Create lemma_audios table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lemma_audios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        lang_code TEXT NOT NULL,
        audio_uri TEXT NOT NULL,
        FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE,
        UNIQUE(entry_id, lang_code)
      )
    ''');

    // Create rich_docs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rich_docs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        lang_code TEXT NOT NULL,
        blocks_json TEXT NOT NULL,
        FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE,
        UNIQUE(entry_id, lang_code)
      )
    ''');

    print('Database initialized successfully');
  }

  /// Save or update an entry
  Future<void> saveEntry(Entry entry, {bool isUserAdded = true}) async {
    final db = await database;

    await db.insert(
      'entries',
      {
        'id': entry.id,
        'notes': entry.notes,
        'is_user_added': isUserAdded ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Delete existing translations
    await db.delete('translations', where: 'entry_id = ?', whereArgs: [entry.id]);

    // Insert translations
    for (final e in entry.translations.entries) {
      if (e.value.trim().isNotEmpty) {
        await db.insert('translations', {
          'entry_id': entry.id,
          'lang_code': e.key.name,
          'word': e.value,
        });
      }
    }

    // Delete existing audios
    await db.delete('lemma_audios', where: 'entry_id = ?', whereArgs: [entry.id]);

    // Insert lemma audios
    if (entry.lemmaAudios != null) {
      for (final e in entry.lemmaAudios!.entries) {
        if (e.value.trim().isNotEmpty) {
          await db.insert('lemma_audios', {
            'entry_id': entry.id,
            'lang_code': e.key.name,
            'audio_uri': e.value,
          });
        }
      }
    }
  }

  /// Load all entries
  Future<List<Entry>> loadAllEntries() async {
    final db = await database;

    final entryRows = await db.query('entries', orderBy: 'id DESC');
    final entries = <Entry>[];

    for (final row in entryRows) {
      final id = row['id'] as int;

      // Load translations
      final translationRows = await db.query(
        'translations',
        where: 'entry_id = ?',
        whereArgs: [id],
      );
      final translations = <LanguageCode, String>{};
      for (final t in translationRows) {
        final code = LanguageCode.values.firstWhere(
          (c) => c.name == t['lang_code'],
          orElse: () => LanguageCode.vi,
        );
        translations[code] = t['word'] as String;
      }

      // Load audios
      final audioRows = await db.query(
        'lemma_audios',
        where: 'entry_id = ?',
        whereArgs: [id],
      );
      final lemmaAudios = <LanguageCode, String>{};
      for (final a in audioRows) {
        final code = LanguageCode.values.firstWhere(
          (c) => c.name == a['lang_code'],
          orElse: () => LanguageCode.vi,
        );
        lemmaAudios[code] = a['audio_uri'] as String;
      }

      entries.add(Entry(
        id: id,
        translations: translations,
        lemmaAudios: lemmaAudios.isNotEmpty ? lemmaAudios : null,
        notes: row['notes'] as String?,
      ));
    }

    return entries;
  }

  /// Delete an entry
  Future<void> deleteEntry(int entryId) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [entryId]);
    await db.delete('translations', where: 'entry_id = ?', whereArgs: [entryId]);
    await db.delete('lemma_audios', where: 'entry_id = ?', whereArgs: [entryId]);
    await db.delete('rich_docs', where: 'entry_id = ?', whereArgs: [entryId]);
  }

  /// Save a rich document for an entry
  Future<void> saveRichDoc(int entryId, LanguageCode langCode, RichDoc doc) async {
    final db = await database;
    await db.insert(
      'rich_docs',
      {
        'entry_id': entryId,
        'lang_code': langCode.name,
        'blocks_json': doc.toJsonString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load all rich documents
  Future<Map<String, RichDoc>> loadAllRichDocs() async {
    final db = await database;
    final rows = await db.query('rich_docs');

    final docsMap = <String, RichDoc>{};
    for (final row in rows) {
      final key = '${row['entry_id']}:${row['lang_code']}';
      try {
        docsMap[key] = RichDoc.fromJsonString(row['blocks_json'] as String);
      } catch (e) {
        print('Failed to parse blocks_json for $key: $e');
      }
    }

    return docsMap;
  }

  /// Check if database has data
  Future<bool> hasData() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM entries');
    return (result.first['count'] as int) > 0;
  }

  /// Import base entries (skip existing)
  Future<void> importBaseEntries(List<Entry> baseEntries) async {
    final db = await database;

    for (final entry in baseEntries) {
      final existing = await db.query(
        'entries',
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      if (existing.isEmpty) {
        await saveEntry(entry, isUserAdded: false);
      }
    }

    print('Imported base entries to database (skipped existing)');
  }
}
