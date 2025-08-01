// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view/home/widget/More_page/setpattern.dart';
// import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';

// import 'CheckPattern.dart';



// class LockPatternPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Pattern Lock Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.deepOrange,
//       ),
//       routes: {
//         "/check_pattern": (BuildContext context) => CheckPattern(),
//         "/set_pattern": (BuildContext context) => SetPattern(),
//        // "/big_pattern": (BuildContext context) => BigPattern(),
//       },
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Lock Pattern'),
//           centerTitle: true,
//         ),
//         body: LockPatternMain(),
//       ),
//     );
//   }
// }

// class LockPatternMain extends StatefulWidget {
//   @override
//   _LockPatternMainWidgetState createState() => _LockPatternMainWidgetState();
// }

// class _LockPatternMainWidgetState extends State<LockPatternMain> {
//   List<int>? pattern;
//   @override
//   void initState() {
//     super.initState();
//     if (pattern != null ) [
//     SizedBox(height: 16),
//     Navigator.pushNamed(
//     context,
//     "/set_pattern",
//     arguments: pattern,
//     ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[

//           // MaterialButton(
//           //   color: Colors.lightGreen,
//           //   child: Text("Set Pattern", style: TextStyle(color: Colors.white)),
//           //   onPressed: () async {
//           //     final result = await Navigator.pushNamed(context, "/set_pattern");
//           //     if (result is List<int>) {
//           //       context.replaceSnackbar(
//           //         content: Text("pattern is $result",textAlign: TextAlign.center,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.white),),
//           //         color: Colors.deepOrange,
//           //
//           //       );
//           //       setState(() {
//           //         pattern = result;
//           //       });
//           //     }
//           //   },
//           // ),




//         ],
//       ),
//     );
//   }
// }