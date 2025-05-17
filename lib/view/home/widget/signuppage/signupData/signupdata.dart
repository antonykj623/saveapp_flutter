import 'package:new_project_2025/view/home/widget/signuppage/signupusermodel/signupmodeluser.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final table = 'Userdettable';
  static final tableacc = 'accountstable';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('userdata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS  Userdettable (columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,username TEXT NOT NULL,email TEXT NOT NULL,mobile TEXT NOT NULL,promocode TEXT NOT NULL,confirmpassword TEXT NOT NULL,country TEXT NOT NULL,password TEXT NOT NULL,state TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS  accountstable(columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,accountname TEXT NOT NULL,catogory TEXT NOT NULL,accounttype TEXT NOT NULL,openingbalance TEXT NOT NULL,status int NOT NULL)
    ''');
  }

  Future<Users> create(Users usr) async {
    final db = await instance.database;
    final id = await db.insert('Userdettable', usr.toMap());
    return Users(
      columnid: id,
      username: usr.username,
      email: usr.email,
      mobile: usr.mobile,
      promocode: usr.promocode,
      confirmpassword: usr.confirmpassword,
      country: usr.country,
      password: usr.password,
      state: usr.state,
    );
  }

  Future<Accounts> createacc(Accounts acc) async {
    final db = await instance.database;
    final id = await db.insert('accountstable', acc.tomap());

    return Accounts(
      columnid: id,
      accountname: acc.accountname,
      catogory: acc.catogory,
      openingbalance: acc.openingbalance,
      accounttype: acc.accounttype,
      status: acc.status,
    );
  }

  Future<List<Map<String, dynamic>>> queryall() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryallacc() async {
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
    var count = await dbClient.execute(
      "ALTER TABLE $table ADD COLUMN $catogory TEXT ",
    );

    print(await dbClient.query(table));
    return count;
  }

  Future<bool> checkLogin(String email, String password) async {
    Database db = await instance.database;
    var dbClient = await db;
    var res = await dbClient.rawQuery(
      "SELECT password FROM $table WHERE email = '$email' and password = '$password'",
    );
    print("Res is: $res.");
    if (res.isNotEmpty) {
      print("output is: $res");
      return true;

      // return new User.fromMap(res.first);
    } else {
      print("Faileddd!!!!!!");
      return false;
    }
  }
  //    Future<bool> getAccountdet(String accountname, String openingbalance, String accounttype,String catogory,String year,String status) async {
  //    Database db = await instance.database;
  // var dbClient = await db;
  //           var res = await dbClient.rawQuery("SELECT accountname,accounttype,catogory,openingbalance,status,year FROM $table WHERE columid = '$id");
  // print ("Res is: $res.");
  //     if (res.isNotEmpty) {
  //    print ("output is: $res");
  // return true;

  //       // return new User.fromMap(res.first);
  //     }
  //     else{
  //   print ("Faileddd!!!!!!");
  // return false;
  //     }

  //   }

  Future<void> updatePassword(String email, String confpassword) async {
    Database db = await instance.database;
    var dbClient = await db;

    var res = await dbClient.rawUpdate(
      "update $table SET password = '$confpassword' where email = '$email'",
    );

    if (res == 1) {
      print("Res is: $res.");
      print("updatedRes is: $res.");
    } else {
      print("not updated");
    }
  }

  //     Future<void> updateaccountdet(String accountname,String catogory,String openingbalance,String accountype) async {
  //    Database db = await instance.database;
  // var dbClient = await db;

  //       // var res = await dbClient.rawUpdate("update $tableacc SET accountname = '$accountname',catogory = '$catogory',openingbalance = '$openingbalance',accountype = '$accountype' where: "id = ?",
  //       //  whereArgs: [],);

  //     //  where columid = '$id'");

  //       if(res == 1){
  //       print ("Res is: $res.");
  // print ("updatedRes is: $res.");
  //      }
  //      else{

  //        print("not updated");
  //      }

  //     }
  Future<List<Accounts>> getAllRecordsacc() async {
    var dbClient = await instance.database;
    var result = await dbClient.query("SELECT * FROM  $tableacc");
    List<Accounts> listdat =
        result.isNotEmpty
            ? result.map((c) => Accounts.fromMap(c)).toList()
            : [];
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
    // }
    //   Future<int> delete(int id) async {
    //     final db = await instance.database;

    //     return await db.delete(
    //       'Userdettable',
    //       where: 'id = ?',
    //       whereArgs: [id],
    //     );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

// // ignore: file_names
// import "dart:io";

// import "package:path/path.dart";
// import "package:sqflite/sqflite.dart";
// import "package:path_provider/path_provider.dart";
// import 'Modalclass/modal.dart';

// var _database;
// var _databaseacc;
//  final _databasename ='userdata.db';

// class Dao{
//     static Future<Database>  get database async{
//   if(_database != null)return _database;  
  
 
 
// _database = await _initDatabase();
//  return _database;  
// //The ??= operator will check if _database is null and set it to the value of await _initiateDatabase() if that is the case and then return the new value of _database. If _database already has a value, it will just be returned.
// }

// }

 
 

// class Users {


// static final columnid = "id";
// static final username = 'username';
// static final email = 'email';
// static final mobile = 'mobile';
// static final promocode = 'promocode';
// static final confirmpassword = 'confirmpassword';
// static final country = 'country';
// static final password = 'password';
// static final state = 'state';

// Users._privateConstructor();
// static final Users instance = Users._privateConstructor();
// // Future<Database> get database async{
// //   if(_database != null)return _database;  
  
 
 
// // _database = await _initDatabase();
// //  return _database;  
// // //The ??= operator will check if _database is null and set it to the value of await _initiateDatabase() if that is the case and then return the new value of _database. If _database already has a value, it will just be returned.
// // }
// }


// class Accounts {
//   static final  columnid= "columnid";
//   static final accountname = "accountname";
//  static final catogory = "catogory";
//  static final openingbalance = "openingbalance";
//   static final accounttype ="accounttype";
//   static final status = "status";
  
// Accounts._privateConstructor();
// static final Accounts instance1 = Accounts._privateConstructor();

//   // void queryallacc() {} 
// // Future<Database> get databaseacc async{
// //   if(_databaseacc != null)return _databaseacc;  
  
 
 
// // _databaseacc = await _initDatabase();
// //  return _databaseacc;  
// // //The ??= operator will check if _database is null and set it to the value of await _initiateDatabase() if that is the case and then return the new value of _database. If _database already has a value, it will just be returned.
// // }
// }

// // 
//   final table ='usertable';
//    final tableaccount ='accounttable';
//   final _databaseversion = 1;




// //static final acctable ='accountstable';
// //static var _database;
 
   
 
//   int idd = 0;

// _initDatabase() async{
  
//   Directory documentdirectory = await getApplicationCacheDirectory();
//   String path = join(documentdirectory.path,_databasename);
// return await openDatabase(path,version:_databaseversion,onCreate: _onCreate);
// }

// String createtable = "CREATE TABLE usertable (columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,username TEXT NOT NULL,email TEXT NOT NULL,mobile TEXT NOT NULL,promocode TEXT NOT NULL,confirmpassword TEXT NOT NULL,country TEXT NOT NULL,password TEXT NOT NULL,state TEXT NOT NULL)";
//  String addaccountstable = "CREATE TABLE accounttable (columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,accountname TEXT NOT NULL,accounttype TEXT NOT NULL,openingbalance TEXT NOT NULL,status int NOT NULL)";



// Future _onCreate(Database db,int version) async{
// await(db.execute(createtable));
//   await(db.execute(addaccountstable));
// }


// //Future<bool> uidExists() async {
//  // var result = await _database.rawQuery(
//   //  'SELECT EXISTS(SELECT 1 FROM tagTable WHERE uidCol="aaa")',v
//  // );
//   //int exists = Sqflite.firstIntValue(result);
//   //return exists == 1;
// //}


// // var db= DatabaseHelper();

// // Future<int> getcount(id) async {
// //       var dbclient = await db;
// //       int  count = Sqflite.firstIntValue(
// //           await dbclient.rawQuery("SELECT COUNT(*) FROM $cartTable WHERE $columnid=$id"));
// //       return count;
// //       }
// Future<int> deleteData() async{
//   Database db = await Dao.database;
// var result = await db.rawDelete("Delete from $table");
// return result;
// }
 
// //function to insert update delete query
// Future<int> insert(Map<String,dynamic> row) async{

// Database db = await Dao.database;

// return await db.insert(table,row);
 
// }
// Future<int> insertacc(Map<String,dynamic> row) async{

// Database db = await Dao.database;

// return await db.insert(tableaccount,row);
 
// }
// // Future<int> delete(Map<String,dynamic> row) async{

// // Database db = await instance.database;
// // return await db.delete("Delete * from  ");
// // Future<dynamic> alterTable(String table, String mobile) async {
// //   Database db = await instance.database;
// //   var dbClient = await db;
// //   var count = await dbClient.execute("ALTER TABLE $table ADD COLUMN $mobile TEXT");
// //   //print(await dbClient.query(TABLE_CUSTOMER));
// //   print("Altered Table!!!!");
// //   return count;
// // }
// // // insertData(table, data) async {
// // // 			var connection = await database;
// // // 			return await connection.insert(table, data);
// // // 		}
// Future<List<Map<String,dynamic>>>queryall() async{

// Database db = await Dao.database;
// return await db.query(table);

// }
//  Future<List<Map<String,dynamic>>>queryallacc() async{

// Database db = await Dao.database;
// return await db.query(tableaccount);

// }
// // Future<List<Map<String,dynamic>>>showdataa() async{

// // Database db = await instance.database;
// // return await db.query(acctable);

// // }

//    Future<List<Map<String, dynamic>>> getItems() async {
// Database db = await Dao.database;
//     return db.query('usertable', orderBy: 'id');

//   }
// Future<dynamic> alterTable(String table, String promocode ) async {
//   Database db = await Dao.database;
//   var dbClient = await db;
//   var count = await dbClient.execute("ALTER TABLE $table ADD COLUMN $promocode TEXT ");
    
//   print(await dbClient.query(table));
//   return count;
// }

// // Future<bool> uidExists(String user,String pass) async {
// //   Database db = await instance.database;
// //   var result = await db.rawQuery
// //     ("select * from usertable where username ='$user' and password = $pass ");
// //  if (result.isNotEmpty){
// //    // print("Resultdata is..:$result");

// //  }
// //   int? exists = Sqflite.firstIntValue(result);
// //   print("Resultdata is..:$result");
// //   return exists == 1;

// // }
// // Future<bool> login(username,password)async{
// //    Database db = await _initDatabase();
// //   //var result = await db.rawQuery("select * from usertable where username = $username and password = $password");
// //    var result = await db.rawQuery("select * from usertable where username =' $username' and password = $password");
// // if (result.isNotEmpty){

// // print("result.....:$result");
// //   return true;
  
// // }
// // else{
// //   return false;
// // }


// // }


//  Future<bool> checkLogin(String email, String password) async {
//    Database db = await Dao.database;
// var dbClient = await db;
//           var res = await dbClient.rawQuery("SELECT password FROM $table WHERE email = '$email' and password = '$password'");
// print ("Res is: $res.");
//     if (res.isNotEmpty) {
//    print ("output is: $res");
// return true;
    
//       // return new User.fromMap(res.first);
//     }
//     else{
//   print ("Faileddd!!!!!!");
// return false;
//     }

   
//   }
// //  Future<List<Map<String, Object?>>> getid(Map<String, dynamic> row) async {
// //     Database db = await instance.database;
// //    idd = row[columnid];
// //     return await db.query(table, where: '$columnid = ?', whereArgs: [idd]);
// //   }


//    Future<void> updatePassword(String email,String confpassword) async {
//    Database db = await Dao.database;
// var dbClient = await db;
 
//       var res = await dbClient.rawUpdate("update $table SET password = '$confpassword' where email = '$email'");
      
//       if(res == 1){
//       print ("Res is: $res.");
// print ("updatedRes is: $res.");
//      }
//      else{

//        print("not updated");
//      }
  
//     }


// //   Future<int> update(Users task, id) async {
// //        Database db = await instance.database;
// // return await db.update('userstable', task.toMap(),
// //     where: '$id = ?', whereArgs: [columnid]);}
    
// //       Map<String, Object?> toMap() {
// //         return {
// //       'columnid': columnid,
// //       'username': username,
// //       'email': email,
// //       'mobile': mobile,
// //       'confirmpassword': confirmpassword,
// //       'country': country,
// //        'password': password,
// //       'state': state,
   
// //     };
// //       }
 



// class Promocode {
//   static final columnid = "id";
 
// static String promocode1 = 'promocode1';
// static String status1 = 'status1';
 

// Promocode._privateConstructor();
 
 
// static final table1 ='promocodeTest';
// //static final _databasename ='userdata.db';
// //static var _database1;
// static final _databaseversion = 1;
// static final Promocode instance = Promocode._privateConstructor();

//   int idd = 0;
//  Future<Database> get database async{
//   if(_database != null)return _database;  
  
 
 
// //_database1 = await _initDatabase();
//  return _database;  
// //The ??= operator will check if _database is null and set it to the value of await _initiateDatabase() if that is the case and then return the new value of _database. If _database already has a value, it will just be returned.
// }
// _initDatabase() async{
  
//   Directory documentdirectory = await getApplicationCacheDirectory();
//   String path = join(documentdirectory.path,_databasename);
// return await openDatabase(path,version:_databaseversion,onCreate: _onCreate);
// }
// String ValidatePromocode = "create table promocodeTest(columnid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,promocode1 TEXT NOT NULL)";
// Future _onCreate(Database db,int version) async{
// await(db.execute(ValidatePromocode));

// }
// Future<int> insert1(Map<String,dynamic> row) async{

// Database db = await instance.database;

// return await db.insert(table1,row);

 
// }
// Future<List<Map<String,dynamic>>>ShowData() async{

// Database db = await instance.database;
// return await db.query(table1);

// }

// }