// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:new_project_2025/model/images/images.dart';
// import 'package:new_project_2025/view/home/widget/Notification_page.dart';
// import 'package:new_project_2025/view/home/widget/setting_page/setting_page.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SAVE Personal App',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         scaffoldBackgroundColor: const Color(0xFFCFECEC),
//       ),
//       home: const SaveApp(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class SaveApp extends StatefulWidget {
//   const SaveApp({Key? key}) : super(key: key);

//   @override
//   State<SaveApp> createState() => _SaveAppState();
// }

// class _SaveAppState extends State<SaveApp> with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   late PageController _pageController;
//   int _currentCarouselIndex = 0;
//   late AnimationController _animationController;
//   String selectedYear = '2025';
//   final List<String> years = ['2023', '2024', '2025', '2026'];

//   final List<String> _carouselImages = [
//     'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg',
//     'https://media.istockphoto.com/id/2064972148/photo/ai-concept-controlling-technological-tools-intelligent-robots-development-of-an-artificial.jpg?s=2048x2048&w=is&k=20&c=CSIqn-EAtpdA58shd1RpRY3Bmt5u0RbSQxBFwkYuxP8=',
//     'https://media.istockphoto.com/id/1182567852/photo/ai-artificial-intelligence-central-computer-processors-cpu-concept.jpg?s=2048x2048&w=is&k=20&c=QrkunbqSqCgjGwt2wghydHuyyR_yOV1fIUaXs6Ip7bg=',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: 0);
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _changePage(int index) {
//     setState(() {
//       _currentIndex = index;
//       _pageController.jumpToPage(index);
//     });
//   }

//   void _showChartDialog() {
//     HapticFeedback.mediumImpact();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: _buildChartDialogContent(context),
//         );
//       },
//     );
//   }

//   Widget _buildChartDialogContent(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       width: MediaQuery.of(context).size.width * 0.9,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: const BoxDecoration(
//               color: Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Income and Expenditure',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF008080),
//                   ),
//                 ),
//                 Container(
//                   width: 120,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.white,
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: ButtonTheme(
//                       alignedDropdown: true,
//                       child: DropdownButton<String>(
//                         value: selectedYear,
//                         icon: const Icon(Icons.keyboard_arrow_down),
//                         isExpanded: true,
//                         onChanged: (String? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               selectedYear = newValue;
//                             });
//                           }
//                         },
//                         items:
//                             years.map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SfCartesianChart(
//                 plotAreaBorderWidth: 0,
//                 primaryXAxis: CategoryAxis(
//                   majorGridLines: const MajorGridLines(
//                     width: 0.5,
//                     color: Colors.grey,
//                     dashArray: [5, 5],
//                   ),
//                   axisLine: const AxisLine(width: 0),
//                   labelStyle: const TextStyle(
//                     color: Colors.black87,
//                     fontSize: 12,
//                   ),
//                 ),
//                 primaryYAxis: NumericAxis(
//                   minimum: 2400,
//                   maximum: 3600,
//                   interval: 200,
//                   majorGridLines: const MajorGridLines(
//                     width: 0.5,
//                     color: Colors.grey,
//                     dashArray: [5, 5],
//                   ),
//                   axisLine: const AxisLine(width: 0),
//                   labelStyle: const TextStyle(
//                     color: Colors.black87,
//                     fontSize: 12,
//                   ),
//                   opposedPosition: false,
//                 ),
//                 legend: Legend(
//                   isVisible: true,
//                   position: LegendPosition.bottom,
//                   orientation: LegendItemOrientation.horizontal,
//                   textStyle: const TextStyle(fontSize: 12),
//                 ),
//                 tooltipBehavior: TooltipBehavior(enable: true),
//                 series: <CartesianSeries<FinancialData, String>>[
//                   ColumnSeries<FinancialData, String>(
//                     name: 'Income',
//                     dataSource: getChartData(),
//                     xValueMapper: (FinancialData data, _) => data.month,
//                     yValueMapper: (FinancialData data, _) => data.income,
//                     color: Colors.green.shade400,
//                     width: 0.6,
//                     spacing: 0.2,
//                     borderRadius: BorderRadius.circular(4),
//                     animationDuration: 1500,
//                     enableTooltip: true,
//                   ),
//                   ColumnSeries<FinancialData, String>(
//                     name: 'Expense',
//                     dataSource: getChartData(),
//                     xValueMapper: (FinancialData data, _) => data.month,
//                     yValueMapper: (FinancialData data, _) => data.expense,
//                     color: Colors.purple.shade300,
//                     width: 0.6,
//                     spacing: 0.2,
//                     borderRadius: BorderRadius.circular(4),
//                     animationDuration: 1500,
//                     enableTooltip: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Currency: USD',
//                   style: TextStyle(color: Colors.grey[700], fontSize: 12),
//                 ),
//                 Text(
//                   'Last updated: May 2025',
//                   style: TextStyle(color: Colors.grey[700], fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   child: const Text('Cancel'),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Chart exported successfully!'),
//                       ),
//                     );
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF008080),
//                   ),
//                   child: const Text('Export'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfffafafa),
//       body: Column(
//         children: [
//           _buildAppBar(),
//           Expanded(
//             child: PageView(
//               controller: _pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 _buildHomePage(),
//                 const ReportScreen(),
//                 const MoreScreen(),
//               ],
//             ),
//           ),
//           _buildBottomNavBar(),
//           _buildAndroidNavBar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHomePage() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCarouselSlider(),
//           _buildSectionHeader('My Money'),
//           _buildCategoryGrid(_moneyCategories),
//           _buildSectionHeader('My Belongings'),
//           _buildCategoryGrid(_belongingsCategories),
//           _buildSectionHeader('My Life'),
//           _buildCategoryGrid(_lifeCategories),
//           _buildSectionHeader('Utilities'),
//           _buildCategoryGrid(_utilitiesCategories),
//           _buildChartButton(),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       color: const Color(0xFFCFECEC),
//       padding: const EdgeInsets.only(
//         top: 40.0,
//         left: 16.0,
//         right: 16.0,
//         bottom: 10.0,
//       ),
//       child: Row(
//         children: [
//           Image.asset(Images.appbar, height: 50),
//           const SizedBox(width: 10),
//           const Text(
//             'My Personal App',
//             style: TextStyle(
//               color: Color(0xFF008080),
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_none,
//               color: Color(0xFF008080),
//               size: 28,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => NotificationScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(
//               Icons.settings,
//               color: Color(0xFF008080),
//               size: 28,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SettingsScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCarouselSlider() {
//     return Column(
//       children: [
//         const SizedBox(height: 10),
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 180.0,
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 0.9,
//             aspectRatio: 16 / 9,
//             autoPlayInterval: const Duration(seconds: 3),
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentCarouselIndex = index;
//               });
//             },
//           ),
//           items:
//               _carouselImages.map((imageUrl) {
//                 return Builder(
//                   builder: (BuildContext context) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 5.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             spreadRadius: 1,
//                             blurRadius: 5,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           imageUrl,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[300],
//                               child: const Center(
//                                 child: Text('Image not available'),
//                               ),
//                             );
//                           },
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value:
//                                     loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }).toList(),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children:
//               _carouselImages.asMap().entries.map((entry) {
//                 return Container(
//                   width: 8.0,
//                   height: 8.0,
//                   margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color:
//                         _currentCarouselIndex == entry.key
//                             ? const Color(0xFF008080)
//                             : Colors.grey.withOpacity(0.5),
//                   ),
//                 );
//               }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildChartButton() {
//     return Hero(
//       tag: 'chart-button',
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFF008080),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: _showChartDialog,
//             borderRadius: BorderRadius.circular(8),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.insert_chart_outlined, color: Colors.white),
//                   const SizedBox(width: 10),
//                   const Text(
//                     'View Financial Chart',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   List<FinancialData> getChartData() {
//     return [
//       FinancialData('Jan', 0, 0),
//       FinancialData('Feb', 0, 0),
//       FinancialData('Mar', 0, 0),
//       FinancialData('Apr', 0, 0),
//       FinancialData('May', 2500, 3600),
//       FinancialData('Jun', 0, 0),
//       FinancialData('Jul', 0, 0),
//       FinancialData('Aug', 0, 0),
//       FinancialData('Sep', 0, 0),
//       FinancialData('Oct', 0, 0),
//       FinancialData('Nov', 0, 0),
//       FinancialData('Dec', 0, 0),
//     ];
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid(List<CategoryItem> items) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 2,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: GridView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         padding: const EdgeInsets.all(10),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           childAspectRatio: 1,
//           crossAxisSpacing: 5,
//           mainAxisSpacing: 5,
//         ),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           final item = items[index];
//           return InkWell(
//             onTap:
//                 item.onPressed ??
//                 () {
//                   debugPrint('${item.label} tapped');
//                 },
//             borderRadius: BorderRadius.circular(8),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(item.icon, color: item.iconColor, size: 40),
//                 const SizedBox(height: 5),
//                 Text(
//                   item.label,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     return Container(
//       color: const Color(0xFF008080),
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(
//             Icons.home,
//             'Home',
//             _currentIndex == 0,
//             () => _changePage(0),
//           ),
//           _buildNavItem(
//             Icons.description_outlined,
//             'Report',
//             _currentIndex == 1,
//             () => _changePage(1),
//           ),
//           _buildNavItem(
//             Icons.more_horiz,
//             'More',
//             _currentIndex == 2,
//             () => _changePage(2),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAndroidNavBar() {
//     return Container(
//       height: 48,
//       color: Colors.black,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: const [
//           Icon(Icons.arrow_back, color: Colors.white),
//           Icon(Icons.circle_outlined, color: Colors.white),
//           Icon(Icons.crop_square, color: Colors.white),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(
//     IconData icon,
//     String label,
//     bool isSelected,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white),
//           Text(
//             label,
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           if (isSelected)
//             Container(
//               height: 4,
//               width: 60,
//               color: Colors.red,
//               margin: const EdgeInsets.only(top: 4),
//             ),
//         ],
//       ),
//     );
//   }

//   final List<CategoryItem> _moneyCategories = [
//     CategoryItem(
//       icon: Icons.credit_card,
//       label: 'Payments',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Payments tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.receipt,
//       label: 'Receipts',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Receipts tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.account_balance_wallet,
//       label: 'Wallet',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Wallet tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.business_center,
//       label: 'Budget',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Budget tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.account_balance,
//       label: 'Bank',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Bank tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.book,
//       label: 'Journal',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Journal tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.description,
//       label: 'Billing',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Billing tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.monetization_on,
//       label: 'Cash and Bank',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Cash and Bank tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.calculate,
//       label: 'Account Setup',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Account Setup tapped'),
//     ),
//   ];

//   final List<CategoryItem> _belongingsCategories = [
//     CategoryItem(
//       icon: Icons.trending_up,
//       label: 'Investment',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Investment tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.lock,
//       label: 'Password Manager',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Password Manager tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.description,
//       label: 'Document Manager',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Document Manager tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.account_balance_wallet,
//       label: 'Asset',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Asset tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.note_alt,
//       label: 'Liability',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Liability tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.security,
//       label: 'Insurance',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Insurance tapped'),
//     ),
//   ];

//   final List<CategoryItem> _lifeCategories = [
//     CategoryItem(
//       icon: Icons.task_alt,
//       label: 'Task',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Task tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.book,
//       label: 'Diary',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Diary tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.add_circle_outline,
//       label: 'Dream',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Dream tapped'),
//     ),
//   ];

//   final List<CategoryItem> _utilitiesCategories = [
//     CategoryItem(
//       icon: Icons.smartphone,
//       label: 'Mobile Recharge',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Mobile Recharge tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.satellite_alt,
//       label: 'DTH Recharge',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('DTH Recharge tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.contact_mail,
//       label: 'Visiting Card',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Visiting Card tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.link,
//       label: 'Website Links',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Website Links tapped'),
//     ),
//     CategoryItem(
//       icon: Icons.warning,
//       label: 'Emergency Numbers',
//       iconColor: Colors.teal,
//       onPressed: () => debugPrint('Emergency Numbers tapped'),
//     ),
//   ];
// }

// class CategoryItem {
//   final IconData icon;
//   final String label;
//   final Color iconColor;
//   final VoidCallback? onPressed;

//   CategoryItem({
//     required this.icon,
//     required this.label,
//     required this.iconColor,
//     this.onPressed,
//   });
// }

// class FinancialData {
//   final String month;
//   final double income;
//   final double expense;

//   FinancialData(this.month, this.income, this.expense);
// }

// class ReportScreen extends StatelessWidget {
//   const ReportScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             color: const Color(0xFFCFECEC),
//             padding: const EdgeInsets.only(
//               top: 40.0,
//               left: 16.0,
//               right: 16.0,
//               bottom: 10.0,
//             ),
//             child: const Row(
//               children: [
//                 Text(
//                   'Reports',
//                   style: TextStyle(
//                     color: Color(0xFF008080),
//                     fontSize: 20,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'Financial Reports',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 15),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 2,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: const Text(
//               'View your financial reports here.',
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class MoreScreen extends StatelessWidget {
// //   const MoreScreen({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Container(
// //             color: const Color(0xFFCFECEC),
// //             padding: const EdgeInsets.only(
// //               top: 40.0,
// //               left: 16.0,
// //               right: 16.0,
// //               bottom: 10.0,
// //             ),
// //             child: const Row(
// //               children: [
// //                 Text(
// //                   'More',
// //                   style: TextStyle(
// //                     color: Color(0xFF008080),
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const Padding(
// //             padding: EdgeInsets.all(16.0),
// //             child: Text(
// //               'Additional Options',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //           Container(
// //             margin: const EdgeInsets.symmetric(horizontal: 15),
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(8),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 2,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 ListTile(
// //                   leading: const Icon(Icons.info, color: Colors.teal),
// //                   title: const Text('About'),
// //                   onTap: () => debugPrint('About tapped'),
// //                 ),
// //                 ListTile(
// //                   leading: const Icon(Icons.support, color: Colors.teal),
// //                   title: const Text('Support'),
// //                   onTap: () => debugPrint('Support tapped'),
// //                 ),
// //                 ListTile(
// //                   leading: const Icon(Icons.logout, color: Colors.teal),
// //                   title: const Text('Logout'),
// //                   onTap: () => debugPrint('Logout tapped'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
