import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:new_project_2025/app/Modules/accounts/global.dart';

import '../../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

String? selectedValue;

class Editaccount extends StatefulWidget {
  //const Editaccount({super.key, required String accname, required String cat, required String obalance, required String actype,});
  //const Editaccount({super.key});
  final String keyid, year, accname, cat, obalance, actype;
  //Editaccount({super.key, required this.accname, required this.cat, required this.obalance,required this.actype,});
  Editaccount({
    required this.keyid,
    required this.year,
    required this.accname,
    required this.cat,
    required this.obalance,
    required this.actype,
  }) {
    print(accname);
  }
  @override
  State<Editaccount> createState() => _SlidebleListState3(
    this.keyid,
    this.year,
    this.accname,
    this.cat,
    this.obalance,
    this.actype,
  );
}

class MenuItem {
  // final int id;
  final String label;
  // final IconData icon;

  MenuItem(this.label);
}

class MenuItem1 {
  // final int id;
  final String label1;
  // final IconData icon;

  MenuItem1(this.label1);
}

class MenuItem2 {
  // final int id;
  final String label2;
  // final IconData icon;

  MenuItem2(this.label2);
}

List<MenuItem2> menuItems2 = [
  MenuItem2('2025'),
  MenuItem2('2026'),
  MenuItem2('2027'),
  MenuItem2('2028'),
  MenuItem2('2029'),
  MenuItem2('2030'),
];

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
List<MenuItem1> menuItems1 = [MenuItem1('Debit'), MenuItem1('Credit')];

var i;
var itm;
final String catvalue = "";
String? selectedvalue;
final TextEditingController accountname = TextEditingController();
final TextEditingController catogory = TextEditingController();
final TextEditingController openingbalance = TextEditingController();
var dropdownvalu = '2025';
// var dropdownvalu1 = 'Debit';
final TextEditingController menuController = TextEditingController();

MenuItem? selectedMenu;
final TextEditingController menuController1 = TextEditingController();
var stat = "1";

MenuItem1? selectedMenu1;

final TextEditingController menuController2 = TextEditingController();
MenuItem2? selectedMenu2;

MenuItem? menutitem_category;

class _SlidebleListState3 extends State<Editaccount> {
  final String keyid, year, accname, cat, obalance, actype;

