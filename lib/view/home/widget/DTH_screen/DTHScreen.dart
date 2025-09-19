// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(DTHRechargeApp());
// }

// class DTHRechargeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'DTH Recharge Pro',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: DTHOperatorsGridScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class DTHOperator {
//   final String name;
//   final String logo;
//   final List<Color> colors;
//   final String subtitle;
//   final double rating;
//   final int users;

//   DTHOperator(
//     this.name,
//     this.logo,
//     this.colors,
//     this.subtitle,
//     this.rating,
//     this.users,
//   );
// }

// class DTHOperatorsGridScreen extends StatefulWidget {
//   @override
//   _DTHOperatorsGridScreenState createState() => _DTHOperatorsGridScreenState();
// }

// class _DTHOperatorsGridScreenState extends State<DTHOperatorsGridScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _floatingController;
//   late AnimationController _shimmerController;
//   late AnimationController _staggerController;

//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _floatingAnimation;
//   late Animation<double> _shimmerAnimation;

//   final List<DTHOperator> operators = [
//     DTHOperator(
//       'Airtel Digital TV',
//       'assets/airtel.png',
//       [Color(0xFFE74C3C), Color(0xFFFF6B6B)],
//       'India\'s Fastest DTH',
//       4.5,
//       25000000,
//     ),
//     DTHOperator(
//       'Dish TV',
//       'assets/dish.png',
//       [Color(0xFFFF6F00), Color(0xFFFFB74D)],
//       'Entertainment Redefined',
//       4.3,
//       18000000,
//     ),
//     DTHOperator(
//       'Sun Direct',
//       'assets/sun.png',
//       [Color(0xFFD32F2F), Color(0xFFEF5350)],
//       'South India\'s Choice',
//       4.4,
//       12000000,
//     ),
//     DTHOperator(
//       'Tata Sky',
//       'assets/tata.png',
//       [Color(0xFF1976D2), Color(0xFF42A5F5)],
//       'Isko Laga Dala Toh Life Jingalala',
//       4.6,
//       22000000,
//     ),
//     DTHOperator(
//       'Videocon D2H',
//       'assets/d2h.png',
//       [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
//       'Digital Entertainment',
//       4.2,
//       8000000,
//     ),
//     DTHOperator(
//       'DD Free Dish',
//       'assets/dd.png',
//       [Color(0xFF2E7D32), Color(0xFF66BB6A)],
//       'Free to Air Service',
//       4.0,
//       35000000,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _floatingController = AnimationController(
//       duration: Duration(milliseconds: 4000),
//       vsync: this,
//     )..repeat(reverse: true);
//     _shimmerController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat();
//     _staggerController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
//       CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//     );
//     _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
//       CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
//     );

//     _animationController.forward();
//     _staggerController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _floatingController.dispose();
//     _shimmerController.dispose();
//     _staggerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF667eea),
//               Color(0xFF764ba2),
//               Color(0xFF4B0082),
//               Color(0xFF2D1B69),
//             ],
//             stops: [0.0, 0.3, 0.7, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildEnhancedHeader(),
//               _buildStatsBar(),
//               Expanded(
//                 child: AnimatedContainer(
//                   duration: Duration(milliseconds: 1000),
//                   curve: Curves.easeOutCubic,
//                   margin: EdgeInsets.only(top: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 30,
//                         offset: Offset(0, -15),
//                       ),
//                     ],
//                   ),
//                   child: _buildOperatorsGrid(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedHeader() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Transform.translate(
//         offset: Offset(0, _slideAnimation.value),
//         child: Container(
//           padding: EdgeInsets.all(25),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: Colors.white.withOpacity(0.4)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.arrow_back_ios_new,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   Spacer(),
//                   AnimatedBuilder(
//                     animation: _floatingAnimation,
//                     builder: (context, child) {
//                       return Transform.translate(
//                         offset: Offset(0, _floatingAnimation.value * 0.5),
//                         child: ShaderMask(
//                           shaderCallback:
//                               (bounds) => LinearGradient(
//                                 colors: [
//                                   Colors.white,
//                                   Colors.white70,
//                                   Colors.white,
//                                 ],
//                                 stops: [0.0, 0.5, 1.0],
//                               ).createShader(bounds),
//                           child: Text(
//                             'DTH Recharge Pro',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 1.5,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   offset: Offset(0, 2),
//                                   blurRadius: 5,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   Spacer(),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: Colors.white.withOpacity(0.4)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.notifications_active,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 25),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.95),
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 25,
//                       offset: Offset(0, 12),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0xFF667eea).withOpacity(0.4),
//                             blurRadius: 8,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Icon(Icons.search, color: Colors.white, size: 22),
//                     ),
//                     SizedBox(width: 18),
//                     Expanded(
//                       child: Text(
//                         'Search operators, plans & more...',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Icon(
//                         Icons.tune,
//                         color: Colors.grey.shade600,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsBar() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withOpacity(0.3)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             _buildStatItem('6+', 'Operators', Icons.tv),
//             _buildStatDivider(),
//             _buildStatItem('120M+', 'Users', Icons.people),
//             _buildStatDivider(),
//             _buildStatItem('99.9%', 'Success', Icons.verified),
//             _buildStatDivider(),
//             _buildStatItem('24/7', 'Support', Icons.support_agent),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String value, String label, IconData icon) {
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.white, size: 16),
//           SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatDivider() {
//     return Container(
//       height: 30,
//       width: 1,
//       color: Colors.white.withOpacity(0.3),
//     );
//   }

