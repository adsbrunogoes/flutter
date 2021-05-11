import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String serviceTable = "serviceTable";
final String idColumn = "idColumn";
final String titleColumn = "titleColumn";
final String checkColumn = "checkColumn";

class ServicesUtils {
  static final ServicesUtils _instance = ServicesUtils.internal();

  factory ServicesUtils() => _instance;

  ServicesUtils.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "services.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $serviceTable("
          "$idColumn INTEGER PRIMARY KEY,"
          "$titleColumn TEXT,"
          "$checkColumn INTEGER"
          ")");
    });
  }

  Future<Service> saveService(Service service) async {
    Database dbService = await db;
    service.id = await dbService.insert(serviceTable, service.toMap());
    return service;
  }

  Future<Service> getService(int id) async {
    Database dbService = await db;
    List<Map> maps = await dbService.query(serviceTable,
        columns: [idColumn, titleColumn, checkColumn],
        where: "$id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Service.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteService(int id) async {
    Database dbService = await db;
    return await dbService
        .delete(serviceTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateService(Service service) async {
    Database dbService = await db;
    return await dbService.update(serviceTable, service.toMap(),
        where: "$idColumn = ?", whereArgs: [service.id]);
  }

  Future<List> getAllServices() async {
    Database dbService = await db;
    List listMap = await dbService.rawQuery("SELECT * FROM $serviceTable");
    List<Service> listservice = List();
    for (Map m in listMap) {
      listservice.add(Service.fromMap(m));
    }
    return listservice;
  }

  Future<int> getNumber() async {
    Database dbService = await db;
    return Sqflite.firstIntValue(
        await dbService.rawQuery("SELECT COUNT(*) FROM $serviceTable"));
  }

  Future close() async {
    Database dbService = await db;
    dbService.close();
  }
}

class Service {
  int id;
  String title;
  int check;

  Service();

  Service.fromMap(Map map) {
    id = map[idColumn];
    title = map[titleColumn];
    check = map[checkColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      titleColumn: title,
      checkColumn: check,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "service(id: $id, title: $title, check: $check)";
  }
}

