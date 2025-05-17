// import 'dart:convert';

// import 'package:get/get.dart';

// import '../Modals/profile.dart';
// import 'mainController.dart';



// class Profilecontroller extends GetxController {

//   var profileList = <Profile>[].obs;


//   @override
//   void onInit() {

//     super.onInit();
//     getProfile();
//   }

//   Future<void> getProfile()
//   async {

//    // String dat =await Apihelper().getApiResponse('getUserDetails.php?q=3123211');

// String dat = await Apihelper().postApiResponse('getUserDetails.php?q=3123211', {});


//     final List<dynamic> jsonList = jsonDecode(dat);
//     profileList.addAll(jsonList.map((json) => Profile.fromJson(json)).toList())  ;



//     print('Response is $dat');


//   }


// //
// //
// // Future<void> getProductsdes()
// // async {
// //
// //   String dat1 =await Apihelper().getApiResponse('products/1');
// //
// //
// //
// //   final List<dynamic> jsonList = jsonDecode(dat1);
// //   productList.addAll(jsonList.map((json) => Products.fromJson(json)).toList())  ;
// //
// //
// //
// //   print('Response is $dat1');
// //
// //
// // }




// }


// // void setUsername(String name) {
// //   username.value = name;
// // }