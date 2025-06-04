import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/add_website_link_page.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Links',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: WebLinksListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebLink {
  String websiteLink;
  String username;
  String password;
  String description;

  WebLink({
    required this.websiteLink,
    required this.username,
    required this.password,
    required this.description,
  });
}

class WebLinksListPage extends StatefulWidget {
  @override
  _WebLinksListPageState createState() => _WebLinksListPageState();
}

class _WebLinksListPageState extends State<WebLinksListPage> {
  List<WebLink> webLinks = [
    WebLink(
      websiteLink: 'https connection',
      username: 'uiii',
      password: 'password123',
      description: 'hhggv',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[600],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          'Web Links',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: webLinks.length,
        itemBuilder: (context, index) {
          return WebLinkCard(
            webLink: webLinks[index],
            onEdit: () => _editWebLink(index),
            onDelete: () => _deleteWebLink(index),
            onShare: () => _shareWebLink(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWebLink,
        backgroundColor: Colors.pink[600],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addWebLink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditWebLinkPage(
              onSave: (webLink) {
                setState(() {
                  webLinks.add(webLink);
                });
              },
            ),
      ),
    );
  }

  void _editWebLink(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditWebLinkPage(
              webLink: webLinks[index],
              isEdit: true,
              onSave: (webLink) {
                setState(() {
                  webLinks[index] = webLink;
                });
              },
            ),
      ),
    );
  }

  void _deleteWebLink(int index) {
    setState(() {
      webLinks.removeAt(index);
    });
  }

  void _shareWebLink(int index) {
    final webLink = webLinks[index];
    final shareText =
        '''
🔗 Website: ${webLink.websiteLink}
👤 Username: ${webLink.username}
📝 Description: ${webLink.description}
    '''.trim();

    Share.share(shareText, subject: 'Web Link - ${webLink.websiteLink}');

    // Show confirmation
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