//   Widget _buildOperatorsGrid() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 5,
//                   height: 35,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ),
//                 SizedBox(width: 18),
//                 Expanded(
//                   child: Text(
//                     'Choose Your DTH Provider',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.grey.shade800,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//                 AnimatedBuilder(
//                   animation: _shimmerController,
//                   builder: (context, child) {
//                     return Transform.rotate(
//                       angle: _shimmerAnimation.value * 0.15,
//                       child: Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.amber, Colors.orange],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.amber.withOpacity(0.4),
//                               blurRadius: 8,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Icon(Icons.star, color: Colors.white, size: 20),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 15,
//                   childAspectRatio: 0.85,
//                 ),
//                 itemCount: operators.length,
//                 itemBuilder: (context, index) {
//                   return AnimatedBuilder(
//                     animation: _staggerController,
//                     builder: (context, child) {
//                       final animationValue = Interval(
//                         (index * 0.1).clamp(0.0, 1.0),
//                         ((index * 0.1) + 0.3).clamp(0.0, 1.0),
//                         curve: Curves.elasticOut,
//                       ).transform(_staggerController.value);

//                       return Transform.translate(
//                         offset: Offset(0, 50 * (1 - animationValue)),
//                         child: Opacity(
//                           opacity: animationValue,
//                           child: _buildEnhancedOperatorCard(
//                             operators[index],
//                             index,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//           _buildQuickActions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedOperatorCard(DTHOperator operator, int index) {
//     return AnimatedBuilder(
//       animation: _floatingController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(
//             0,
//             _floatingAnimation.value * 0.2 * (index % 2 == 0 ? 1 : -1),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white,
//                   operator.colors[0].withOpacity(0.05),
//                   operator.colors[1].withOpacity(0.1),
//                 ],
//                 stops: [0.0, 0.6, 1.0],
//               ),
//               border: Border.all(
//                 color: operator.colors[0].withOpacity(0.2),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: operator.colors[0].withOpacity(0.15),
//                   blurRadius: 20,
//                   offset: Offset(0, 10),
//                   spreadRadius: 2,
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(25),
//                 onTap: () {
//                   HapticFeedback.mediumImpact();
//                   _navigateToPlanSelection(operator);
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header with logo and rating
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Hero(
//                             tag: 'operator_${operator.name}',
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: operator.colors,
//                                 ),
//                                 borderRadius: BorderRadius.circular(18),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: operator.colors[0].withOpacity(0.4),
//                                     blurRadius: 15,
//                                     offset: Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: Icon(
//                                 _getOperatorIcon(operator.name),
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//                           ),
//                           Spacer(),
//                           Column(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.amber.shade100,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       color: Colors.amber,
//                                       size: 12,
//                                     ),
//                                     SizedBox(width: 2),
//                                     Text(
//                                       '${operator.rating}',
//                                       style: TextStyle(
//                                         color: Colors.amber.shade800,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: operator.colors,
//                                   ),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   'INSTANT',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 8,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 15),

//                       // Operator Name
//                       Text(
//                         operator.name,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.grey.shade800,
//                           letterSpacing: 0.3,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       SizedBox(height: 6),

//                       // Subtitle
//                       Text(
//                         operator.subtitle,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           height: 1.2,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       Spacer(),

//                       // Users count and action button
//                       Row(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${_formatUsers(operator.users)}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: operator.colors[0],
//                                 ),
//                               ),
//                               Text(
//                                 'Users',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Spacer(),
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: operator.colors),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: operator.colors[0].withOpacity(0.4),
//                                   blurRadius: 8,
//                                   offset: Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               Icons.arrow_forward_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 10),