  _SlidebleListState3(
    this.keyid,
    this.year,
    this.accname,
    this.cat,
    this.obalance,
    this.actype,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("keyid is :" + keyid);
    setState(() {
      accountname.text = accname;
      print('Account name is ${accname}');
      print("Year is : " + year);

      for (MenuItem i in menuItems) {
        print(i.label);
        print("current : " + cat);
        if (i.label.toString().compareTo(cat) == 0) {
          catogory.text = cat;
          menutitem_category = i;
          break;
        }
      }
      for (MenuItem1 i in menuItems1) {
        print(i.label1);

        if (i.label1.toString().trim().compareTo(actype) == 0) {
          selectedMenu1 = i;
          print("Type is : " + actype);
          break;
        }
      }

      for (MenuItem2 i in menuItems2) {
        print(i.label2);

        if (i.label2.toString().trim().compareTo(year.trim()) == 0) {
          selectedMenu2 = i;
          print("current year : " + year);
          break;
        }
      }

      openingbalance.text = obalance;
      print('openingbalance is ${obalance}');
      //  menuController.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("sdfsdfsdfdsf"+'${global.accname}');
    //    accountname.text = accname;
    //TextEditingController accountname = TextEditingController(text: accname);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit')),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: double.infinity,
          // height: MediaQuery.of(context).size.height,
          //   width: MediaQuery.of(context).size.width,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                enabled: true,
                controller: accountname,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 5, 5, 5),
                      width: .5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 254, 255, 255),
                      width: .5,
                    ),
                  ),
                  hintText: "Accountname",

                  // hintText: 'MObile',
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),

                  fillColor: const Color.fromARGB(0, 170, 30, 30),
                  filled: true,
                  // prefixIcon: const Icon(Icons.person,color:Colors.white)),
                ),
                validator: (value) {
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
                    width: double.infinity,

                    initialSelection: menutitem_category,

                    controller: menuController,
                    //  width: 600,
                    hintText: "Select Menu",
                    requestFocusOnTap: true,
                    enableFilter: true,
                    label: const Text('Select Category '),
                    onSelected: (MenuItem? menu) {
                      selectedMenu = menu;
                    },
                    dropdownMenuEntries:
                        menuItems.map<DropdownMenuEntry<MenuItem>>((
                          MenuItem menu,
                        ) {
                          return DropdownMenuEntry<MenuItem>(
                            value: menu,
                            label: menu.label,
                            // leadingIcon: Icon(menu.icon));
                          );
                        }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              TextFormField(
                enabled: true,
                controller: openingbalance,
                // obscureText: true,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),

                  //   hintStyle: (TextStyle(color: Colors.white)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: .5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 254, 255, 255),
                      width: .5,
                    ),
                  ),
                  hintText: "Opening Balance",

                  fillColor: Colors.transparent,
                  filled: true,

                  //  prefixIcon: const Icon(Icons.password,color:Colors.white)
                ),
                validator: (value) {
                  if (value == "") {
                    return 'Opening Balance';
                  }
                  return null;
                },
                //    obscureText: true,
              ),
              const SizedBox(height: 10),
              DropdownMenu<MenuItem1>(
                width: double.infinity,

                initialSelection: selectedMenu1,

                //  width: 600,
                hintText: "Select Type",
                requestFocusOnTap: true,
                enableFilter: true,

                onSelected: (MenuItem1? menu) {
                  selectedMenu1 = menu;
                },
                dropdownMenuEntries:
                    menuItems1.map<DropdownMenuEntry<MenuItem1>>((
                      MenuItem1 menu,
                    ) {
                      return DropdownMenuEntry<MenuItem1>(
                        value: menu,
                        label: menu.label1,
                        // leadingIcon: Icon(menu.icon));
                      );
                    }).toList(),
              ),

              const SizedBox(height: 10),
              DropdownMenu<MenuItem2>(
                width: double.infinity,

                initialSelection: selectedMenu2,

                //  width: 600,
                hintText: "Select Year",
                requestFocusOnTap: true,
                enableFilter: true,

                onSelected: (MenuItem2? menu) {
                  selectedMenu2 = menu;
                },
                dropdownMenuEntries:
                    menuItems2.map<DropdownMenuEntry<MenuItem2>>((
                      MenuItem2 menu,
                    ) {
                      return DropdownMenuEntry<MenuItem2>(
                        value: menu,
                        label: menu.label2,
                        // leadingIcon: Icon(menu.icon));
                      );
                    }).toList(),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),

              // Container(
              //   decoration: ShapeDecoration(
              //     shape: RoundedRectangleBorder(
              //       side: BorderSide(width: .7, style: BorderStyle.solid),
              //       borderRadius: BorderRadius.all(Radius.circular(0.0)),
              //
              //     ),
              //   ),
              //   child: DropdownButton(
              //     menuWidth: 400,
              //     value: selectedValue,
              //     isExpanded: true,
              //
              //
              //     icon:  Padding(
              //       padding: const EdgeInsets.only(left: 200.0,right: 10),
              //       child: Icon(Icons.keyboard_arrow_down),
              //
              //     ),
              //     items: <String>['2025', '2026', '2027', '2028', '2029', '2030']
              //
              //         .map<DropdownMenuItem<String>>((String value) {
              //
              //
              //       return DropdownMenuItem<String>(
              //
              //         value: value,
              //         child: Text(value),
              //
              //       );
              //     }).toList(),
              //     // value: dropdownvalu,
              //
              //
              //     onChanged: (values) {
              //       setState(() {
              //         dropdownvalu = values.toString();
              //       });
              //     },
              //   ),
              //
              //
              // ),
              //
              SizedBox(height: 70),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      57,
                      216,
                      62,
                    ), // background (button) color
                    foregroundColor: Colors.white, // foreground (text) color
                  ),

                  onPressed: () {
                    DatabaseHelper().updateaccountdet(
                      accountname.text,
                      menutitem_category!.label,
                      openingbalance.text,
                      selectedMenu1!.label1,
                      selectedMenu2!.label2,
                      keyid,
                    );
                    print("updateddddddddddddd");
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  //   color: const Color(0xFF1BC0C5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
