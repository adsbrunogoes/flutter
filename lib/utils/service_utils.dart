import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String serviceTable = "serviceTable";
final String idColumn = "idColumn";
final String titleColumn = "titleColumn";
final String checkColumn = "checkColumn";
final String idContactColumn = "idContactColumn";

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
          "$checkColumn INTEGER,"
          "$idContactColumn INTEGER"
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
        columns: [idColumn, titleColumn, checkColumn, idContactColumn],
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

  Future<List> getAllServices(int idContact) async {
    Database dbService = await db;
    List<Map> maps = await dbService.query(serviceTable,
        columns: [idColumn, titleColumn, checkColumn, idContactColumn],
        where: "$idContactColumn = ?",
        whereArgs: [idContact]);
    List<Service> listservice = List();
    for (Map m in maps) {
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
  int idContact;

  Service();

  Service.fromMap(Map map) {
    id = map[idColumn];
    title = map[titleColumn];
    check = map[checkColumn];
    idContact = map[idContactColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      titleColumn: title,
      checkColumn: check,
      idContactColumn: idContact,
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
