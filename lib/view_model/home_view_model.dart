import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/Modules/accounts/addaccount.dart';
import '../app/Modules/accounts/editaccountdetails.dart';
import '../app/Modules/accounts/global.dart' as global;
import '../services/dbhelper/dbhelper.dart';
import 'Add_Acount.dart';

final dbhelper = DatabaseHelper.instance;
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _Home_ScreenState();
}
List<Map<String, dynamic>> _foundUsers = [];
class _Home_ScreenState extends State<HomeScreen> {
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

        title: Text(' Account Setup',style: TextStyle(color: Colors.white)),

      ),

      body:
      Container(

        child: Column(
          children: [
            TextField(
                decoration: InputDecoration(
                  prefixIcon:
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  hintText: 'Search by Account Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value){

                  setState(() {
                    name = value;
                  });
                }
              // calls the _searchChanged on textChange
              //   onChanged: (search) =>
            ),

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
                        itemCount:10,
                        padding: EdgeInsets.all(10),
                        itemBuilder: (BuildContext context, int index) {
                        return

                          Card(
                          elevation: 5,

                          child: Container(
                            child: Column(





                              children:<Widget> [

                                Padding(
                                  padding: const EdgeInsets.only(left:15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [

                                    Text('AccountName    '),
                                     Text('  :'),
                                     Text('  Accountname1')
                                   //  Text("${dat[index]['accountname']?? "0"}")

                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Text('Catogory '),
                                        Text('              :   '),
                                        Text('Cash')
                                    //    Text("${dat[index]['Catogory']?? "0"}")

                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Text('opening'
                                            'balance '),
                                           Text('   :'),
                                        Text('  2000'),
                                       // Text("${dat[index]['openingbalance']?? "0"}")

                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Text('AccountType      '),
                                        Text('   :  '),
                                        Text('Cash')

                                        // Text("${dat[index]['type']?? "0"}")

                                      ]),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Text('Year             '),
                                        Text('           :   '),
                                                        Text('2025')
                                      //  Text("${dat[index]['type']?? "0"}")

                                      ]),
                                ),


                                // Row(
                                //     children:[
                                //       Expanded(flex: 1, child:   IconButton(
                                //         iconSize: 25,
                                //         icon: const Icon(Icons.edit),
                                //         onPressed: () {
                                //           // print("accname is"+'${global.catgry}');
                                //           // global.accname=dat[index]['accountname'];
                                //           // global.catgry =dat[index]['catogory'];
                                //           // global.obalance =dat[index]['openingbalance'];
                                //           //  global.type =dat[index]['accountype'];
                                //           // Editaccount( global.acname, cat: global.catgry, obalance: global.obalance, actype: global.type, )
                                //           // Navigator.push(context,MaterialPageRoute(builder:(context)=>Editaccount(accname:dat[index]['accountname'],cat:dat[index]['catogory'],obalance: dat[index]['openingbalance'],actype:dat[index]['accountype'])));
                                //           //  Navigator.push(context,MaterialPageRoute(builder:(context)=>Editaccount(accname:global.accname,cat:global.catgry,obalance:global.obalance,actype:global.type)));
                                //           print("cat is..${dat[index]['openingbalance']?? "0"}");
                                //           var anm = dat[index]['accountname'];
                                //           print("anamwwww is...$anm");
                                //           var cat = dat[index]['catogory'];
                                //           var acty = dat[index]['type'];
                                //           var ob = dat[index]['openingbalance'];
                                //           global.accname = anm ?? "0";
                                //           global.catgry = cat ?? "0";
                                //           global.type = acty ??"0";
                                //           global.obalance = ob ?? "0";
                                //           Navigator.push(context,MaterialPageRoute(builder:(context)=>
                                //               Editaccount(accname: anm??"0", cat: cat??"0", obalance: ob??"0", actype: acty??"0")));
                                //         },
                                //       ),),
                                //       Expanded(flex: 2, child:   IconButton(
                                //         iconSize: 25,
                                //         icon: const Icon(Icons.delete),
                                //         onPressed: () {
                                //           //Navigator.push(context,MaterialPageRoute(builder:(context)=>Editaccount( )));
                                //         },
                                //       ),),
                                //     ]
                                // ),
                            // Column(
                            //   children: [
                            //     Row(
                            //       children: [
                            //     IconButton(
                            //       iconSize: 25,
                            //       icon: const Icon(Icons.edit),
                            //       onPressed: () {
                            //         // ...
                            //       },
                            //     ),
                            //   ]

                            //   )


                            //   ],
                            // ),









                            SizedBox(height: 10,),

                                Container(
                                  decoration:


                                  BoxDecoration(
                                    // border: Border.all(
                                    //   color: Colors.black,

                                      boxShadow: const [
                                        BoxShadow(
                                          blurStyle: BlurStyle.outer,
                                          spreadRadius: 0,
                                          blurRadius: 3,
                                          color: Colors.grey,
                                        ),
                                      ],




                                  //  borderRadius: BorderRadius.circular(0.0), // Uniform radius
                                  ),
                                  child: Row(
                                      children: [

                                        Padding(
                                            padding: const EdgeInsets.only(left:150),
                                            child:  TextButton(onPressed: (){}, child: Text('Edit',style: TextStyle(color: Colors.green,fontSize: 20),))



                                        ),

                                      ]),
                                )]

                            ),
                          ),

                        );

                        },
                      );

                   // },
                  //);





                }

              //  return PageView.builder(
              //     itemCount: 1,
              //     itemBuilder: (context, index) {
              //       String kec1 = "  1. " + isipendudukkecamatan[index].
              //       String kec2 =  "";
              //     });

              // if (!snapshot.hasData) {
              //       // Show loading when there is no data
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //     else{
              //       return ListTile(

              //         iconColor: Colors.amber,
              //       );

              //     }
              //     else{
              //       var mydata = snapshot.data;
              //     return ListView.builder(
              //           itemCount: mydata.length,

              //       itemBuilder: (context, index) => Card(

              //               key: ValueKey(mydata[index]["accountname"]),
              //          color: Colors.amber,

              //                   elevation: 4,
              //                   margin: const EdgeInsets.symmetric(vertical: 10),
              //                   child: ListTile(
              //                     leading: Text(

              //                       mydata(index.)
              //                       mydata[index]["accountnaame"].toString(),
              //                       style: const TextStyle(fontSize: 24),
              //                     ),
              //                     title: Text(fghfghfgghj),
              //                    // subtitle: Text(
              //                      //   '${mydata[index]["type"].toString()} '),


              // )
              //       )  );

              //     }

            ),

            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(
          left: 40.0,
        ),
        child: Row(

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Container(
              height:65,

              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Increment',
                shape:   const CircleBorder(),
                onPressed: (){
               Navigator.push(context,MaterialPageRoute(builder:(context)=>Addaccountsdet( )));


                },
                child: const Icon(Icons.add, color: Colors.white, size: 25),
              ),


            ),
            //  Text('Home'),
            Spacer(),

          ],
        ),
      ),



    );



    //  return   Placeholder();


  }
}