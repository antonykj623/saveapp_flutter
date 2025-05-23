
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/user_model.dart';

// import 'package:sqliteproj/AccountSetup/addaccountdetails.dart';
// import 'package:sqliteproj/Modalclass/modal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final table ='Userdettable';
  static final tableacc ='accountstable';




  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('userdata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
    CREATE TABLE IF NOT EXISTS  Userdettable (columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,username TEXT NOT NULL,email TEXT NOT NULL,mobile TEXT NOT NULL,promocode TEXT NOT NULL,confirmpassword TEXT NOT NULL,country TEXT NOT NULL,password TEXT NOT NULL,state TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS  accountstable(columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,accountname TEXT NOT NULL,catogory TEXT NOT NULL,accounttype TEXT NOT NULL,openingbalance TEXT NOT NULL,year Text NOT NULL)
    ''');
  }


  Future<Users> create(Users usr) async {
    final db = await instance.database;
    final id = await db.insert('Userdettable', usr.toMap());
    return Users(columnid: id,
        username: usr.username,
        email: usr.email,
        mobile: usr.mobile,
        promocode: usr.promocode,
        confirmpassword: usr.confirmpassword,
        country: usr.country,
        password: usr.password,
        state: usr.state);

  }

  Future<Accounts> createacc(Accounts acc) async {
    final db = await instance.database;
    final id = await db.insert('accountstable', acc.tomap());

    return Accounts(columnid: id,
      accountname: acc.accountname,
      catogory: acc.catogory,
      openingbalance: acc.openingbalance,
      accounttype: acc.accounttype,
      accyear: acc.accyear,

    );
  }


  Future<List<Map<String,dynamic>>>queryall() async{

    Database db = await instance.database;
    return await db.query(table);

  }

  Future<List<Map<String,dynamic>>>queryallacc() async{

    Database db = await instance.database;
    var res = await db.query(tableacc);

    var s = res.toList();
    print("queryallacc datas are: $s");

    return s;



  }

  Future<List<Accounts>> getItems() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableacc);
    return List.generate(maps.length, (i) {
      return Accounts.fromMap(maps[i]);
    });
  }

  //  Future<List<Accounts>> getAllaccountsdata() async {
  //   Database db = await instance.database;
  //     List<Map<String, dynamic>> allRows = await db.query('tableacc');
  // List<Accounts> accdet =
  //   allRows.map((c) => Accounts.fromMap(c)).toList();
  //   return accdet;

  //  }
  //  return List.generate(maps.length, (i) {
  //     return Todo(
  //       id: maps[i]['id'],
  //       name: maps[i]['name'],
  //       description: maps[i]['description'],
  //     );
  //   });
  // }
  Future<dynamic> alterTable(String table, String catogory) async {
    Database db = await instance.database;
    var dbClient = await db;
    var count = await dbClient.execute("ALTER TABLE $table ADD COLUMN $catogory TEXT ");

    print(await dbClient.query(table));
    return count;
  }
  Future<dynamic> alterTableacc(String accountstable, String year) async {
    Database db = await instance.database;
    var dbClient = await db;
    var count = await dbClient.execute("ALTER TABLE $accountstable ADD COLUMN $year TEXT ");

    print(await dbClient.query(table));
    return count;
  }

  Future<bool> checkLogin(String email, String password) async {
    Database db = await instance.database;
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT password FROM $table WHERE email = '$email' and password = '$password'");
    print ("Res is: $res.");
    if (res.isNotEmpty) {
      print ("output is: $res");
      return true;

      // return new User.fromMap(res.first);
    }
    else{
      print ("Faileddd!!!!!!");
      return false;
    }


  }
  Future<bool> getAccountdet(String accountname, String openingbalance, String accounttype,String catogory,String year) async {
    Database db = await instance.database;
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT accountname,accounttype,catogory,openingbalance,year FROM $table");
    print ("Res is: $res.");
    if (res.isNotEmpty) {
      print ("output is: $res");
      return true;

      // return new User.fromMap(res.first);
    }
    else{
      print ("Faileddd!!!!!!");
      return false;
    }


  }


  Future<void> updatePassword(String email,String confpassword) async {
    Database db = await instance.database;
    var dbClient = await db;

    var res = await dbClient.rawUpdate("update $table SET password = '$confpassword' where email = '$email'");

    if(res == 1){
      print ("Res is: $res.");
      print ("updatedRes is: $res.");
    }
    else{

      print("not updated");
    }

  }

  Future<void> updateaccountdet(String accountname,String catogory,String openingbalance,String accountype,int year) async {
    Database db = await instance.database;
    var dbClient = await db;

    var res = await dbClient.rawUpdate("update $tableacc SET accountname = '$accountname',catogory = '$catogory',openingbalance = '$openingbalance',accountype = '$accountype',year = '$year' where columnid = '1'");




    if(res == 1){
      print ("Res is: $res.");
      print ("updatedRes is: $res.");
    }
    else{

      print("not updated");
    }

  }
  Future<List<Accounts>> getAllRecordsacc() async {
    var dbClient = await instance.database;
    var result = await dbClient.query("SELECT * FROM  $tableacc");
    List<Accounts> listdat = result.isNotEmpty? result.map((c)=>Accounts.fromMap(c)).toList():[];
    return listdat;


    // return result;

  }
  // Future<int> update(Users usrr) async {
  //   final db = await instance.database;

  //   return db.roq(
  //     'Userdettable',
  //     usrr.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [usrr.columnid],
  //   );
  // }

  Future<int> deleteData() async {
    Database db = await instance.database;
    var result = await db.rawDelete("Delete from $table");
    return result;
  }
  Future close() async {
    final db = await instance.database;

    db.close();
  }

Future<int> deleteaccData() async {
  Database db = await instance.database;
  var result = await db.rawDelete("Delete from $tableacc");
  return result;
}
// Future close() async {
//   final db = await instance.database;
//
//   db.close();
// }
}
