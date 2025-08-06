import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/add_website_link_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class WebLink {
  final int? keyId;
  final String websiteLink;
  final String username;
  final String password;
  final String description;

  WebLink({
    required this.keyId,
    required this.websiteLink,
    required this.username,
    required this.password,
    required this.description,
  });

  factory WebLink.fromMap(Map<String, dynamic> map) {
    return WebLink(
      keyId: map['keyid'] ?? 0,
      websiteLink: map['weblink'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      description: map['desc'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyid': keyId,
      'weblink': websiteLink,
      'username': username,
      'password': password,
      'desc': description,
    };
  }

  @override
  String toString() {
    return 'WebLinkData((keyId: $keyId,websiteLink: $websiteLink, username: $username, password: $password, description: $description)';
  }
}

class WebLinkItem {
  final int keyId;
  final WebLink data;

  WebLinkItem({required this.keyId, required this.data});

  factory WebLinkItem.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    final Map<String, dynamic> dataMap = rawData is String
        ? Map<String, dynamic>.from(jsonDecode(rawData))
        : Map<String, dynamic>.from(rawData);

    return WebLinkItem(
      keyId: map['keyid'] ?? 0,
      data: WebLink.fromMap(dataMap),
    );
  }

  @override
  String toString() => 'WebLinkItem(keyId: $keyId, data: $data)';
}

class WebLinksListPage extends StatefulWidget {
  @override
  _WebLinksListPageState createState() => _WebLinksListPageState();
}

class _WebLinksListPageState extends State<WebLinksListPage> {
  List<WebLink> webLinks = [];

  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllData();
    List<WebLink> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId; // Add keyId
        loadedLinks.add(WebLink.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      webLinks = loadedLinks;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // appBar: AppBar(
      //   backgroundColor: Colors.teal[600],
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      //   title: Text(
      //     'Web Links',
      //     style: TextStyle(color: Colors.white, fontSize: 20),
      //   ),
      //   elevation: 0,
      // ),

      body:
      Padding(
        padding: const EdgeInsets.all(0.0),

        child:
        Column(

       children: [
         Container(

           width: double.infinity,
           padding:  EdgeInsets.symmetric(
             horizontal: 16,
             vertical: 12,),
           decoration:  BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
             ),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: () => Navigator.pop(context),
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
                       'Add Password Manager',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 16,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ],
                 ),
               ),
               SizedBox(width: 8),

             ],
           ),
         ),


         Expanded(

           child: Container(

            child: ListView.builder(
              padding: EdgeInsets.all(16),

              itemCount: webLinks.length,
              itemBuilder: (context, index) {
                final link = webLinks[index];
                return WebLinkCard(

                  webLink: link,
                  onEdit: () => _editWebLink(index),
                  onDelete: () => _deleteWebLink(index),
                  onShare: () => _shareWebLink(index),
                );
              },
            ),
                   ),
         ),

       Padding(
         padding: const EdgeInsets.all(8.0),
         child: FloatingActionButton(
          onPressed: _addWebLink,
          backgroundColor: Colors.pink[600],
          child: Icon(Icons.add, color: Colors.white),
               ),
       ),
      ]) ));
  }

  void _addWebLink() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWebLinkPage(
          onSave: (webLink) {
            // No need to add to webLinks here; _loadData will handle it
          },
        ),
      ),
    );
    if (result == true) {
      _loadData(); // Re-fetch updated data from the database
    }
  }

  void _editWebLink(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWebLinkPage(
          webLink: webLinks[index],
          isEdit: true,
          onSave: (webLink) {
            // No need to update webLinks here; _loadData will handle it
          },
        ),
      ),
    );
    if (result == true) {
      _loadData(); // Re-fetch updated data from the database
    }
  }

  void _deleteWebLink(int index) async {
    final webLink = webLinks[index];
    final keyId = webLink.keyId;
    if (keyId != null) {
      await DatabaseHelper().deleteWebLInk("TABLE_WEBLINKS", keyId as String);
      _loadData(); // Refresh the UI after deletion
    }
  }

  void _shareWebLink(int index) {
    final webLink = webLinks[index];
    final shareText = '''
🔗 Website: ${webLink.websiteLink}
👤 Username: ${webLink.username}
📝 Description: ${webLink.description}
    '''.trim();

    Share.share(shareText, subject: 'Web Link - ${webLink.websiteLink}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link shared successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class WebLinkCard extends StatefulWidget {
  final WebLink webLink;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  WebLinkCard({
    required this.webLink,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  _WebLinkCardState createState() => _WebLinkCardState();
}

class _WebLinkCardState extends State<WebLinkCard> {
  bool _isPasswordVisible = false;



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Website Link', widget.webLink.websiteLink),
            SizedBox(height: 16),
            _buildInfoRow('Username', widget.webLink.username),
            SizedBox(height: 16),
            _buildPasswordRow(),
            SizedBox(height: 16),
            _buildInfoRow('Description', widget.webLink.description),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: widget.onDelete,
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: widget.onEdit,
                  child: Text(
                    'Edit',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: widget.onShare,
                  child: Text(
                    'Share',
                    style: TextStyle(color: Colors.green[700], fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(':', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(':', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            _isPasswordVisible ? widget.webLink.password : '*****',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Text(
            'View',
            style: TextStyle(color: Colors.teal, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
