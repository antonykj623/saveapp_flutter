// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'package:new_project_2025/view_model/Task/tasks.dart';

// class Tasks extends StatefulWidget {
//   const Tasks({super.key});

//   @override
//   State<Tasks> createState() => _SlidebleListState1();
// }

// class _SlidebleListState1 extends State<Tasks> with SingleTickerProviderStateMixin {
//   final dbHelper = DatabaseHelper();
//   final TextEditingController task = TextEditingController();
//   final TextEditingController startdateCtl = TextEditingController();
//   final TextEditingController enddateCtl1 = TextEditingController();
//   final TextEditingController reminddateCtl1 = TextEditingController();
//   final TextEditingController _timeController = TextEditingController();
//   final TextEditingController dropdownController = TextEditingController();
//   String dropdownvalu = 'OneTime';
//   final List<String> items1 = [
//     'OneTime',
//     'Daily',
//     'Weekly',
//     'Monthly',
//     'Quarterly',
//     'Half Yearly',
//     'Yearly',
//   ];

//   late AnimationController _buttonHoverController;
//   late Animation<double> _buttonScaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _buttonHoverController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _buttonHoverController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     task.dispose();
//     startdateCtl.dispose();
//     enddateCtl1.dispose();
//     reminddateCtl1.dispose();
//     _timeController.dispose();
//     dropdownController.dispose();
//     _buttonHoverController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (pickedTime != null) {
//       setState(() {
//         _timeController.text = pickedTime.format(context);
//       });
//     }
//   }

//   Future<void> saveTaskToDB() async {
//     if (task.text.isEmpty || startdateCtl.text.isEmpty || enddateCtl1.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     try {
//       final DateTime startDate = DateFormat('dd/MM/yyyy').parse(startdateCtl.text.trim());
//       final DateTime endDate = DateFormat('dd/MM/yyyy').parse(enddateCtl1.text.trim());
//       DateTime? remindDateUpTo = reminddateCtl1.text.isNotEmpty
//           ? DateFormat('dd/MM/yyyy').parse(reminddateCtl1.text.trim())
//           : null;

//       Future<void> saveRow(DateTime date, DateTime remindDate) async {
//         Map<String, dynamic> taskData = {
//           "task": task.text,
//           "statrdatectrl": DateFormat('dd/MM/yyyy').format(date),
//           "enddatectrl": DateFormat('dd/MM/yyyy').format(remindDate),
//           "timectrl": _timeController.text,
//           "reminddateupto": remindDateUpTo != null ? DateFormat('dd/MM/yyyy').format(remindDateUpTo) : "no data",
//           "selectedItem": dropdownvalu,
//           "status": "initial",
//         };

//         await dbHelper.addData("TABLE_TASK", jsonEncode(taskData));

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Task added successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }

//       if (dropdownvalu == "OneTime") {
//         await saveRow(startDate, endDate);
//       } else {
//         DateTime loopDate = startDate;
//         DateTime loopEndDate = endDate;

//         while (remindDateUpTo != null &&
//             (loopDate.isBefore(remindDateUpTo) || loopDate.isAtSameMomentAs(remindDateUpTo))) {
//           await saveRow(loopDate, loopEndDate);

