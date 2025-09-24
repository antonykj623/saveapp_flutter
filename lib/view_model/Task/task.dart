// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view_model/investment11/addinvestment.dart';
// import 'package:path/path.dart' as path;
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
// import 'package:intl/intl.dart';
// import 'dart:math' as math;

// import '../../services/dbhelper/dbhelper.dart';

// class Tasks extends StatefulWidget {
//   const Tasks({super.key});

//   @override
//   State<Tasks> createState() => _SlidebleListState1();
// }

// class _SlidebleListState1 extends State<Tasks> with TickerProviderStateMixin {
//   bool _showTextBox = false;
//   late TextEditingController _timeController;
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Controllers initialized within the state
//   late TextEditingController taskController;
//   late TextEditingController emiAmountController;
//   late TextEditingController emiPeriodController;
//   late TextEditingController menuController;
//   late TextEditingController menuController1;
//   late TextEditingController typeController;

//   DateTime selected_startDate = DateTime.now();
//   DateTime selected_endDate = DateTime.now();

//   String dropdownvalu = 'OneTime';
//   final items1 = [
//     'OneTime',
//     'Daily',
//     'Monthly',
//     'Weekly',
//     'Quarterly',
//     'Half Yearly',
//     'Yearly',
//   ];
//   final dbhelper = DatabaseHelper.instance;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers here to tie them to the widget's lifecycle
//     taskController = TextEditingController();
//     emiAmountController = TextEditingController();
//     emiPeriodController = TextEditingController();
//     menuController = TextEditingController();
//     menuController1 = TextEditingController();
//     typeController = TextEditingController();
//     _timeController = TextEditingController();

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
//     );

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _timeController.dispose();
//     taskController.dispose();
//     emiAmountController.dispose();
//     emiPeriodController.dispose();
//     menuController.dispose();
//     menuController1.dispose();
//     typeController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.fromSeed(
//               seedColor: Colors.teal,
//               brightness: Brightness.light,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedTime != null) {
//       final formattedTime = pickedTime.format(context);
//       setState(() {
//         _timeController.text = formattedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     void selectDate(bool isStart) {
//       showDatePicker(
//         context: context,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.fromSeed(
//                 seedColor: Colors.teal,
//                 brightness: Brightness.light,
//               ),
//             ),
//             child: child!,
//           );
//         },
//       ).then((pickedDate) {
//         if (pickedDate != null) {
//           setState(() {
//             if (isStart) {
//               selected_startDate = pickedDate;
//             } else {
//               selected_endDate = pickedDate;
//             }
//           });
//         }
//       });
//     }

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.teal.shade50,
//               Colors.cyan.shade50,
//               Colors.blue.shade50,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Custom App Bar with Glassmorphism
//               Container(
//                 height: 100,
//                 margin: const EdgeInsets.all(16),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.2),
//                             Colors.white.withOpacity(0.1),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             icon: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.arrow_back_ios_rounded,
//                                 color: Colors.teal,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Center(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Colors.teal, Colors.cyan],
//                                       ),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Icon(
//                                       Icons.task_alt,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   const Text(
//                                     'Create Task',
//                                     style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.teal,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 48), // Balance the back button
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Main Content
//               Expanded(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Task Input Field
//                           _buildSectionHeader(
//                             "Task Details",
//                             Icons.edit_rounded,
//                           ),
//                           const SizedBox(height: 16),
//                           AnimatedTextField(
//                             controller: taskController,
//                             labelText: "Enter your task",
//                             borderType: 'electric',
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a task';
//                               }
//                               return null;
//                             },
//                             borderRadius: 16,
//                             prefixIcon: Container(
//                               margin: const EdgeInsets.all(8),
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [Colors.teal, Colors.cyan],
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.task,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                             backgroundColor: Colors.white.withOpacity(0.9),
//                           ),

//                           const SizedBox(height: 24),

//                           // Date and Time Section
//                           _buildSectionHeader(
//                             "Schedule",
//                             Icons.schedule_rounded,
//                           ),
//                           const SizedBox(height: 16),

//                           // Start Date
//                           _buildAnimatedDatePicker(
//                             "Start Date",
//                             _getDisplayStartDate(),
//                             Icons.date_range_rounded,
//                             () => selectDate(true),
//                             'fire',
//                           ),

//                           const SizedBox(height: 16),

//                           // Time Picker
//                           AnimatedTextField(
//                             controller: _timeController,
//                             labelText: "Select Time",
//                             borderType: 'neon',
//                             onTap: () => _selectTime(context),
//                             borderRadius: 16,
//                             prefixIcon: Container(
//                               margin: const EdgeInsets.all(8),
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [Colors.orange, Colors.pink],
//                                 ),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.access_time_rounded,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                             backgroundColor: Colors.white.withOpacity(0.9),
//                           ),

