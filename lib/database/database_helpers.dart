import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// data model class
class Highscore {
  int id;
  int highscore;
  String quizType;

  Highscore({
    this.id,
    this.highscore,
    this.quizType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'highscore': highscore,
      'quizType': quizType,
    };
  }
}

// database helper
class DatabaseHelper {
  static final _databaseName = "highscores.db";
  // increment this version when changing schema
  static final _databaseVersion = 2;

  static final table = 'highscores';

  static final id = 'id';
  static final highscore = 'highscore';
  static final quizType = 'quizType';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create db table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $highscore INTEGER NOT NULL,
            $quizType TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Highscore highscore) async {
    Database db = await instance.database;
    var res = await db.insert(table, highscore.toMap());
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table, orderBy: 'id DESC');
    return res;
  }
}