//                       // Feature badges
//                       Row(
//                         children: [
//                           _buildMiniFeatureBadge('HD', operator.colors[0]),
//                           SizedBox(width: 6),
//                           _buildMiniFeatureBadge('4K', operator.colors[1]),
//                           SizedBox(width: 6),
//                           _buildMiniFeatureBadge('Sports', Colors.green),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMiniFeatureBadge(String text, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 8,
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   String _formatUsers(int users) {
//     if (users >= 1000000) {
//       return '${(users / 1000000).toStringAsFixed(0)}M+';
//     } else if (users >= 1000) {
//       return '${(users / 1000).toStringAsFixed(0)}K+';
//     }
//     return users.toString();
//   }

//   Widget _buildQuickActions() {
//     return Container(
//       height: 100,
//       margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildQuickActionCard('History', Icons.history, Colors.blue),
//           ),
//           SizedBox(width: 15),
//           Expanded(
//             child: _buildQuickActionCard(
//               'Auto Pay',
//               Icons.autorenew,
//               Colors.green,
//             ),
//           ),
//           SizedBox(width: 15),
//           Expanded(
//             child: _buildQuickActionCard(
//               'Offers',
//               Icons.local_offer,
//               Colors.orange,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionCard(String title, IconData icon, Color color) {
//     return AnimatedBuilder(
//       animation: _floatingController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _floatingAnimation.value * 0.15),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [color.withOpacity(0.1), Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: color.withOpacity(0.3), width: 1.5),
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.15),
//                   blurRadius: 10,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(18),
//                 onTap: () => HapticFeedback.lightImpact(),
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(icon, color: color, size: 24),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         title,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.grey.shade700,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   IconData _getOperatorIcon(String operatorName) {
//     switch (operatorName) {
//       case 'Airtel Digital TV':
//         return Icons.satellite_alt;
//       case 'Dish TV':
//         return Icons.tv;
//       case 'Sun Direct':
//         return Icons.wb_sunny;
//       case 'Tata Sky':
//         return Icons.live_tv;
//       case 'Videocon D2H':
//         return Icons.video_settings;
//       case 'DD Free Dish':
//         return Icons.public;
//       default:
//         return Icons.tv;
//     }
//   }

//   void _navigateToPlanSelection(DTHOperator operator) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder:
//             (context, animation, secondaryAnimation) =>
//                 PlanSelectionScreen(operator: operator),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(
//               CurvedAnimation(parent: animation, curve: Curves.elasticOut),
//             ),
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: Duration(milliseconds: 1000),
//       ),
//     );
//   }
// }

// class RechargeOption {
//   final String name;
//   final double price;
//   final String duration;
//   final String description;
//   final List<Color> colors;

//   RechargeOption(
//     this.name,
//     this.price,
//     this.duration,
//     this.description,
//     this.colors,
//   );
// }

// // Placeholder for the plan selection screen

// class PlanSelectionScreen extends StatefulWidget {
//   final DTHOperator operator;

//   PlanSelectionScreen({required this.operator});

//   @override
//   _PlanSelectionScreenState createState() => _PlanSelectionScreenState();
// }

// class _PlanSelectionScreenState extends State<PlanSelectionScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _categoryController;
//   late AnimationController _pulseController;
//   late Animation<double> _headerAnimation;
//   late Animation<double> _listAnimation;
//   late Animation<double> _pulseAnimation;
//   String selectedCategory = 'COMBO';
//   TextEditingController searchController = TextEditingController();

//   final List<RechargeOption> rechargeOptions = [
//     RechargeOption('MY FTA', 98.0, '1 month', 'Free to Air channels', [
//       Colors.green,
//       Colors.green.shade400,
//     ]),
//     RechargeOption('NCF Basic', 99.0, '1 month', 'Network Capacity Fee', [
//       Colors.blue,
//       Colors.blue.shade400,
//     ]),
//     RechargeOption(
//       'HD Odia Economy',
//       226.0,
//       '1 month',
//       'HD channels + Regional',
//       [Colors.orange, Colors.orange.shade400],
//     ),
//     RechargeOption(
//       'HD Odia Premium',
//       676.0,
//       '3 months',
//       'HD channels + Premium Regional',
//       [Colors.purple, Colors.purple.shade400],
//     ),
//     RechargeOption(
//       'Ultimate Pack',
//       1299.0,
//       '6 months',
//       'All channels + Premium + Sports',
//       [Colors.red, Colors.red.shade400],
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _categoryController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _pulseController = AnimationController(
//       duration: Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);

//     _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//     _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//     _categoryController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _categoryController.dispose();
//     _pulseController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               widget.operator.colors[0].withOpacity(0.9),
//               widget.operator.colors[1].withOpacity(0.7),
//               widget.operator.colors[0].withOpacity(0.5),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildEnhancedPlanHeader(),
//               _buildAnimatedSearchBar(),
//               _buildEnhancedCategorySelector(),
//               Expanded(child: _buildAnimatedPlansList()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedPlanHeader() {
//     return FadeTransition(
//       opacity: _headerAnimation,
//       child: Container(
//         padding: EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: IconButton(
//                 icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             SizedBox(width: 15),
//             Hero(
//               tag: 'operator_${widget.operator.name}',
//               child: Container(
//                 width: 55,
//                 height: 55,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 15,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _getOperatorIcon(widget.operator.name),
//                   color: widget.operator.colors[0],
//                   size: 28,
//                 ),
//               ),
//             ),
//             SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.operator.name,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Choose your perfect plan',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: IconButton(
//                 icon: Icon(Icons.favorite_border, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedSearchBar() {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: Offset(0, -1),
//         end: Offset.zero,
//       ).animate(_headerAnimation),
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.15),
//               blurRadius: 20,
//               offset: Offset(0, 10),
//             ),
//           ],
//         ),
//         child: TextField(
//           controller: searchController,
//           decoration: InputDecoration(
//             hintText: 'Search by amount, channels or name...',
//             prefixIcon: Container(
//               margin: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(colors: widget.operator.colors),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(Icons.search, color: Colors.white),
//             ),
//             suffixIcon: Container(
//               margin: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(Icons.mic, color: Colors.grey.shade600),
//             ),
//             border: InputBorder.none,
//             contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//           ),
//           onChanged: (value) => setState(() {}),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedCategorySelector() {
//     final categories = [
//       {'name': 'COMBO', 'icon': Icons.apps},
//       {'name': 'BASIC', 'icon': Icons.tv_outlined},
//       {'name': 'PREMIUM', 'icon': Icons.star},
//       {'name': 'REGIONAL', 'icon': Icons.language},
//     ];

//     return Container(
//       height: 80,
//       margin: EdgeInsets.symmetric(vertical: 20),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           final isSelected = selectedCategory == category['name'];

//           return AnimatedContainer(
//             duration: Duration(milliseconds: 400),
//             curve: Curves.elasticOut,
//             margin: EdgeInsets.only(right: 15),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category['name'] as String;
//                 });
//                 HapticFeedback.selectionClick();
//               },
//               child: Container(
//                 width: 90,
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                 decoration: BoxDecoration(
//                   gradient:
//                       isSelected
//                           ? LinearGradient(colors: widget.operator.colors)
//                           : LinearGradient(
//                             colors: [
//                               Colors.white.withOpacity(0.3),
//                               Colors.white.withOpacity(0.1),
//                             ],
//                           ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color:
//                         isSelected
//                             ? Colors.white.withOpacity(0.5)
//                             : Colors.white.withOpacity(0.3),
//                     width: 1.5,
//                   ),
//                   boxShadow:
//                       isSelected
//                           ? [
//                             BoxShadow(
//                               color: widget.operator.colors[0].withOpacity(0.3),
//                               blurRadius: 15,
//                               offset: Offset(0, 8),
//                             ),
//                           ]
//                           : [],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       category['icon'] as IconData,
//                       color:
//                           isSelected
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.8),
//                       size: 20,
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       category['name'] as String,
//                       style: TextStyle(
//                         color:
//                             isSelected
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.8),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAnimatedPlansList() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.grey.shade50, Colors.white],
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(40),
//           topRight: Radius.circular(40),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: Offset(0, -10),
//           ),
//         ],
//       ),
//       child: ListView.builder(
//         padding: EdgeInsets.all(25),
//         itemCount: rechargeOptions.length,
//         itemBuilder: (context, index) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(
//               CurvedAnimation(
//                 parent: _animationController,
//                 curve: Interval(index * 0.15, 1.0, curve: Curves.elasticOut),
//               ),
//             ),
//             child: _buildEnhancedPlanCard(rechargeOptions[index], index),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEnhancedPlanCard(RechargeOption option, int index) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: option.colors[0].withOpacity(0.1),
//             blurRadius: 20,
//             offset: Offset(0, 10),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(25),
//           onTap: () {
//             HapticFeedback.lightImpact();
//             Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         PaymentScreen(operator: widget.operator, plan: option),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return FadeTransition(
//                     opacity: animation,
//                     child: ScaleTransition(
//                       scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//                         CurvedAnimation(
//                           parent: animation,
//                           curve: Curves.elasticOut,
//                         ),
//                       ),
//                       child: child,
//                     ),
//                   );
//                 },
//                 transitionDuration: Duration(milliseconds: 600),
//               ),
//             );
//           },
//           child: Container(
//             padding: EdgeInsets.all(25),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   option.colors[0].withOpacity(0.05),
//                   option.colors[1].withOpacity(0.02),
//                   Colors.white,
//                 ],
//                 stops: [0.0, 0.3, 1.0],
//               ),
//               border: Border.all(
//                 color: option.colors[0].withOpacity(0.15),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 75,
//                   height: 75,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: option.colors,
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: option.colors[0].withOpacity(0.4),
//                         blurRadius: 15,
//                         offset: Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Icon(Icons.live_tv, color: Colors.white, size: 35),
//                 ),
//                 SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               option.name,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey.shade800,
//                               ),
//                             ),
//                           ),
//                           AnimatedBuilder(
//                             animation: _pulseAnimation,
//                             builder: (context, child) {
//                               return Transform.scale(
//                                 scale: _pulseAnimation.value,
//                                 child: Text(
//                                   '₹${option.price.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: option.colors[0],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         option.description,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey.shade600,
//                           height: 1.3,
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: option.colors),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.schedule,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   option.duration,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade100,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.verified,
//                                   color: Colors.green,
//                                   size: 14,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   'Verified',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Spacer(),
//                           Container(
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: option.colors),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Icon(
//                               Icons.arrow_forward,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getOperatorIcon(String operatorName) {
//     switch (operatorName) {
//       case 'Airtel Digital TV':
//         return Icons.satellite_alt;
//       case 'Dish TV':
//         return Icons.tv;
//       case 'Sun Direct':
//         return Icons.wb_sunny;
//       case 'Tata Sky':
//         return Icons.live_tv;
//       case 'Videocon D2H':
//         return Icons.video_settings;
//       default:
//         return Icons.tv;
//     }
//   }
// }

// class PaymentMethod {
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   PaymentMethod(this.name, this.icon, this.description, this.color);
// }

// class PaymentScreen extends StatefulWidget {
//   final DTHOperator operator;
//   final RechargeOption plan;

//   PaymentScreen({required this.operator, required this.plan});

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _progressController;
//   late AnimationController _buttonController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _progressAnimation;
//   late Animation<double> _buttonAnimation;
//   String selectedPaymentMethod = 'UPI';
//   bool isProcessing = false;

//   final List<PaymentMethod> paymentMethods = [
//     PaymentMethod(
//       'UPI',
//       Icons.account_balance_wallet,
//       'No convenience charges',
//       Colors.indigo,
//     ),
//     PaymentMethod(
//       'Credit Card',
//       Icons.credit_card,
//       '2% convenience charges',
//       Colors.blue,
//     ),
//     PaymentMethod(
//       'Debit Card',
//       Icons.payment,
//       '1% convenience charges',
//       Colors.teal,
//     ),
//     PaymentMethod(
//       'Net Banking',
//       Icons.account_balance,
//       'No convenience charges',
//       Colors.green,
//     ),
//     PaymentMethod('Wallet', Icons.wallet, 'Instant payment', Colors.orange),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _progressController = AnimationController(
//       duration: Duration(milliseconds: 3000),
//       vsync: this,
//     );
//     _buttonController = AnimationController(
//       duration: Duration(milliseconds: 200),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
//     );
//     _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _progressController.dispose();
//     _buttonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               widget.operator.colors[0].withOpacity(0.9),
//               widget.operator.colors[1].withOpacity(0.7),
//               widget.operator.colors[0].withOpacity(0.5),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildPaymentHeader(),
//               Expanded(
//                 child: Container(
//                   margin: EdgeInsets.only(top: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         offset: Offset(0, -10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildEnhancedPlanSummary(),
//                       _buildEnhancedPaymentMethods(),
//                       _buildEnhancedPaymentButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentHeader() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: Colors.white.withOpacity(0.3)),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           Spacer(),
//           ShaderMask(
//             shaderCallback:
//                 (bounds) => LinearGradient(
//                   colors: [Colors.white, Colors.white70],
//                 ).createShader(bounds),
//             child: Text(
//               'Secure Payment',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.1,
//               ),
//             ),
//           ),
//           Spacer(),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: Colors.white.withOpacity(0.3)),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.security, color: Colors.white),
//               onPressed: () {},
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedPlanSummary() {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         margin: EdgeInsets.all(25),
//         padding: EdgeInsets.all(25),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               widget.plan.colors[0].withOpacity(0.1),
//               widget.plan.colors[1].withOpacity(0.05),
//               Colors.white,
//             ],
//             stops: [0.0, 0.3, 1.0],
//           ),
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: widget.plan.colors[0].withOpacity(0.2)),
//           boxShadow: [
//             BoxShadow(
//               color: widget.plan.colors[0].withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 65,
//                   height: 65,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: widget.plan.colors),
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: widget.plan.colors[0].withOpacity(0.4),
//                         blurRadius: 15,
//                         offset: Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Icon(Icons.live_tv, color: Colors.white, size: 30),
//                 ),
//                 SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.plan.name,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey.shade800,
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         widget.plan.description,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '₹${widget.plan.price.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: widget.plan.colors[0],
//                       ),
//                     ),
//                     Text(
//                       'Total Amount',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green.shade50, Colors.green.shade100],
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.verified_user, color: Colors.green, size: 24),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Instant Activation',
//                           style: TextStyle(
//                             color: Colors.green.shade700,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           'Valid for ${widget.plan.duration} • 24/7 Support',
//                           style: TextStyle(
//                             color: Colors.green.shade600,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedPaymentMethods() {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 25),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: widget.operator.colors),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Choose Payment Method',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: paymentMethods.length,
//                 itemBuilder: (context, index) {
//                   final method = paymentMethods[index];
//                   final isSelected = selectedPaymentMethod == method.name;

//                   return AnimatedContainer(
//                     duration: Duration(milliseconds: 400),
//                     curve: Curves.elasticOut,
//                     margin: EdgeInsets.only(bottom: 15),
//                     decoration: BoxDecoration(
//                       color:
//                           isSelected
//                               ? method.color.withOpacity(0.1)
//                               : Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected ? method.color : Colors.grey.shade300,
//                         width: isSelected ? 2 : 1,
//                       ),
//                       boxShadow:
//                           isSelected
//                               ? [
//                                 BoxShadow(
//                                   color: method.color.withOpacity(0.2),
//                                   blurRadius: 15,
//                                   offset: Offset(0, 8),
//                                 ),
//                               ]
//                               : [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 5,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(20),
//                         onTap: () {
//                           setState(() {
//                             selectedPaymentMethod = method.name;
//                           });
//                           HapticFeedback.selectionClick();
//                         },
//                         child: Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 55,
//                                 height: 55,
//                                 decoration: BoxDecoration(
//                                   gradient:
//                                       isSelected
//                                           ? LinearGradient(
//                                             colors: [
//                                               method.color,
//                                               method.color.withOpacity(0.8),
//                                             ],
//                                           )
//                                           : LinearGradient(
//                                             colors: [
//                                               Colors.grey.shade100,
//                                               Colors.grey.shade200,
//                                             ],
//                                           ),
//                                   borderRadius: BorderRadius.circular(15),
//                                   boxShadow:
//                                       isSelected
//                                           ? [
//                                             BoxShadow(
//                                               color: method.color.withOpacity(
//                                                 0.3,
//                                               ),
//                                               blurRadius: 10,
//                                               offset: Offset(0, 5),
//                                             ),
//                                           ]
//                                           : [],
//                                 ),
//                                 child: Icon(
//                                   method.icon,
//                                   color:
//                                       isSelected
//                                           ? Colors.white
//                                           : Colors.grey.shade600,
//                                   size: 28,
//                                 ),
//                               ),
//                               SizedBox(width: 18),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       method.name,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 17,
//                                         color:
//                                             isSelected
//                                                 ? method.color
//                                                 : Colors.grey.shade800,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       method.description,
//                                       style: TextStyle(
//                                         color: Colors.grey.shade600,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color:
//                                         isSelected
//                                             ? method.color
//                                             : Colors.grey.shade400,
//                                     width: 2,
//                                   ),
//                                   color:
//                                       isSelected
//                                           ? method.color
//                                           : Colors.transparent,
//                                 ),
//                                 child:
//                                     isSelected
//                                         ? Icon(
//                                           Icons.check,
//                                           color: Colors.white,
//                                           size: 16,
//                                         )
//                                         : null,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedPaymentButton() {
//     return Container(
//       padding: EdgeInsets.all(25),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey.shade50, Colors.grey.shade100],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Amount',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     Text(
//                       '₹${widget.plan.price.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: widget.operator.colors[0],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: widget.operator.colors),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Text(
//                     'SECURE',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           if (isProcessing)
//             Container(
//               height: 65,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(colors: widget.operator.colors),
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.operator.colors[0].withOpacity(0.4),
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 3,
//                       ),
//                     ),
//                     SizedBox(width: 15),
//                     Text(
//                       'Processing Payment...',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             ScaleTransition(
//               scale: _buttonAnimation,
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 65,
//                 child: ElevatedButton(
//                   onPressed: _processPayment,
//                   // onTapDown: (_) => _buttonController.forward(),
//                   // onTapUp: (_) => _buttonController.reverse(),
//                   // onTapCancel: () => _buttonController.reverse(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: widget.operator.colors),
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: widget.operator.colors[0].withOpacity(0.4),
//                           blurRadius: 20,
//                           offset: Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Container(
//                       alignment: Alignment.center,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.security, color: Colors.white, size: 24),
//                           SizedBox(width: 12),
//                           Text(
//                             'Pay ₹${widget.plan.price.toStringAsFixed(0)} Securely',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.lock, color: Colors.green, size: 16),
//               SizedBox(width: 8),
//               Text(
//                 '256-bit SSL encrypted • PCI DSS compliant',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _processPayment() async {
//     setState(() {
//       isProcessing = true;
//     });

