import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final String referralLink =
      "http://mysaveapp.com/signup?sponserid=qwertyuiop";

  String? timestamp;
  ApiHelper api = ApiHelper();
  List<String> imageList = [];
  String description = '';
  bool isDownloading = false;
  @override
  void initState() {
    super.initState();
    imageData();
    // downloadAndShareImage('slider.jpeg');
  }

  Future<void> downloadShareImage(String imageName, String token) async {
    setState(() {
      isDownloading = true;
    });

    try {
      final imageUrl = 'https://mysaving.in/images/$imageName';

      // Step 1: Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) throw Exception("Image download failed");

      // Step 2: Get temp directory path
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$imageName';

      // Step 3: Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Step 4: Share the image with token
      final referralLink = "http://mysaveapp.com/signup?sponserid=qwertyuiop";
      final fullLink = "$referralLink&token=$token";

      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: "Join this platform:\n$fullLink");
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to download image.")));
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  String extractFileName(String url) {
    return url.split('/').last;
  }

  void imageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      String response = await api.getApiResponse(
        "getSettingsSlider.php?&timestamp=$timestamp",
      );
      debugPrint("Response: $response");

      final jsonData = json.decode(response);
      if (jsonData["status"] == 1) {
        List<dynamic> data = jsonData['data'];
        print("Data is $data");
        List<String> tempImages =
            data
                .map<String>(
                  (item) => 'https://mysaving.in/images/${item['image']}',
                )
                .toList();
        String tempDescription = data.isNotEmpty ? data[0]['description'] : '';
        // List<String> tempImages = data.map<String>((item) => item['image'].toString()).toList();
        print("Listofiamge  is $tempImages");
        setState(() {
          imageList = tempImages;
          description = tempDescription;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Share",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                imageList.isNotEmpty
                    ? CarouselSlider(
                      options: CarouselOptions(
                        height: 280,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                      ),
                      items:
                          imageList.map((imagePath) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Center(child: Text('Image load error')),
                              ),
                            );
                          }).toList(),
                    )
                    : Center(child: CircularProgressIndicator()),

                SizedBox(height: 16),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralLink,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: () async {
                          Clipboard.setData(ClipboardData(text: referralLink));
                          await Share.share(
                            'Join this platform using my referral link:\n$referralLink',
                            subject: 'Referral Invitation',
                          );
                        },
                        child: Text(
                          "Copy link",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (imageList.isNotEmpty) {
                      const token =
                          'qwertyuioplkjhgfvbnmlkjiou.OTc0NzQ5Nzk2Nw==.MjVkNTVhZDI4M2FhNDAwYWY0NjRjNzZkNzEzYzA3YWQ=.qwertyuioplkjhgfvbnmlkjiou';
                      String imageUrl = imageList[0];
                      String imageName = extractFileName(imageUrl);
                      downloadShareImage(imageName, token);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No image available to share")),
                      );
                    }
                  },
                  icon: Icon(Icons.image),
                  label: Text("Share Image with Token"),
                ),

                if (isDownloading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),

                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
