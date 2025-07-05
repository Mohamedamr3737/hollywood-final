// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../view/login_page.dart';

Future<void> storeTokens(String accessToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // // Get the current time
  // DateTime now = DateTime.now();
  //
  // // Calculate the expiration time of the access token
  // DateTime expiryTime = now.add(Duration(seconds: expiresIn));

  // Store tokens and expiration time
  await prefs.setString('access_token', accessToken);
  // await prefs.setString('access_token_expiry', expiryTime.toIso8601String());
}


// Method to retrieve the access token from SharedPreferences
Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token'); // Retrieve the stored token
}

void checkLoginStatus() async {
  if (await getAccessToken() == null) {
    Get.offAll(() => const LoginView());
  }
}

Future<bool> checkLoginStatusBool() async {
  if (await getAccessToken() == null) {
    return false;
  }else{
    return true;
  }
}

// Future<String?> refreshAccessToken() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? access_token = prefs.getString('access_token'); // Retrieve the stored token
//
//   // Make the request to refresh the access token
//   var response = await http.post(
//     Uri.parse(
//         'https://portal.ahmed-hussain.com/api/patient/auth/refresh'), // Replace with your API endpoint
//     headers: {
//       'Authorization':
//           'Bearer $access_token', // Add the Bearer token to the header
//       'Accept': 'application/json',
//     },
//   );
//
//   if (response.statusCode == 200) {
//     var responseData = jsonDecode(response.body);
//     String newAccessToken = responseData['access_token'];
//     // int expiresIn = responseData['expires_in'];
//
//     // Store the new access token and expiration time
//     await storeTokens(newAccessToken);
//
//     print("Access token refreshed successfully.");
//     return newAccessToken; // Return the new access token
//   } else {
//     print('Failed to refresh access token: ${response.body}');
//     // return null; // Token refresh failed
//     Get.offAll(() => const LoginView());
//   }
//
//   Get.offAll(() => const LoginView());
//   return null;
// }
