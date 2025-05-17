import 'package:flutter/material.dart';
import 'package:new_project_2025/model/images/images.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAVE Personal App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFCFECEC),
      ),
      home: const SaveApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SaveApp extends StatelessWidget {
  const SaveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: const Color(0xFFCFECEC),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image.network(
                //   'https://via.placeholder.com/40/008080/FFFFFF/?text=S',
                //   width: 40,
                //   height: 40,
                // ),
                const SizedBox(width: 10),
                Image.asset(Images.appbar, height: 80),
                const SizedBox(width: 20),
                const Text(
                  'My Personal App',
                  style: TextStyle(
                    color: Color(0xFF008080),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 50),
                const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF008080),
                  size: 50,
                ),
                const SizedBox(width: 20),
                const Icon(Icons.settings, color: Color(0xFF008080), size: 50),
              ],
            ),
          ),

          // Scrollable Main Content
          Expanded(child: AllInOneScreen()),

          // Bottom Navigation Bar
          Container(
            height: 60,
            color: const Color(0xFF008080),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, color: Colors.white),
                    Text('Home', style: TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, color: Colors.white),
                    Text('Report', style: TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_horiz, color: Colors.white),
                    Text('More', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          // Android Navigation Bar (Visual Only)
          Container(
            height: 48,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.arrow_back, color: Colors.white),
                Icon(Icons.circle_outlined, color: Colors.white),
                Icon(Icons.crop_square, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AllInOneScreen extends StatefulWidget {
  const AllInOneScreen({Key? key}) : super(key: key);

  @override
  State<AllInOneScreen> createState() => _AllInOneScreenState();
}

class _AllInOneScreenState extends State<AllInOneScreen> {
  final List<String> images = [
    'https://via.placeholder.com/600x300/008080/ffffff?text=Slide+1',
    'https://via.placeholder.com/600x300/20b2aa/ffffff?text=Slide+2',
    'https://via.placeholder.com/600x300/5f9ea0/ffffff?text=Slide+3',
  ];
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                images.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _current == entry.key ? Colors.teal : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SectionHeader(title: 'My Money'),
          buildCategorySection([
            {
              'icon': Icons.credit_card,
              'label': 'Payments',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.receipt,
              'label': 'Receipts',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.account_balance_wallet,
              'label': 'Wallet',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.business_center,
              'label': 'Budget',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.account_balance,
              'label': 'Bank',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.book,
              'label': 'Journal',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.description,
              'label': 'Billing',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.monetization_on,
              'label': 'Cash and Bank',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.calculate,
              'label': 'Account Setup',
              'color': Color(0xFF008080),
            },
          ]),

          const SectionHeader(title: 'My Belongings'),
          buildCategorySection([
            {
              'icon': Icons.trending_up,
              'label': 'Investment',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.lock,
              'label': 'Password Manager',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.description,
              'label': 'Document Manager',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.account_balance_wallet,
              'label': 'Asset',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.note_alt,
              'label': 'Liability',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.security,
              'label': 'Insurance',
              'color': Color(0xFF008080),
            },
          ]),

          const SectionHeader(title: 'My Life'),
          buildCategorySection([
            {
              'icon': Icons.task_alt,
              'label': 'Task',
              'color': Color(0xFF008080),
            },
            {'icon': Icons.book, 'label': 'Diary', 'color': Color(0xFF008080)},
            {
              'icon': Icons.add_circle_outline,
              'label': 'Dream',
              'color': Color(0xFF008080),
            },
          ]),

          const SectionHeader(title: 'Utilities'),
          buildCategorySection([
            {
              'icon': Icons.smartphone,
              'label': 'Mobile Recharge',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.satellite_alt,
              'label': 'DTH Recharge',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.contact_mail,
              'label': 'Visiting Card',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.link,
              'label': 'Website Links',
              'color': Color(0xFF008080),
            },
            {
              'icon': Icons.warning,
              'label': 'Emergency Numbers',
              'color': Color(0xFF008080),
            },
          ]),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildCategorySection(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            items.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: item['color'],
                    radius: 24,
                    child: Icon(item['icon'], color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(item['label'], style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

 Widget buildCategorySection(List<Map<String, dynamic>> items) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'], color: item['color'], size: 50),
            const SizedBox(height: 8),
            Text(
              item['label'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    ),
  );
}
