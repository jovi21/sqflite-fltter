import 'package:sqflite/sqflite.dart';

abstract class TableElement{
  int id;
  final String nombre;
  TableElement(this.id, this.nombre);
  void createTable(Database db);
  Map<String, dynamic> toMap();
}

class Nombre extends TableElement{
  static final String TABLE_NAME = "nombre";
  String title;
  
  Nombre({this.title, id}):super(id, TABLE_NAME);
  factory Nombre.fromMap(Map<String, dynamic> map){
    return Nombre(title: map["title"], id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    db.rawQuery("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, title varchar(30))");
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"title": this.title};
    if(this.id != null){
      map["_id"]= id;
    }

    return map;
  }
}

final String DB_FILE_NAME = "crud.db";

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database _database;

  Future<Database> get db async {
    if(_database != null){
      return _database;
    }

    _database = await open();

    return _database;
  }

  Future<Database> open() async {
    try{
      String databasesPath = await getDatabasesPath();
      String path = "$databasesPath/$DB_FILE_NAME";
      var db = await openDatabase(path,
                version: 1,
                onCreate: (Database database, int version) async{
                  new Nombre().createTable(database);
                });
      return db;
    }catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<List<Nombre>> getList() async {
    Database dbData = await db;

    List<Map> maps = await dbData.query(Nombre.TABLE_NAME,
        columns: ["_id", "title"]);

    return maps.map((i) => new Nombre.fromMap(i)).toList();
  }

  Future<TableElement> insert(TableElement element) async {
    var dbData = await db;
    element.id = await dbData.insert(element.nombre, element.toMap());
    print("new Id ${element.id}");
    return element;
  }

  Future<int> delete(TableElement element) async{
    var dbData = await db;

    return await dbData.delete(element.nombre, where: '_id = ?', whereArgs: [element.id]);
  }

  Future<int> update(TableElement element) async{
    var dbData = await db;

    return await dbData.update(element.nombre, element.toMap(), where: '_id = ?', whereArgs: [element.id]);
  }

}
