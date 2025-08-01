import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/snack_bar.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show listEquals;

class SetPattern extends StatefulWidget {
  @override
  _SetPatternState createState() => _SetPatternState();
}

class _SetPatternState extends State<SetPattern> {
  bool isConfirm = false;
  bool isVerifyingOldPattern = false;
  List<int>? pattern;
  List<int>? savedPattern;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadSavedPattern();
  }

  Future<void> loadSavedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final patternString = prefs.getString('lock_pattern');
    if (patternString != null) {
      setState(() {
        savedPattern = patternString.split(',').map((e) => int.parse(e)).toList();
        isVerifyingOldPattern = true;
      });
    }
  }

  Future<void> savePatternToPrefs(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final patternString = pattern.join(',');
    await prefs.setString('lock_pattern', patternString);
    print("Saved pattern: $patternString");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(isVerifyingOldPattern ? "Verify Old Pattern" : isConfirm ? "Confirm New Pattern" : "Set New Pattern"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: Text(
              isVerifyingOldPattern ? "Draw your existing pattern" : isConfirm ? "Confirm new pattern" : "Draw new pattern",
              style: TextStyle(fontSize: 26),
            ),
          ),
          Flexible(
            child: PatternLock(
              selectedColor: Colors.amber,
              pointRadius: 12,
              onInputComplete: (List<int> input) async {
                if (input.length < 3) {
                  context.replaceSnackbar(
                    content: Text(
                      "At least 3 points required",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    color: Colors.red,
                  );
                  return;
                }

                if (isVerifyingOldPattern) {
                  if (listEquals<int>(input, savedPattern)) {
                    setState(() {
                      isVerifyingOldPattern = false;
                      pattern = null;
                      isConfirm = false;
                    });
                    context.replaceSnackbar(
                      content: Text(
                        "Old pattern verified",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.green,
                    );
                  } else {
                    context.replaceSnackbar(
                      content: Text(
                        "Incorrect pattern",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.red,
                    );
                  }
                } else if (isConfirm) {
                  if (listEquals<int>(input, pattern)) {
                    await savePatternToPrefs(pattern!);
                    context.replaceSnackbar(
                      content: Text(
                        "Pattern saved successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.green,
                    );
                    Navigator.of(context).pop(pattern);
                  } else {
                    context.replaceSnackbar(
                      content: Text(
                        "Patterns do not match",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.red,
                    );
                    setState(() {
                      pattern = null;
                      isConfirm = false;
                    });
                  }
                } else {
                  setState(() {
                    pattern = input;
                    isConfirm = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
// import 'package:pattern_lock/pattern_lock.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SetPattern extends StatefulWidget {
//   @override
//   _SetPatternState createState() => _SetPatternState();
// }
// Future<void> savePatternToPrefs(List<int> pattern) async {
//   final prefs = await SharedPreferences.getInstance();
//   final patternString = pattern.join(',');
//   await prefs.setString('lock_pattern', patternString);
//
//   // ✅ Print the saved pattern
//   print("Saved pattern: $patternString");
// }
//
// class _SetPatternState extends State<SetPattern> {
//   bool isConfirm = false;
//   List<int>? pattern;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text("Check Pattern"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Flexible(
//             child: Text(
//               isConfirm ? "Confirm pattern" : "Draw pattern",
//               style: TextStyle(fontSize: 26),
//             ),
//           ),
//           Flexible(
//             child: PatternLock(
//               selectedColor: Colors.amber,
//               pointRadius: 12,
//               onInputComplete: (List<int> input) async {
//                 if (input.length < 3) {
//                   context.replaceSnackbar(
//                     content: Text("At least 3 points required",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 12)),
//                     color: Colors.red,
//                   );
//                   return;
//                 }
//
//                 if (isConfirm) {
//                   if (listEquals<int>(input, pattern)) {
//                     // ✅ Save to SharedPreferences
//                     await savePatternToPrefs(pattern!);
//
//                     context.replaceSnackbar(
//                       content: Text("Pattern saved successfully",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontSize: 12)),
//                       color: Colors.green,
//                     );
//
//                     Navigator.of(context).pop(pattern);
//                   } else {
//                     context.replaceSnackbar(
//                       content: Text("Patterns do not match",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.white, fontSize: 12)),
//                       color: Colors.red,
//                     );
//                     setState(() {
//                       pattern = null;
//                       isConfirm = false;
//                     });
//                   }
//                 } else {
//                   setState(() {
//                     pattern = input;
//                     isConfirm = true;
//                   });
//                 }
//               },
//
//
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }