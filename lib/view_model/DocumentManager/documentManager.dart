import 'dart:convert';
import 'dart:io';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'addDocumentmanager.dart';

class DocumentModel {
  final String doc;
  final String doclink;
  final String keyid;

  DocumentModel({
    required this.doc,
    required this.doclink,
    required this.keyid,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'doc': doc, 'doclink': doclink, 'keyid': keyid};
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      keyid: map['keyid'] ?? 0,
      doclink: map['doclink'] ?? '',
      doc: map['doc'] ?? '',
    );
  }

  // Convert from JSON
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      doc: json['doc'],
      doclink: json['doclink'],
      keyid: json['keyid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'keyid': keyid, 'doclink': doclink, 'doc': doc};
  }
}

var id;

Future<void> getDocumentFromServer({required String fileId}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print("No token found!");
    return;
  }

  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final url = Uri.parse(
      'https://mysaving.in/IntegraAccount/api/getUploadedDocumentPath.php?timestamp=$timestamp&fileid=$fileId',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 1 && jsonResponse['data'] != null) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        final fileName = data['filename'] as String?;

        if (fileName == null || fileName.isEmpty) {
          print("Filename missing or empty in JSON data.");
          return;
        }

        final documentUrl =
            'https://mysaving.in/uploads/user_documents/$fileName';

        final fileResponse = await http.get(Uri.parse(documentUrl));

        if (fileResponse.statusCode == 200) {
          final bytes = fileResponse.bodyBytes;

          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          print("File saved to: $filePath");

          // Share the saved file
          await Share.shareXFiles([
            XFile(filePath),
          ], text: 'Here is the document.');
        } else {
          print(
            "Failed to download the document. Status: ${fileResponse.statusCode}",
          );
        }
      } else {
        print("Failed or invalid response: ${jsonResponse['message']}");
      }
    } else {
      print(
        "Failed to fetch document filename. Status: ${response.statusCode}",
      );
    }
  } catch (e) {
    print("Error fetching or sharing document: $e");
  }
}

List<String> _filteredItems = [];
TextEditingController _searchController = TextEditingController();

class Documentmanager extends StatefulWidget {
  Documentmanager({super.key});

  @override
  State<Documentmanager> createState() => _Home_ScreenState();
}

List<Map<String, dynamic>> _foundUsers = [];

class _Home_ScreenState extends State<Documentmanager> {
  bool isLoading = false;
  String getFilenameFromDoclink(String doclink) {
    if (doclink.isEmpty) return '';
    try {
      Uri uri = Uri.parse(doclink);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    } catch (e) {
      print("Error parsing URI: $e");
      return '';
    }
  }

  List<DocumentModel> docLinks = [];
  int currentYear = DateTime.now().year;
  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllDocData();
    List<DocumentModel> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId; // Add keyId
        loadedLinks.add(DocumentModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      docLinks = loadedLinks;
    });
  }

  @override
  initState() {
    super.initState();
    _loadData();
  }

  Future<void> _handleDownload(String fileId) async {
    setState(() => isLoading = true);
    await Future.delayed(Duration.zero); // Let UI show loader
    await getDocumentFromServer(fileId: fileId);
    await Future.delayed(Duration(seconds: 2)); // Simulate 2-second loading
    setState(() => isLoading = false);
  }

  Future<void> _handleDelete(int keyid) async {
    setState(() => isLoading = true);
    await Future.delayed(Duration.zero);
    await DatabaseHelper().deleteByFieldId('TABLE_DOCUMENT', keyid);
    _loadData();
    await Future.delayed(Duration(seconds: 2));

    setState(() => isLoading = false);
  }

  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFFF093fb),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SaveApp()),
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text(
                            ' Document Manager',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getAllData('TABLE_DOCUMENT'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return const Center(child: Text("No documents found"));
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final dataJson = jsonDecode(item['data'] ?? '{}');
                        final doclink = dataJson['doclink'] ?? '';
                        final filename = getFilenameFromDoclink(doclink);
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name: ${dataJson['doc'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Filename: $filename",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        List<Map<String, dynamic>> documents =
                                            await DatabaseHelper()
                                                .fetchAllDocData();
                                        final kid = documents[index]['keyid'];
                                        if (kid != null) {
                                          await _handleDelete(kid);
                                        }
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () async {
                                        final fileid1 = dataJson["fileid"];
                                        await _handleDownload(fileid1);
                                      },
                                      child: const Text(
                                        'Download',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Container(
              height: 65,

              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Increment',
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Adddocumentmanager(),
                    ),
                  );
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