//                           const SizedBox(height: 16),

//                           // End Date
//                           _buildAnimatedDatePicker(
//                             "End Date",
//                             _getDisplayEndDate(),
//                             Icons.event_available_rounded,
//                             () => selectDate(false),
//                             'ocean',
//                           ),

//                           const SizedBox(height: 24),

//                           // Frequency Section
//                           _buildSectionHeader(
//                             "Frequency",
//                             Icons.repeat_rounded,
//                           ),
//                           const SizedBox(height: 16),

//                           AnimatedBorderWidget(
//                             borderType: 'rainbow',
//                             borderRadius: BorderRadius.circular(16),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: Colors.white.withOpacity(0.9),
//                               ),
//                               child: DropdownButtonFormField<String>(
//                                 value: dropdownvalu,
//                                 decoration: InputDecoration(
//                                   prefixIcon: Container(
//                                     margin: const EdgeInsets.all(8),
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Colors.purple, Colors.blue],
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: const Icon(
//                                       Icons.repeat,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                   ),
//                                   labelText: "Repeat Frequency",
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 16,
//                                   ),
//                                 ),
//                                 items:
//                                     items1.map((String item) {
//                                       return DropdownMenuItem<String>(
//                                         value: item,
//                                         child: Text(
//                                           item,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       );
//                                     }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     dropdownvalu = newValue!;
//                                   });
//                                 },
//                                 dropdownColor: Colors.white,
//                                 icon: Container(
//                                   margin: const EdgeInsets.only(right: 12),
//                                   child: const Icon(
//                                     Icons.keyboard_arrow_down_rounded,
//                                     color: Colors.teal,
//                                     size: 28,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 40),

//                           // Save Button
//                           Center(
//                             child: AnimatedBorderWidget(
//                               borderType: 'electric',
//                               borderRadius: BorderRadius.circular(20),
//                               child: Container(
//                                 width: 200,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                     colors: [
//                                       Colors.teal,
//                                       Colors.cyan,
//                                       Colors.teal.shade700,
//                                     ],
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.teal.withOpacity(0.3),
//                                       blurRadius: 20,
//                                       offset: const Offset(0, 10),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Material(
//                                   color: Colors.transparent,
//                                   child: InkWell(
//                                     borderRadius: BorderRadius.circular(20),
//                                     onTap: () {
//                                       _showSuccessDialog();
//                                     },
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           const Icon(
//                                             Icons.save_rounded,
//                                             color: Colors.white,
//                                             size: 24,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           const Text(
//                                             "Save Task",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [Colors.teal, Colors.cyan]),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.teal,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAnimatedDatePicker(
//     String label,
//     String displayDate,
//     IconData icon,
//     VoidCallback onTap,
//     String borderType,
//   ) {
//     return AnimatedBorderWidget(
//       borderType: borderType,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white.withOpacity(0.9),
//         ),
//         child: ListTile(
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _getGradientForBorderType(borderType),
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//           title: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           subtitle: Text(
//             displayDate,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           trailing: const Icon(
//             Icons.calendar_today_rounded,
//             color: Colors.teal,
//           ),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }

//   List<Color> _getGradientForBorderType(String borderType) {
//     switch (borderType) {
//       case 'fire':
//         return [Colors.orange, Colors.red];
//       case 'ocean':
//         return [Colors.blue, Colors.cyan];
//       case 'neon':
//         return [Colors.pink, Colors.purple];
//       default:
//         return [Colors.teal, Colors.cyan];
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => Dialog(
//             backgroundColor: Colors.transparent,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.green, Colors.teal],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.check_rounded,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Task Created!',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Your task has been successfully created.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'OK',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }
// }

// String _getDisplayStartDate() {
//   return DateFormat('dd/MM/yyyy').format(selected_startDate);
// }

// String _getDisplayEndDate() {
//   return DateFormat('dd/MM/yyyy').format(selected_endDate);
// }

// class AnimatedBorderWidget extends StatefulWidget {
//   final Widget child;
//   final String borderType;
//   final List<Color>? customColors;
//   final double borderWidth;
//   final double glowSize;
//   final int animationDuration;
//   final BorderRadius? borderRadius;
//   final bool isActive;

//   const AnimatedBorderWidget({
//     Key? key,
//     required this.child,
//     this.borderType = 'electric',
//     this.customColors,
//     this.borderWidth = 3.0,
//     this.glowSize = 20.0,
//     this.animationDuration = 2500,
//     this.borderRadius,
//     this.isActive = true,
//   }) : super(key: key);

//   @override
//   _AnimatedBorderWidgetState createState() => _AnimatedBorderWidgetState();
// }

// class _AnimatedBorderWidgetState extends State<AnimatedBorderWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: widget.animationDuration),
//       vsync: this,
//     );

//     if (widget.isActive) {
//       _animationController.repeat();
//     }
//   }

//   @override
//   void didUpdateWidget(AnimatedBorderWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive != oldWidget.isActive) {
//       if (widget.isActive) {
//         _animationController.repeat();
//       } else {
//         _animationController.stop();
//         _animationController.reset();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   List<Color> _getGradientColors() {
//     if (widget.customColors != null) {
//       return widget.customColors!;
//     }

//     switch (widget.borderType) {
//       case 'electric':
//         return [
//           Colors.transparent,
//           Color(0xFF00D4FF).withOpacity(0.3),
//           Color(0xFF0099FF).withOpacity(0.6),
//           Color(0xFF0066FF),
//           Color(0xFF3366FF),
//           Color(0xFF6633FF),
//           Color(0xFF9933FF),
//           Color(0xFFCC33FF),
//           Color(0xFF9933FF),
//           Color(0xFF6633FF),
//           Color(0xFF3366FF),
//           Color(0xFF0066FF),
//           Colors.transparent,
//         ];
//       case 'rainbow':
//         return [
//           Colors.transparent,
//           Colors.red.withOpacity(0.3),
//           Colors.orange.withOpacity(0.6),
//           Colors.yellow,
//           Colors.green,
//           Colors.blue,
//           Colors.indigo,
//           Colors.purple,
//           Colors.pink,
//           Colors.purple,
//           Colors.indigo,
//           Colors.blue,
//           Colors.green,
//           Colors.yellow,
//           Colors.orange.withOpacity(0.6),
//           Colors.red.withOpacity(0.3),
//           Colors.transparent,
//         ];
//       case 'fire':
//         return [
//           Colors.transparent,
//           Color(0xFFFF6B35).withOpacity(0.3),
//           Color(0xFFFF8C42).withOpacity(0.6),
//           Color(0xFFFFA500),
//           Color(0xFFFFD700),
//           Color(0xFFFF6347),
//           Color(0xFFFF4500),
//           Color(0xFFDC143C),
//           Color(0xFFB22222),
//           Color(0xFFDC143C),
//           Color(0xFFFF4500),
//           Color(0xFFFF6347),
//           Color(0xFFFFD700),
//           Color(0xFFFFA500),
//           Colors.transparent,
//         ];
//       case 'ocean':
//         return [
//           Colors.transparent,
//           Color(0xFF00CED1).withOpacity(0.3),
//           Color(0xFF20B2AA).withOpacity(0.6),
//           Color(0xFF008B8B),
//           Color(0xFF00FFFF),
//           Color(0xFF40E0D0),
//           Color(0xFF48D1CC),
//           Color(0xFF00CED1),
//           Color(0xFF5F9EA0),
//           Color(0xFF00CED1),
//           Color(0xFF48D1CC),
//           Color(0xFF40E0D0),
//           Color(0xFF00FFFF),
//           Color(0xFF008B8B),
//           Colors.transparent,
//         ];
//       case 'neon':
//         return [
//           Colors.transparent,
//           Color(0xFFFF073A).withOpacity(0.3),
//           Color(0xFFFF073A).withOpacity(0.6),
//           Color(0xFFFF073A),
//           Color(0xFF39FF14),
//           Color(0xFF00FFFF),
//           Color(0xFFFF1493),
//           Color(0xFFFFFF00),
//           Color(0xFF9400D3),
//           Color(0xFFFFFF00),
//           Color(0xFFFF1493),
//           Color(0xFF00FFFF),
//           Color(0xFF39FF14),
//           Color(0xFFFF073A),
//           Colors.transparent,
//         ];
//       default:
//         return [Colors.grey.shade300];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return CustomAnimatedBorder(
//           borderSize: widget.isActive ? widget.borderWidth : 1.0,
//           glowSize: widget.isActive ? widget.glowSize : 0.0,
//           gradientColors:
//               widget.isActive ? _getGradientColors() : [Colors.grey.shade300],
//           animationProgress: _animationController.value,
//           borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
//           child: widget.child,
//         );
//       },
//     );
//   }
// }

// class CustomAnimatedBorder extends StatelessWidget {
//   final Widget child;
//   final double borderSize;
//   final double glowSize;
//   final List<Color> gradientColors;
//   final double animationProgress;
//   final BorderRadius borderRadius;

//   const CustomAnimatedBorder({
//     Key? key,
//     required this.child,
//     required this.borderSize,
//     required this.glowSize,
//     required this.gradientColors,
//     required this.animationProgress,
//     required this.borderRadius,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: borderRadius,
//         boxShadow:
//             glowSize > 0
//                 ? [
//                   BoxShadow(
//                     color:
//                         gradientColors.isNotEmpty
//                             ? gradientColors[gradientColors.length ~/ 2]
//                                 .withOpacity(0.8)
//                             : Colors.blue.withOpacity(0.8),
//                     blurRadius: glowSize,
//                     spreadRadius: glowSize / 4,
//                   ),
//                   BoxShadow(
//                     color:
//                         gradientColors.isNotEmpty
//                             ? gradientColors[gradientColors.length ~/ 3]
//                                 .withOpacity(0.5)
//                             : Colors.blue.withOpacity(0.5),
//                     blurRadius: glowSize * 1.5,
//                     spreadRadius: glowSize / 3,
//                   ),
//                   BoxShadow(
//                     color:
//                         gradientColors.isNotEmpty
//                             ? gradientColors[gradientColors.length ~/ 4]
//                                 .withOpacity(0.3)
//                             : Colors.blue.withOpacity(0.3),
//                     blurRadius: glowSize * 2,
//                     spreadRadius: glowSize / 2,
//                   ),
//                 ]
//                 : null,
//       ),
//       child: CustomPaint(
//         painter: AnimatedBorderPainter(
//           borderSize: borderSize,
//           gradientColors: gradientColors,
//           animationProgress: animationProgress,
//           borderRadius: borderRadius,
//         ),
//         child: child,
//       ),
//     );
//   }
// }

// class AnimatedBorderPainter extends CustomPainter {
//   final double borderSize;
//   final List<Color> gradientColors;
//   final double animationProgress;
//   final BorderRadius borderRadius;

//   AnimatedBorderPainter({
//     required this.borderSize,
//     required this.gradientColors,
//     required this.animationProgress,
//     required this.borderRadius,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (gradientColors.length <= 1) {
//       final paint =
//           Paint()
//             ..color =
//                 gradientColors.isNotEmpty ? gradientColors.first : Colors.grey
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = borderSize;

//       final rect = Rect.fromLTWH(
//         borderSize / 2,
//         borderSize / 2,
//         size.width - borderSize,
//         size.height - borderSize,
//       );
//       final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
//       canvas.drawRRect(rrect, paint);
//       return;
//     }

//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
//     final path = Path()..addRRect(rrect);
//     final pathMetrics = path.computeMetrics().toList();

//     if (pathMetrics.isNotEmpty) {
//       final pathMetric = pathMetrics.first;
//       final totalLength = pathMetric.length;

//       if (totalLength > 0) {
//         final trainLength = totalLength * 0.4;
//         final trainPosition = (animationProgress * totalLength) % totalLength;

//         _drawGradientTrain(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainLength,
//           trainPosition,
//         );

//         _drawSparkleEffects(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainPosition,
//           trainLength,
//         );

//         _drawTrailingGlow(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainPosition,
//           trainLength,
//         );
//       }
//     }
//   }

//   void _drawGradientTrain(
//     Canvas canvas,
//     PathMetric pathMetric,
//     double totalLength,
//     double trainLength,
//     double trainPosition,
//   ) {
//     for (int i = 0; i < gradientColors.length; i++) {
//       final segmentLength = trainLength / gradientColors.length;
//       final segmentStart =
//           (trainPosition - trainLength / 2 + i * segmentLength) % totalLength;
//       final segmentEnd = (segmentStart + segmentLength) % totalLength;

//       final paint =
//           Paint()
//             ..color = gradientColors[i]
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = borderSize
//             ..strokeCap = StrokeCap.round;

//       try {
//         if (segmentStart < segmentEnd && segmentEnd <= totalLength) {
//           final segmentPath = pathMetric.extractPath(segmentStart, segmentEnd);
//           canvas.drawPath(segmentPath, paint);
//         } else if (segmentStart >= 0 && segmentStart < totalLength) {
//           if (segmentStart < totalLength) {
//             final segmentPath1 = pathMetric.extractPath(
//               segmentStart,
//               totalLength,
//             );
//             canvas.drawPath(segmentPath1, paint);
//           }
//           if (segmentEnd > 0) {
//             final segmentPath2 = pathMetric.extractPath(
//               0,
//               math.min(segmentEnd, totalLength),
//             );
//             canvas.drawPath(segmentPath2, paint);
//           }
//         }
//       } catch (e) {
//         continue;
//       }
//     }
//   }

//   void _drawSparkleEffects(
//     Canvas canvas,
//     PathMetric pathMetric,
//     double totalLength,
//     double trainPosition,
//     double trainLength,
//   ) {
//     final sparklePositions = [
//       (trainPosition + trainLength * 0.2) % totalLength,
//       (trainPosition + trainLength * 0.5) % totalLength,
//       (trainPosition + trainLength * 0.8) % totalLength,
//     ];

//     final sparklePaint =
//         Paint()
//           ..color = Colors.white.withOpacity(0.9)
//           ..style = PaintingStyle.fill;

//     final sparkleGlowPaint =
//         Paint()
//           ..color = Colors.white.withOpacity(0.3)
//           ..style = PaintingStyle.fill;

//     for (int i = 0; i < sparklePositions.length; i++) {
//       final pos = sparklePositions[i];
//       try {
//         if (pos >= 0 && pos <= totalLength) {
//           final tangent = pathMetric.getTangentForOffset(pos);
//           if (tangent != null) {
//             canvas.drawCircle(tangent.position, 5, sparkleGlowPaint);
//             canvas.drawCircle(tangent.position, 2, sparklePaint);
//           }
//         }
//       } catch (e) {
//         continue;
//       }
//     }
//   }

//   void _drawTrailingGlow(
//     Canvas canvas,
//     PathMetric pathMetric,
//     double totalLength,
//     double trainPosition,
//     double trainLength,
//   ) {
//     final trailStart = (trainPosition - trainLength * 0.6) % totalLength;
//     final trailEnd = (trainPosition - trainLength * 0.3) % totalLength;

//     final trailPaint =
//         Paint()
//           ..color =
//               gradientColors.isNotEmpty
//                   ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.3)
//                   : Colors.white.withOpacity(0.3)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = borderSize * 1.5
//           ..strokeCap = StrokeCap.round;

//     try {
//       if (trailStart < trailEnd && trailEnd <= totalLength) {
//         final trailPath = pathMetric.extractPath(trailStart, trailEnd);
//         canvas.drawPath(trailPath, trailPaint);
//       }
//     } catch (e) {
//       // Continue if there's an error
//     }
//   }

//   @override
//   bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
//     return oldDelegate.animationProgress != animationProgress ||
//         oldDelegate.borderSize != borderSize ||
//         oldDelegate.gradientColors != gradientColors;
//   }
// }

// class AnimatedTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final String borderType;
//   final bool obscureText;
//   final int maxLines;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;
//   final VoidCallback? onTap;
//   final int borderRadius;
//   final Widget prefixIcon;
//   final Color backgroundColor;

//   const AnimatedTextField({
//     Key? key,
//     required this.controller,
//     required this.labelText,
//     this.borderType = 'electric',
//     this.obscureText = false,
//     this.maxLines = 1,
//     this.validator,
//     this.keyboardType,
//     this.onTap,
//     required this.borderRadius,
//     required this.prefixIcon,
//     required this.backgroundColor,
//   }) : super(key: key);

//   @override
//   _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
// }

// class _AnimatedTextFieldState extends State<AnimatedTextField> {
//   late FocusNode _focusNode;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _focusNode.addListener(() {
//       if (mounted) {
//         setState(() {
//           _isFocused = _focusNode.hasFocus;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.removeListener(() {});
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBorderWidget(
//       borderType: widget.borderType,
//       isActive: _isFocused,
//       borderWidth: _isFocused ? 3.0 : 1.0,
//       glowSize: _isFocused ? 15.0 : 0.0,
//       borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//           color: widget.backgroundColor,
//         ),
//         child: TextFormField(
//           controller: widget.controller,
//           focusNode: _focusNode,
//           obscureText: widget.obscureText,
//           maxLines: widget.maxLines,
//           keyboardType: widget.keyboardType,
//           onTap: widget.onTap,
//           decoration: InputDecoration(
//             labelText: widget.labelText,
//             labelStyle: TextStyle(
//               color: _isFocused ? Colors.teal[700] : Colors.grey[600],
//               fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
//             ),
//             prefixIcon: widget.prefixIcon,
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             floatingLabelBehavior: FloatingLabelBehavior.auto,
//           ),
//           style: const TextStyle(color: Colors.black87, fontSize: 16),
//           validator: widget.validator,
//         ),
//       ),
//     );
//   }
// }
