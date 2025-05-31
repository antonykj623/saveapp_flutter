

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../services/dbhelper/dbhelper.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';


class Adddocumentmanager extends StatefulWidget {
  const Adddocumentmanager({super.key});

  @override
  State<Adddocumentmanager> createState() => _SlidebleListState1();


}

  class _SlidebleListState1 extends State<Adddocumentmanager> {

    @override
    void initState() {
      super.initState();
      // Schedule the dialog to be shown after the widget has been built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showmyDialog();
      });}






      final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final TextEditingController name = TextEditingController();
    final TextEditingController filepick = TextEditingController();
    static const IconData camera_alt = IconData(0xe130, fontFamily: 'MaterialIcons');
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImageFromGallery() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Picked from gallery: ${image.path}');
      }
    }

    Future<void> pickFolder() async {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User canceled the picker
        print("No directory selected");
      } else {
        print("Selected directory: $selectedDirectory");
      }
    }

    // Future<void> _pickFile() async {
    //   FilePickerResult? result = await FilePicker.platform.pickFiles();
    //
    //   if (result != null && result.files.single.path != null) {
    //     setState(() {
    //       filepick.text = result.files.single.name; // or .path
    //     });
    //   }
    // }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(title: const Text('Add Account Setup')),
        appBar: AppBar(
          backgroundColor: Colors.teal,

          leading: IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back, color: Colors.white,
          )),

          title: Text(
              'Add Document Manager', style: TextStyle(color: Colors.white)),

        ),
drawer:  Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        child: Text('Choose Option'),
        decoration: BoxDecoration(color: Colors.blue),
      ),
      ListTile(
        leading: Icon(Icons.photo),
        title: Text('Gallery'),
        onTap: () {
          Navigator.pop(context);
          _pickImageFromGallery();
        },
      ),
      ListTile(
        leading: Icon(Icons.folder),
        title: Text('From Folder'),
        onTap: () {
          Navigator.pop(context);
          pickFolder();
        },
      ),
    ],
  ),
),
        body: Padding(
          padding: const EdgeInsets.all(20.0),


        ),


      );
    }

    void showmyDialog() {
      showDialog(
        context: context,
       // barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            content:  Container(

    width: 300,
            height: 300,

            //   color: const Color.fromARGB(255, 255, 255, 255),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      TextFormField(

                        enabled: true,
                        controller: name,

                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),


                          //   hintStyle: (TextStyle(color: Colors.white)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black),
                          ),
                          // focusedBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                          //
                          // ),
                          hintText: "Name ",


                          fillColor: Colors.transparent,
                          filled: true,
                          //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                        ),
                        validator: (value) {
                          if (value == "") {
                            return ' name';
                          }
                          return null;
                        },
                        //    obscureText: true,
                      ),
                      SizedBox(height: 20,),

                      TextField(
                        controller:  filepick,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Select File',
                          suffixIcon: Container(
                            width: 120,
                            color: Colors.teal,
                            child: IconButton(
                                icon: Icon(Icons.camera_alt),
                                color: Colors.white,
                                onPressed:(){

                                  _scaffoldKey.currentState?.openDrawer();


                                }


                              //_pickFile,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 80,),
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                        child: Column(
                          children: [
                            ElevatedButton(

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,// background (button) color
                                foregroundColor: Colors.white, // foreground (text) color

                              ),

                              onPressed: () {

                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                              ),
                              //   color: const Color(0xFF1BC0C5),
                            ),



                          ],),
                      ),




                    ])),

          );
        },
      );
    }



  }
