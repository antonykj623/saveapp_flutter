import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/Modules/accounts/addaccount.dart';
import '../../app/Modules/accounts/editaccountdetails.dart';
import '../../app/Modules/accounts/global.dart' as global;
import '../../services/dbhelper/dbhelper.dart';
import '../AccountSet_up/Add_Acount.dart';
import 'addLiabilities.dart';


final dbhelper = DatabaseHelper.instance;
var emiamnt = 0;

void queryall() async{
  // _accList = List<Accounts>();
  print("checking");
  List<Map<String, dynamic>> allrows;
  List<Map<String, dynamic>> accdetails;
  allrows = await dbhelper.queryallacc();
  allrows.forEach((k){


    print("cda1 ${k.keys}");
    print("cda1 ${k.values}");



  }
  );
}
List<Map<String, dynamic>> accItems = [{"accountname":"s"},{"accountname":"s1"}];

class Liabilities extends StatefulWidget {
  const Liabilities({super.key});

  @override
  State<Liabilities> createState() => _Home_ScreenState();
}
List<Map<String, dynamic>> _foundUsers = [];
class _Home_ScreenState extends State<Liabilities> {
  @override
  initState() {
    // at the beginning, all users are shown
    //original    _foundUsers = _allUsers;
    _foundUsers = accItems;
    queryall();



    print('Original datas are..');

    super.initState();
  }
  String name = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,

        leading: IconButton(onPressed: (){
          Navigator.pop(context);

        }, icon: Icon(Icons.arrow_back, color: Colors.white,
        )),

        title: Text(' List of My Liabilities',style: TextStyle(color: Colors.white)),

      ),

      body:
      Container(

        child: Column(
          children: [

            Expanded(child:
            FutureBuilder(future: dbhelper.queryallacc(),

                //  dbhelper.queryallacc(),

                builder:

                    (context,AsyncSnapshot snapshot) {
                  List dat = snapshot.data;

                  // }
                  var s =
                  dat.forEach(print);
                  var str=' ';

                  // return ListView.builder(
                  //   primary: false,
                  //   itemCount: dat.length,
                  //   itemBuilder: (BuildContext context, int index) {
                  //
                  //     global.accname = dat[index]['accountname']?? "0";
                  //
                  //     global.catgry = dat[index]['catogory']?? "0";
                  //     global.obalance = dat[index]['openingbalance']??"0";
                  //     global.type = dat[index]['accountype']??"0";
                  final List<String> entries = <String>['A', 'B', 'C'];
                  return ListView.builder(
                    itemCount:2,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (BuildContext context, int index) {
                      return

                        Card(
                          elevation: 50,

                          child: Container(
                            height: 120,
                            child: Column(





                                children:<Widget> [


                                  Padding(
                                    padding: const EdgeInsets.only(left:15.0,),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [

                                          Text('AccountName    '),
                                          Text('  :'),
                                          Text(' HDFC Loan'),
                                          //  Text("${dat[index]['accountname']?? "0"}")


                                  ],),),


                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [

                                          Text('Amount '),
                                          Text('              :   '),
                                          Text('2500')
                                          //    Text("${dat[index]['Catogory']?? "0"}")

                                        ]),
                                  ),


                                  Padding(
                                    padding: const EdgeInsets.only(left: 180.0,top: 25),
                                    child: Row(
                                        children: [

                                          TextButton(onPressed: (){}, child: Text('Edit',style: TextStyle(color: Colors.green,fontSize: 20),)),
                                          TextButton(onPressed: (){}, child: Text('Delete',style: TextStyle(color: Colors.red,fontSize: 20),))

                                        ]),
                                  ),





                            ],),
                          ),

                        );

                    },
                  );

                  // },
                  //);





                }


            ),

            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,



        child: Row(

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            // Spacer(),
            // Spacer(),
            // Spacer(),
            // Spacer(),
            Container(
              height:105,

             child:  Padding(
               padding: const EdgeInsets.only(right: 70.0),
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '2500',
                      // '₹${_calculateTotal()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),



                  ],
                ),
             ),


            ),
            //  Text('Home'),

            Padding(
              padding: const EdgeInsets.only(bottom: 18.0,right: 20),
              child: Container(



                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      tooltip: 'Increment',
                      shape:   const CircleBorder(),
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder:(context)=>AddLiabilities( )));


                      },
                      child: const Icon(Icons.add, color: Colors.white, size: 25),
                    ),



              ),
            )

          ],
        ),
      ),



    );



    //  return   Placeholder();


  }
}