//     HapticFeedback.mediumImpact();
//     _progressController.forward();

//     // Simulate payment processing delay
//     await Future.delayed(Duration(seconds: 3));

//     // Show success dialog
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return EnhancedSuccessDialog(
//             operator: widget.operator,
//             plan: widget.plan,
//             paymentMethod: selectedPaymentMethod,
//           );
//         },
//       );
//     }

//     setState(() {
//       isProcessing = false;
//     });

//     _progressController.reset();
//   }
// }

// class EnhancedSuccessDialog extends StatefulWidget {
//   final DTHOperator operator;
//   final RechargeOption plan;
//   final String paymentMethod;

//   EnhancedSuccessDialog({
//     required this.operator,
//     required this.plan,
//     required this.paymentMethod,
//   });

//   @override
//   _EnhancedSuccessDialogState createState() => _EnhancedSuccessDialogState();
// }

// class _EnhancedSuccessDialogState extends State<EnhancedSuccessDialog>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _successController;
//   late AnimationController _confettiController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _successAnimation;
//   late Animation<double> _confettiAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _mainController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _successController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _confettiController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
//     );
//     _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _successController, curve: Curves.bounceOut),
//     );
//     _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
//     );

//     _startAnimations();
//   }

//   void _startAnimations() async {
//     _mainController.forward();
//     await Future.delayed(Duration(milliseconds: 300));
//     _successController.forward();
//     await Future.delayed(Duration(milliseconds: 200));
//     _confettiController.forward();
//   }

//   @override
//   void dispose() {
//     _mainController.dispose();
//     _successController.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           margin: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 30,
//                 offset: Offset(0, 15),
//               ),
//             ],
//           ),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [_buildConfettiEffect(), _buildDialogContent()],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildConfettiEffect() {
//     return AnimatedBuilder(
//       animation: _confettiAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: CustomPaint(
//             painter: ConfettiPainter(_confettiAnimation.value),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDialogContent() {
//     return Padding(
//       padding: EdgeInsets.all(30),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ScaleTransition(
//             scale: _successAnimation,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green, Colors.green.shade400],
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.green.withOpacity(0.4),
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
//             ),
//           ),
//           SizedBox(height: 25),
//           ShaderMask(
//             shaderCallback:
//                 (bounds) => LinearGradient(
//                   colors: [Colors.green, Colors.green.shade600],
//                 ).createShader(bounds),
//             child: Text(
//               'Payment Successful!',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             'Your DTH recharge has been completed successfully.\nYou will receive a confirmation shortly.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//               height: 1.4,
//             ),
//           ),
//           SizedBox(height: 25),
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey.shade50, Colors.grey.shade100],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               children: [
//                 _buildSummaryRow('Operator', widget.operator.name, Icons.tv),
//                 _buildSummaryRow('Plan', widget.plan.name, Icons.subscriptions),
//                 _buildSummaryRow(
//                   'Amount',
//                   '₹${widget.plan.price.toStringAsFixed(0)}',
//                   Icons.currency_rupee,
//                 ),
//                 _buildSummaryRow(
//                   'Payment',
//                   widget.paymentMethod,
//                   Icons.payment,
//                 ),
//                 _buildSummaryRow(
//                   'Transaction ID',
//                   'TXN${DateTime.now().millisecondsSinceEpoch}',
//                   Icons.receipt_long,
//                 ),
//                 _buildSummaryRow(
//                   'Status',
//                   'Completed',
//                   Icons.verified,
//                   isStatus: true,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 25),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 55,
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pop();
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         color: widget.operator.colors[0],
//                         width: 2,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                     icon: Icon(Icons.home, color: widget.operator.colors[0]),
//                     label: Text(
//                       'HOME',
//                       style: TextStyle(
//                         color: widget.operator.colors[0],
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 15),
//               Expanded(
//                 child: Container(
//                   height: 55,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: widget.operator.colors),
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: widget.operator.colors[0].withOpacity(0.4),
//                         blurRadius: 15,
//                         offset: Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       HapticFeedback.lightImpact();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                     icon: Icon(Icons.share, color: Colors.white),
//                     label: Text(
//                       'SHARE',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(
//     String label,
//     String value,
//     IconData icon, {
//     bool isStatus = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isStatus ? Colors.green.shade100 : Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               size: 18,
//               color: isStatus ? Colors.green.shade700 : Colors.grey.shade600,
//             ),
//           ),
//           SizedBox(width: 15),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: isStatus ? Colors.green.shade700 : Colors.grey.shade800,
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ConfettiPainter extends CustomPainter {
//   final double animationValue;

//   ConfettiPainter(this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();
//     final random = DateTime.now().millisecondsSinceEpoch;

//     for (int i = 0; i < 50; i++) {
//       final x = (random + i * 123) % size.width.toInt();
//       final y = size.height * animationValue + (random + i * 456) % 100 - 50;

//       paint.color = [
//         Colors.red,
//         Colors.blue,
//         Colors.green,
//         Colors.orange,
//         Colors.purple,
//         Colors.pink,
//       ][i % 6].withOpacity(0.8);

//       canvas.drawCircle(Offset(x.toDouble(), y), 3 + (i % 3), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
