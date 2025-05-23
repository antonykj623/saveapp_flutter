class Users {


  final int? columnid;
  final String username ;
  final String email;
  final String mobile ;
  final String promocode;
  final String confirmpassword;
  final String country;
  final String password;
  final String state;


  Users({this.columnid, required this.username, required this.email,required this.mobile, required this.promocode,required this.confirmpassword,required this.country, required this.password,required this.state});

  Map<String, dynamic> toMap() {
    return {
      'columnid': columnid,
      'username': username,
      'email': email,
      'mobile': mobile,
      'promocode': promocode,
      'confirmpassword': confirmpassword,
      'country': country,
      'password': password,
      'state': state,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {

    return Users(
      columnid: map['columnid'],
      username: map['username'],
      email: map['email'],
      mobile: map['mobile'],
      promocode: map['promocode'],
      confirmpassword: map['confirmpassword'],
      country: map['country'],
      password: map['password'],
      state: map['state'],

    );
  }
}


class Accounts {


  int? columnid;
  String? accountname;
  String? catogory;
  String? openingbalance;
  String? accounttype;
  String? accyear;

  Accounts({this.columnid,this.accountname,this.catogory,this.openingbalance,this.accounttype,this.accyear});




  Accounts.fromMap(dynamic obj){
    columnid = obj['columnid'];
    accountname = obj['accountname'];
    catogory = obj['catogory'];
    openingbalance = obj['openingbalance'];
    accounttype = obj['accounttype'];
    accyear = obj['accyear'];

  }



  Map<String, dynamic> tomap() {
    final Map<String, dynamic> data = <String, dynamic>{
      'columnid':columnid,
      'accountname':accountname,
      'catogory':catogory,
      'openingbalance':openingbalance,
      'accounttype':accounttype,
      'accyear':accyear,
    };
    return data;
  }





}