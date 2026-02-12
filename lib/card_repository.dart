import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CardRepository {
  static final CardRepository instance = CardRepository._();
  CardRepository._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pokecard.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            setName TEXT NOT NULL,
            number TEXT NOT NULL,
            rarity TEXT NOT NULL,
            owned INTEGER NOT NULL,
            accent INTEGER NOT NULL,
            imagePath TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE cards ADD COLUMN accent INTEGER NOT NULL DEFAULT 0xFF101828',
          );
        }
      },
    );
  }

  Future<List<CardItem>> getAll() async {
    final db = await database;
    final rows = await db.query('cards', orderBy: 'id DESC');
    return rows.map(CardItem.fromMap).toList();
  }

  Future<int> insert(CardItem item) async {
    final db = await database;
    return db.insert('cards', item.toMap());
  }

  Future<int> update(CardItem item) async {
    final db = await database;
    return db.update(
      'cards',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}

class CardItem {
  const CardItem({
    this.id,
    required this.name,
    required this.setName,
    required this.number,
    required this.rarity,
    required this.owned,
    required this.accent,
    required this.imagePath,
  });

  final int? id;
  final String name;
  final String setName;
  final String number;
  final String rarity;
  final bool owned;
  final int accent;
  final String? imagePath;

  CardItem copyWith({
    int? id,
    String? name,
    String? setName,
    String? number,
    String? rarity,
    bool? owned,
    int? accent,
    String? imagePath,
  }) {
    return CardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      setName: setName ?? this.setName,
      number: number ?? this.number,
      rarity: rarity ?? this.rarity,
      owned: owned ?? this.owned,
      accent: accent ?? this.accent,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'setName': setName,
      'number': number,
      'rarity': rarity,
      'owned': owned ? 1 : 0,
      'accent': accent,
      'imagePath': imagePath,
    };
  }

  static CardItem fromMap(Map<String, Object?> map) {
    return CardItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      setName: map['setName'] as String,
      number: map['number'] as String,
      rarity: map['rarity'] as String,
      owned: (map['owned'] as int) == 1,
      accent: map['accent'] as int,
      imagePath: map['imagePath'] as String?,
    );
  }
}