//           switch (dropdownvalu) {
//             case "Daily":
//               loopDate = loopDate.add(const Duration(days: 1));
//               loopEndDate = loopEndDate.add(const Duration(days: 1));
//               break;
//             case "Weekly":
//               loopDate = loopDate.add(const Duration(days: 7));
//               loopEndDate = loopEndDate.add(const Duration(days: 7));
//               break;
//             case "Monthly":
//               loopDate = DateTime(loopDate.year, loopDate.month + 1, loopDate.day);
//               loopEndDate = DateTime(loopEndDate.year, loopEndDate.month + 1, loopEndDate.day);
//               break;
//             case "Quarterly":
//               loopDate = DateTime(loopDate.year, loopDate.month + 3, loopDate.day);
//               loopEndDate = DateTime(loopEndDate.year, loopEndDate.month + 3, loopEndDate.day);
//               break;
//             case "Half Yearly":
//               loopDate = DateTime(loopDate.year, loopDate.month + 6, loopDate.day);
//               loopEndDate = DateTime(loopEndDate.year, loopEndDate.month + 6, loopEndDate.day);
//               break;
//             case "Yearly":
//               loopDate = DateTime(loopDate.year + 1, loopDate.month, loopDate.day);
//               loopEndDate = DateTime(loopEndDate.year + 1, loopEndDate.month, loopEndDate.day);
//               break;
//           }
//         }
//       }

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const TaskScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving task: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildModernButton({
//     required String text,
//     required VoidCallback onPressed,
//     required List<Color> gradientColors,
//     required String borderType,
//   }) {
//     return AnimatedBuilder(
//       animation: _buttonScaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _buttonScaleAnimation.value,
//           child: AnimatedBorderWidget(
//             borderType: borderType,
//             customColors: gradientColors,
//             borderWidth: 2.0,
//             glowSize: 6.0,
//             borderRadius: BorderRadius.circular(25),
//             isActive: true,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: gradientColors,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: gradientColors[0].withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(25),
//                   onTap: onPressed,
//                   onTapDown: (_) => _buttonHoverController.forward(),
//                   onTapUp: (_) => _buttonHoverController.reverse(),
//                   onTapCancel: () => _buttonHoverController.reverse(),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     child: Center(
//                       child: Text(
//                         text,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 1.2,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black26,
//                               blurRadius: 4,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
//               ),
//             ),
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Add Task',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   AnimatedTextField(
//                     controller: task,
//                     labelText: "Task",
//                     borderType: "neon",
//                     customColors: [
//                       Colors.transparent,
//                       const Color(0xFF667eea).withOpacity(0.4),
//                       const Color(0xFF764ba2),
//                       const Color(0xFF89f7fe),
//                       const Color(0xFF66a6ff),
//                       const Color(0xFF89f7fe),
//                       const Color(0xFF764ba2),
//                       Colors.transparent,
//                     ],
//                     onTap: () {},
//                   ),
//                   const SizedBox(height: 20),
//                   AnimatedTextField(
//                     controller: startdateCtl,
//                     labelText: 'Start Date',
//                     borderType: "fire",
//                     customColors: [
//                       Colors.transparent,
//                       const Color(0xFFFF6B35).withOpacity(0.3),
//                       const Color(0xFFFF8C42).withOpacity(0.6),
//                       const Color(0xFFFFA500),
//                       const Color(0xFFFFD700),
//                       const Color(0xFFFF6347),
//                       Colors.transparent,
//                     ],
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       DateTime? date = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(1900),
//                         lastDate: DateTime(2100),
//                       );
//                       if (date != null) {
//                         setState(() {
//                           startdateCtl.text = DateFormat('dd/MM/yyyy').format(date);
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   AnimatedTextField(
//                     controller: _timeController,
//                     labelText: "Select Time",
//                     borderType: "rainbow",
//                     customColors: [
//                       Colors.transparent,
//                       Colors.red.withOpacity(0.3),
//                       Colors.orange.withOpacity(0.6),
//                       Colors.yellow,
//                       Colors.green,
//                       Colors.blue,
//                       Colors.transparent,
//                     ],
//                     onTap: () => _selectTime(context),
//                   ),
//                   const SizedBox(height: 20),
//                   AnimatedTextField(
//                     controller: enddateCtl1,
//                     labelText: 'Remind Date',
//                     borderType: "electric",
//                     customColors: [
//                       Colors.transparent,
//                       const Color(0xFF00D4FF).withOpacity(0.3),
//                       const Color(0xFF0099FF).withOpacity(0.6),
//                       const Color(0xFF0066FF),
//                       const Color(0xFF3366FF),
//                       Colors.transparent,
//                     ],
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       DateTime? date = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(1900),
//                         lastDate: DateTime(2100),
//                       );
//                       if (date != null) {
//                         setState(() {
//                           enddateCtl1.text = DateFormat('dd/MM/yyyy').format(date);
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   AnimatedTextField(
//                     controller: dropdownController,
//                     labelText: 'Select Item',
//                     borderType: "fire",
//                     customColors: [
//                       Colors.transparent,
//                       const Color(0xFFFF6B35).withOpacity(0.3),
//                       const Color(0xFFFF8C42).withOpacity(0.6),
//                       const Color(0xFFFFA500),
//                       const Color(0xFFFFD700),
//                       Colors.transparent,
//                     ],
//                     onTap: () async {
//                       String? selected = await showDialog<String>(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return SimpleDialog(
//                             title: const Text('Select an item'),
//                             children: items1.map((item) {
//                               return SimpleDialogOption(
//                                 child: Text(item),
//                                 onPressed: () {
//                                   Navigator.pop(context, item);
//                                 },
//                               );
//                             }).toList(),
//                           );
//                         },
//                       );
//                       if (selected != null) {
//                         setState(() {
//                           dropdownController.text = selected;
//                           dropdownvalu = selected;
//                         });
//                       }
//                     },
//                   ),
//                   if (dropdownvalu != "OneTime") ...[
//                     const SizedBox(height: 20),
//                     AnimatedTextField(
//                       controller: reminddateCtl1,
//                       labelText: 'Remind Date Up To',
//                       borderType: "electric",
//                       customColors: [
//                         Colors.transparent,
//                         const Color(0xFF00D4FF).withOpacity(0.3),
//                         const Color(0xFF0099FF).withOpacity(0.6),
//                         const Color(0xFF0066FF),
//                         Colors.transparent,
//                       ],
//                       onTap: () async {
//                         FocusScope.of(context).requestFocus(FocusNode());
//                         DateTime? date = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime(2100),
//                         );
//                         if (date != null) {
//                           setState(() {
//                             reminddateCtl1.text = DateFormat('dd/MM/yyyy').format(date);
//                           });
//                         }
//                       },
//                     ),
//                   ],
//                   const SizedBox(height: 40),
//                   _buildModernButton(
//                     text: 'Submit',
//                     onPressed: saveTaskToDB,
//                     gradientColors: const [
//                       Color(0xFF667eea),
//                       Color(0xFF764ba2),
//                     ],
//                     borderType: "neon",
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
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
//           const Color(0xFF00D4FF).withOpacity(0.3),
//           const Color(0xFF0099FF).withOpacity(0.6),
//           const Color(0xFF0066FF),
//           const Color(0xFF3366FF),
//           const Color(0xFF6633FF),
//           const Color(0xFF9933FF),
//           const Color(0xFFCC33FF),
//           const Color(0xFF9933FF),
//           const Color(0xFF6633FF),
//           const Color(0xFF3366FF),
//           const Color(0xFF0066FF),
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
//           const Color(0xFFFF6B35).withOpacity(0.3),
//           const Color(0xFFFF8C42).withOpacity(0.6),
//           const Color(0xFFFFA500),
//           const Color(0xFFFFD700),
//           const Color(0xFFFF6347),
//           const Color(0xFFFF4500),
//           const Color(0xFFDC143C),
//           const Color(0xFFB22222),
//           const Color(0xFFDC143C),
//           const Color(0xFFFF4500),
//           const Color(0xFFFF6347),
//           const Color(0xFFFFD700),
//           const Color(0xFFFFA500),
//           Colors.transparent,
//         ];
//       case 'ocean':
//         return [
//           Colors.transparent,
//           const Color(0xFF00CED1).withOpacity(0.3),
//           const Color(0xFF20B2AA).withOpacity(0.6),
//           const Color(0xFF008B8B),
//           const Color(0xFF00FFFF),
//           const Color(0xFF40E0D0),
//           const Color(0xFF48D1CC),
//           const Color(0xFF00CED1),
//           const Color(0xFF5F9EA0),
//           const Color(0xFF00CED1),
//           const Color(0xFF48D1CC),
//           const Color(0xFF40E0D0),
//           const Color(0xFF00FFFF),
//           const Color(0xFF008B8B),
//           Colors.transparent,
//         ];
//       case 'neon':
//         return [
//           Colors.transparent,
//           const Color(0xFFFF073A).withOpacity(0.3),
//           const Color(0xFFFF073A).withOpacity(0.6),
//           const Color(0xFFFF073A),
//           const Color(0xFF39FF14),
//           const Color(0xFF00FFFF),
//           const Color(0xFFFF1493),
//           const Color(0xFFFFFF00),
//           const Color(0xFF9400D3),
//           const Color(0xFFFFFF00),
//           const Color(0xFFFF1493),
//           const Color(0xFF00FFFF),
//           const Color(0xFF39FF14),
//           const Color(0xFFFF073A),
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
//           gradientColors: widget.isActive ? _getGradientColors() : [Colors.grey.shade300],
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
//         boxShadow: glowSize > 0
//             ? [
//                 BoxShadow(
//                   color: gradientColors.isNotEmpty
//                       ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.8)
//                       : Colors.blue.withOpacity(0.8),
//                   blurRadius: glowSize,
//                   spreadRadius: glowSize / 4,
//                 ),
//                 BoxShadow(
//                   color: gradientColors.isNotEmpty
//                       ? gradientColors[gradientColors.length ~/ 3].withOpacity(0.5)
//                       : Colors.blue.withOpacity(0.5),
//                   blurRadius: glowSize * 1.5,
//                   spreadRadius: glowSize / 3,
//                 ),
//                 BoxShadow(
//                   color: gradientColors.isNotEmpty
//                       ? gradientColors[gradientColors.length ~/ 4].withOpacity(0.3)
//                       : Colors.blue.withOpacity(0.3),
//                   blurRadius: glowSize * 2,
//                   spreadRadius: glowSize / 2,
//                 ),
//               ]
//             : null,
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
//       final paint = Paint()
//         ..color = gradientColors.isNotEmpty ? gradientColors.first : Colors.grey
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderSize;

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

//         _drawGradientTrain(canvas, pathMetric, totalLength, trainLength, trainPosition);
//         _drawSparkleEffects(canvas, pathMetric, totalLength, trainPosition, trainLength);
//         _drawTrailingGlow(canvas, pathMetric, totalLength, trainPosition, trainLength);
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
//       final segmentStart = (trainPosition - trainLength / 2 + i * segmentLength) % totalLength;
//       final segmentEnd = (segmentStart + segmentLength) % totalLength;

//       final paint = Paint()
//         ..color = gradientColors[i]
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderSize
//         ..strokeCap = StrokeCap.round;

//       try {
//         if (segmentStart < segmentEnd && segmentEnd <= totalLength) {
//           final segmentPath = pathMetric.extractPath(segmentStart, segmentEnd);
//           canvas.drawPath(segmentPath, paint);
//         } else if (segmentStart >= 0 && segmentStart < totalLength) {
//           if (segmentStart < totalLength) {
//             final segmentPath1 = pathMetric.extractPath(segmentStart, totalLength);
//             canvas.drawPath(segmentPath1, paint);
//           }
//           if (segmentEnd > 0) {
//             final segmentPath2 = pathMetric.extractPath(0, segmentEnd.clamp(0, totalLength));
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

//     final sparklePaint = Paint()
//       ..color = Colors.white.withOpacity(0.9)
//       ..style = PaintingStyle.fill;

//     final sparkleGlowPaint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.fill;

//     for (final pos in sparklePositions) {
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

//     final trailPaint = Paint()
//       ..color = gradientColors.isNotEmpty
//           ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.3)
//           : Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderSize * 1.5
//       ..strokeCap = StrokeCap.round;

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
//   final Icon? prefixIcon;
//   final int borderRadius;
//   final Color backgroundColor;
//   final List<Color>? customColors;
//   final VoidCallback onTap;

//   const AnimatedTextField({
//     Key? key,
//     required this.controller,
//     required this.labelText,
//     this.borderType = 'electric',
//     this.obscureText = false,
//     this.maxLines = 1,
//     this.validator,
//     this.keyboardType,
//     this.prefixIcon,
//     this.borderRadius = 12,
//     this.backgroundColor = Colors.white,
//     this.customColors,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
// }

// class _AnimatedTextFieldState extends State<AnimatedTextField> {
//   final FocusNode _focusNode = FocusNode();
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {
//         _isFocused = _focusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBorderWidget(
//       borderType: widget.borderType,
//       customColors: widget.customColors,
//       isActive: _isFocused,
//       borderWidth: _isFocused ? 3.0 : 1.5,
//       glowSize: _isFocused ? 12.0 : 0.0,
//       borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//           color: _isFocused ? widget.backgroundColor.withOpacity(0.95) : widget.backgroundColor.withOpacity(0.92),
//           boxShadow: _isFocused
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : null,
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
//               color: _isFocused ? Colors.blue.shade700 : Colors.grey.shade600,
//               fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
//               fontSize: 16,
//             ),
//             prefixIcon: widget.prefixIcon != null
//                 ? Padding(
//                     padding: const EdgeInsets.only(left: 8, right: 12),
//                     child: widget.prefixIcon,
//                   )
//                 : null,
//             border: InputBorder.none,
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: widget.prefixIcon != null ? 8 : 24,
//               vertical: widget.maxLines > 1 ? 20 : 18,
//             ),
//             floatingLabelBehavior: FloatingLabelBehavior.auto,
//           ),
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//           validator: widget.validator,
//         ),
//       ),
//     );
//   }
// }