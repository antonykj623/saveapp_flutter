

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


class VisitingCardPage extends StatefulWidget {
  final String imageUrl;

  const VisitingCardPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<VisitingCardPage> createState() => _VisitingCardPageState();
}
class _VisitingCardPageState extends State<VisitingCardPage> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _shareCard() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/business_card.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'My Business Card');
    } catch (e) {
      print("Error sharing card: $e");
    }
  }

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
        title: const Text('Share VisitingCard Details', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.grey[200],
      body: SizedBox(
        child: SingleChildScrollView(

          child: Column(

            children: [
              RepaintBoundary(
                key: _globalKey,
                child:  Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.imageUrl),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),



                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with image
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("ANTONY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("Mobile Application Developer", style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text("Save App"),
                                  Text("Central And South America"),
                                  Text("Ty 😃"),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/1.jpg', // Replace with your asset
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        Container(
                          width: 350,
                          //  height: 200,


                          //  decoration: BoxDecoration(
                          // //   color: Colors.white,
                          //    border: Border.all(color: Colors.white),
                          //    borderRadius: BorderRadius.circular(0),
                          //  ),
                          child: Row(
                            children: [
                              // First Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Row(
                                      children: const [
                                        Icon(Icons.phone, size: 18),
                                        SizedBox(width: 8),
                                        Text("7575757373"),
                                      ],
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.add, size: 18),
                                        SizedBox(width: 8),
                                        Text("646464737"),
                                      ],
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.person, size: 18),
                                        SizedBox(width: 8),
                                        Text("6464"),
                                      ],
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.email, size: 18),
                                        SizedBox(width: 8),
                                        Text("antonykj623@gmail.com"),
                                      ],
                                    ),
                                    const Text("www.google.com"),
                                    const Text("ghhhh"),
                                    const Text("45666"),

                                  ],
                                ),
                              ),

                              // Second Column
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Image.asset(
                                          'assets/2.jpg', // Replace with your QR code
                                          width: 60,
                                          height: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        Container(

                          // Social Media
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: const [
                                  Icon(Icons.facebook, color: Colors.blue),
                                  Text("fblink"),
                                ],
                              ),
                              Column(
                                children: const [
                                  Icon(Icons.youtube_searched_for, color: Colors.red),
                                  Text("yt link"),
                                ],
                              ),
                              Column(
                                children: const [
                                  Icon(Icons.camera_alt, color: Colors.orange),
                                  Text("insta links"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              // Share Button
              ElevatedButton(
                onPressed: _shareCard,

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.teal,
                  // backgroundColor:
                  // const LinearGradient(
                  //   colors: [Colors.teal, Colors.blue],
                  // ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
                child: const Text("Share", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
