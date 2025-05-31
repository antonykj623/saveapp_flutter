import 'package:flutter/material.dart';


import '../../../services/dbhelper/dbhelper.dart';
import 'global.dart' as global;


class Editaccount extends StatefulWidget {
  //const Editaccount({super.key, required String accname, required String cat, required String obalance, required String actype,});
//const Editaccount({super.key});
  String accname,cat,obalance,actype;
//Editaccount({super.key, required this.accname, required this.cat, required this.obalance,required this.actype,});
  Editaccount({Key? key,required this.accname, required this.cat, required this.obalance,required this.actype,}):super(key: key){


    print(global.accname);
  }
  @override
  State<Editaccount> createState() => _SlidebleListState3();
}
class MenuItem {
  // final int id;
  final String label;
  // final IconData icon;

  MenuItem(this.label);
}
final dbhelper = DatabaseHelper.instance;
class MenuItem1 {
  // final int id;
  final String label1;
  // final IconData icon;

  MenuItem1(this.label1);
}
List<MenuItem> menuItems = [
  MenuItem('Asset Account'),
  MenuItem('Bank'),
  MenuItem('Cash'),
  MenuItem('Credit Card'),
  MenuItem('Customers'),
  MenuItem('Expense Account'),
  MenuItem('Income Account'),
  MenuItem('Insurance'),
  MenuItem('Investment'),
  MenuItem('Liability Account'),


];
List<MenuItem> menuItems1 = [
  MenuItem('Debit'),
  MenuItem('Credit'),


];

// List<MenuItem> menuItems = [
//    MenuItem('Credit'),
//   MenuItem('Debit'),


// ];
void update() async
{

  await dbhelper.updateaccountdet(global.accname, global.catgry, global.accname, global.type,global.year);

}


final TextEditingController accountname = TextEditingController(text: global.accname);
final TextEditingController catogory = TextEditingController();
final TextEditingController openingbalance = TextEditingController(text: global.obalance );
var dropdownvalu = '2025';
// var dropdownvalu1 = 'Debit';
final TextEditingController menuController = TextEditingController(text: global.catgry );
MenuItem? selectedMenu;
final TextEditingController menuController1 = TextEditingController(text: global.type );
var stat = "1";


MenuItem1? selectedMenu1;

final TextEditingController year = TextEditingController(text: dropdownvalu);
class _SlidebleListState3 extends State<Editaccount> {

  @override
  Widget build(BuildContext context) {


    print("sdfsdfsdfdsf"+'${global.accname}');
    //    accountname.text = accname;
    //TextEditingController accountname = TextEditingController(text: accname);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit')),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 500,
          // height: MediaQuery.of(context).size.height,
          //   width: MediaQuery.of(context).size.width,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              TextFormField(

                enabled: true,
                controller:accountname,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 5, 5, 5), width: .5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                  ),
                  //   hintText: "Accountname",


                  // hintText: 'MObile',
                  hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),


                  fillColor: const Color.fromARGB(0, 170, 30, 30),
                  filled: true,
                  // prefixIcon: const Icon(Icons.person,color:Colors.white)),
                ),
                validator:(value) {
                  if (value == "") {
                    return 'Account name';
                  }
                  return null;
                },


              ),
              const SizedBox(height: 20),

              Column(
                children: [

                  DropdownMenu<MenuItem>(
                    width: 400,

                    initialSelection: menuItems.first,

                    controller: menuController,
                    //  width: 600,
                    hintText: "Select Menu",
                    requestFocusOnTap: true,
                    enableFilter: true,
                    label: const Text('Select Catgory '),
                    onSelected: (MenuItem? menu) {
                      selectedMenu = menu;
                    },
                    dropdownMenuEntries:
                    menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
                      return DropdownMenuEntry<MenuItem>(
                        value: menu,
                        label: menu.label,
                        // leadingIcon: Icon(menu.icon));
                      );    }).toList(),
                  ),
                ],
              ),




              const SizedBox(height: 10),
              TextFormField(
                enabled: true,
                controller:openingbalance,
                // obscureText: true,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),


                  //   hintStyle: (TextStyle(color: Colors.white)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 0, 0, 0), width: .5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 254, 255, 255), width: .5),

                  ),
                  hintText: "Opening Balance",




                  fillColor: Colors.transparent,
                  filled: true,
                  //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                ),
                validator:(value) {
                  if (value == "") {
                    return 'Opening Balance';
                  }
                  return null;
                },
                //    obscureText: true,
              ),
              const SizedBox(height: 10),
              //  DropdownButton(


              //             icon:  Padding(
              //               padding: const EdgeInsets.only(left: 80.0,right: 10),
              //               child: Icon(Icons.keyboard_arrow_down),

              //             ),
              //             items: <String>['2025', '2026', '2027', '2028', '2029', '2030']
              //                 .map<DropdownMenuItem<String>>((String value) {
              //               return DropdownMenuItem<String>(

              //                 value: value,
              //                 child: Text(value),

              //               );
              //             }).toList(),
              //             value: dropdownvalu,

              //             onChanged: (values) {
              //               setState(() {
              //                 dropdownvalu = values.toString();
              //               });
              //             },
              //           ),


              const SizedBox(height: 10),
              DropdownMenu<MenuItem>(
                width: 400,
                initialSelection: menuItems1.first,
                controller: menuController1,
                //  width: 600,
                hintText: "Select Menu",
                requestFocusOnTap: true,
                enableFilter: true,
                label: const Text('Select  type'),
                onSelected: (MenuItem? menu) {
                  selectedMenu = menu;
                },
                dropdownMenuEntries:
                menuItems1.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
                  return DropdownMenuEntry<MenuItem>(
                    value: menu,
                    label: menu.label,
                    // leadingIcon: Icon(menu.icon));
                  );    }).toList(),
              ),



              const SizedBox(height: 20),
              Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: .7, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(0.0)),

                  ),
                ),
                child: DropdownButton(
                  menuWidth: 400,

                  isExpanded: true,


                  icon:  Padding(
                    padding: const EdgeInsets.only(left: 200.0,right: 10),
                    child: Icon(Icons.keyboard_arrow_down),

                  ),
                  items: <String>['2025', '2026', '2027', '2028', '2029', '2030']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(

                      value: value,
                      child: Text(value),

                    );
                  }).toList(),
                  value: dropdownvalu,


                  onChanged: (values) {
                    setState(() {
                      dropdownvalu = values.toString();
                    });
                  },
                ),


              ),



              Center(
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 57, 216, 62), // background (button) color
                    foregroundColor: Colors.white, // foreground (text) color
                  ),

                  onPressed: () {
                    update();
                    print("updateddddddddddddd");
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  //   color: const Color(0xFF1BC0C5),
                ),
              )




            ],

          ),
        ),
      ),



    );


  }
}