import 'package:flutter/material.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final List<String> item = [
    "How to use",
    "Help on Whatsapp",
    "mail Us",
    "About Us",
    'Privacy Policy',
    "Terms and Conditions For Use",
    "FeedBack",
    'Share',
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: ListView.builder(
          itemCount: item.length,
          itemBuilder: (context, index) {
            return _buildReportItem1(
              title: item[index],
              onTap: () {
                print("${item[index]} tapped");
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportItem1({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
