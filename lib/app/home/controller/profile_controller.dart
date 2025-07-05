import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../auth/controller/token_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/login_page.dart';

class ProfileController extends GetxController {
  String apiUrl = "https://portal.ahmed-hussain.com/api/patient/profile/me";
  String updateApiUrl = "https://portal.ahmed-hussain.com/api/patient/profile/update";
  String logoutApiUrl = "https://portal.ahmed-hussain.com/api/patient/auth/logout";
  String deleteApiUrl = "https://portal.ahmed-hussain.com/api/patient/auth/delete";

  var userData = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Getter for profile that the UI expects
  Map<String, dynamic>? get profile => userData.isNotEmpty ? userData : null;

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      String? token = await getAccessToken();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userData.assignAll(data['data']);
        errorMessage('');
      } else {
        errorMessage("Failed to fetch profile. Try again later.");
      }
    } catch (e) {
      errorMessage("An error occurred: $e");
    }
    isLoading(false);
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData, BuildContext context) async {
    try {
      String? token = await getAccessToken();

      // Ensure passwords are included only if they are provided
      Map<String, dynamic> finalData = {
        "name": updatedData["name"],
        "gender": updatedData["gender"],
        "birthday": updatedData["birthday"],
        "email": updatedData["email"],
        "address": updatedData["address"],
      };

      if (updatedData.containsKey("password") && updatedData["password"].isNotEmpty) {
        finalData["password"] = updatedData["password"];
        finalData["password_confirmation"] = updatedData["password_confirmation"];
      }

      final response = await http.post(
        Uri.parse(updateApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(finalData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["status"] == true) {
        fetchProfile(); // Refresh profile data
        errorMessage('');

        // Show success message
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Handle API error response
        if (responseData["message"] is Map) {
          errorMessage(responseData["message"].values.join("\n")); // Combine all error messages
        } else {
          errorMessage(responseData["message"] ?? "Failed to update profile.");
        }

        // Show error message in Snackbar
        Get.snackbar(
          "Error",
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print(e);
      errorMessage("An error occurred: $e");

      Get.snackbar(
        "Error",
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// New function to sign out the user.
  Future<void> signOut(BuildContext context) async {
    try {
      // Get the current access token.
      String? token = await getAccessToken();
      if (token == null) {
        Get.snackbar(
          "Error",
          "No token found. Already signed out?",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.post(
        Uri.parse(logoutApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Clear the token from SharedPreferences.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("access_token");

        // Optionally, you can also clear user data.
        userData.clear();

        Get.snackbar(
          "Success",
          "Signed out successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAll(() => const LoginView());

      } else {
        Get.snackbar(
          "Error",
          "Sign out failed: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// New function to delete the user's account.
  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Retrieve the current access token.
      String? token = await getAccessToken();
      if (token == null) {
        Get.snackbar(
          "Error",
          "No token found. You may already be signed out.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.post(
        Uri.parse(deleteApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse["status"] == true) {
        // Clear the token from SharedPreferences.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("access_token");

        // Optionally, clear user data.
        userData.clear();

        Get.snackbar(
          "Success",
          "Account deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to login page.
        Get.offAll(() => LoginView());
      } else {
        String errorMsg = jsonResponse["message"] ?? "Failed to delete account.";
        Get.snackbar(
          "Error",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

}
