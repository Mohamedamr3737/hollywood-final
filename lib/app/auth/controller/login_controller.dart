// ignore_for_file: unnecessary_import

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:s_medi/general/consts/consts.dart';
import "../../home/view/home.dart";
import 'token_controller.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Base URL of the API
  final String apiUrl = 'https://portal.ahmed-hussain.com/api/auth/login';

  // login user using the API
  loginUser(context) async {
    if (formkey.currentState!.validate()) {
      try {
        isLoading(true);

        // Send the POST request
        var response = await http.post(
          Uri.parse("https://portal.ahmed-hussain.com/api/patient/auth/login"),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            // Adding the necessary CORS headers
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, DELETE',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Accept, Authorization',
          },
          body: jsonEncode({
            'username': emailController.text,
            'password': passwordController.text,
          }),
        );

        // Print response details
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Check the status code and handle the response
        if (response.statusCode == 200 && responseBody['status'] == true) {
          var data = jsonDecode(response.body);
          String accessToken = data['access_token'];
          // Store the tokens and expiration time
          await storeTokens(accessToken);

          String? tokk = await getAccessToken();
print(tokk);
          VxToast.show(context, msg: "Login Successful");

          // Navigate to Home if login is successful
          Get.offAll(() => const Home());
        } else {
          VxToast.show(context, msg: "Wrong user name or password");
        }
      } catch (e) {
        VxToast.show(context, msg: "An error occurred $e");
      } finally {
        isLoading(false);
      }
    }
  }

  // Validate email and password (same as before)
  String? validateemail(value) {
    if (value!.isEmpty) {
      return 'please enter an Phone number';
    }
    // RegExp emailRefExp = RegExp(r'^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRefExp.hasMatch(value)) {
    //   return 'please enter a valid email';
    // }
    return null;
  }

  String? validpass(value) {
    if (value!.isEmpty) {
      return 'please enter a password';
    }
    // RegExp passRegExp = RegExp(r'^.{6,}$');
    // if (!passRegExp.hasMatch(value)) {
    //   return 'Password must contain at least 8 characters';
    // }
    return null;
  }
}
