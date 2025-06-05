import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';

import 'addVisitingcard.dart';
import 'test.dart';

class VisitingCard extends StatefulWidget {
  const VisitingCard({super.key});

  @override
  _VisitingCardFormState createState() => _VisitingCardFormState();
}

class _VisitingCardFormState extends State<VisitingCard> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final List<dynamic> _images = [
    "assets/1.jpg",

    "assets/2.jpg",
    "assets/3.jpg",
  ];
  int _currentIndex = 0;
  final picker = ImagePicker();

  // Future<void> _pickImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _images.add(File(pickedFile.path) as String  );
  //     });
  //   }
  // }
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController whatsapnumber = TextEditingController();
  final TextEditingController landphone = TextEditingController();
  final TextEditingController companyName = TextEditingController();
  final TextEditingController desig = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController saveapplink = TextEditingController();
  final TextEditingController couponcode = TextEditingController();
  final TextEditingController fblink = TextEditingController();
  final TextEditingController instalink = TextEditingController();
  final TextEditingController youtubelink = TextEditingController();
  final TextEditingController companyaddress = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Add VisitingCard Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Text(
            //   'Visiting Card Background',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            // ),
            SizedBox(height: 10),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height / 4.2,
                    child: CarouselSlider(
                      items:
                          _images.map((img) {
                            return Container(
                              margin: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image:
                                      img is String
                                          ? AssetImage(img) as ImageProvider
                                          : FileImage(img),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                      options: CarouselOptions(
                        height: 180.0,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        aspectRatio: 16 / 10,
                        enableInfiniteScroll: true,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index; // 🔥 Get current index here
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.pink,
                    onPressed: _pickImage,
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: name,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Name",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return ' Please enter name';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                // First TextField
                Expanded(
                  child: TextFormField(
                    enabled: true,
                    controller: phone,

                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),

                      //   hintStyle: (TextStyle(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                      //
                      // ),
                      hintText: "Phone Number",

                      fillColor: Colors.transparent,
                      filled: true,

                      //  prefixIcon: const Icon(Icons.password,color:Colors.white)
                    ),
                    validator: (value) {
                      if (value == "") {
                        return ' Please enter Phone';
                      }
                      return null;
                    },
                    //    obscureText: true,
                  ),
                ),
                SizedBox(width: 16), // space between the two fields
                // Second TextField
                Expanded(
                  child: TextFormField(
                    enabled: true,
                    controller: whatsapnumber,

                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),

                      //   hintStyle: (TextStyle(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                      //
                      // ),
                      hintText: "Whatsapp Number",

                      fillColor: Colors.transparent,
                      filled: true,

                      //  prefixIcon: const Icon(Icons.password,color:Colors.white)
                    ),
                    validator: (value) {
                      if (value == "") {
                        return ' Please enter Whatsapnumber';
                      }
                      return null;
                    },
                    //    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: landphone,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Land Phone Number",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return ' Please enter LandPhoneNumber';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: email,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Email",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return ' Please enter Email';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: companyName,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Company Name",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return ' Please Enter Company Name';
                }
                return null;
              },
              //    obscureText: true,
            ),

            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: desig,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Designation/Profession",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return ' Enter Designation';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: website,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: " Website",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'Website';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: saveapplink,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Save App link",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'Save app link';
                }
                return null;
              },
              //    obscureText: true,
            ),
            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: couponcode,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Coupon Code",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'Coupon Code';
                }
                return null;
              },
              //    obscureText: true,
            ),

            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: fblink,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "FaceBook Link",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'FaceBook Link';
                }
                return null;
              },
              //    obscureText: true,
            ),

            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: instalink,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Instagram Link",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'Instagram Link';
                }
                return null;
              },
              //    obscureText: true,
            ),

            SizedBox(height: 20),

            TextFormField(
              enabled: true,
              controller: youtubelink,

              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                //   hintStyle: (TextStyle(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                //
                // ),
                hintText: "Youtube Link",

                fillColor: Colors.transparent,
                filled: true,

                //  prefixIcon: const Icon(Icons.password,color:Colors.white)
              ),
              validator: (value) {
                if (value == "") {
                  return 'Youtube Link';
                }
                return null;
              },
              //    obscureText: true,
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextFormField(
                controller: companyaddress,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Company Address',
                  hintStyle: TextStyle(fontSize: 15.0, color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  'Company Logo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Logo container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image:
                              _image != null
                                  ? FileImage(_image!)
                                  : AssetImage('assets/3.jpg') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Camera icon overlay
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {
                String selectedImage = _images[_currentIndex];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => VisitingCardPage(imageUrl: selectedImage),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildTextField(String hint) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder()),
    ),
  );
}

Widget buildDoubleField(String hint1, String hint2) {
  return Row(
    children: [
      Expanded(child: buildTextField(hint1)),
      SizedBox(width: 10),
      Expanded(child: buildTextField(hint2)),
    ],
  );
}
