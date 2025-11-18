import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../auth/controller/token_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/login_page.dart';
import 'package:s_medi/general/consts/consts.dart';
import 'package:s_medi/general/services/alert_service.dart';
class ProfileController with ChangeNotifier {
  String apiUrl = "${ApiConfig.baseUrl}/api/patient/profile/me";
  String updateApiUrl = "${ApiConfig.baseUrl}/api/patient/profile/update";
  String logoutApiUrl = "${ApiConfig.baseUrl}/api/patient/auth/logout";
  String deleteApiUrl = "${ApiConfig.baseUrl}/api/patient/auth/delete";

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchProfile() async {
    try {
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
        userData = data['data'];
        errorMessage = '';
      } else {
        errorMessage = "Failed to fetch profile. Try again later.";
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData, BuildContext context, {File? imageFile}) async {
    try {
      String? token = await getAccessToken();

      // Check if we have an image file to upload
      if (imageFile != null) {
        // Use multipart/form-data for image upload
        var request = http.MultipartRequest('POST', Uri.parse(updateApiUrl));
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        // Add text fields
        request.fields['name'] = updatedData["name"];
        request.fields['gender'] = updatedData["gender"];
        request.fields['birthday'] = updatedData["birthday"];
        request.fields['email'] = updatedData["email"];
        request.fields['address'] = updatedData["address"];
        request.fields['phone'] = updatedData["phone"];

        // Add password fields if provided
        if (updatedData.containsKey("password") && updatedData["password"].isNotEmpty) {
          request.fields['password'] = updatedData["password"];
          request.fields['password_confirmation'] = updatedData["password_confirmation"];
        }

        // Add image file
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        var responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData["status"] == true) {
          fetchProfile(); // Refresh profile data
          errorMessage = '';
          AlertService.success(context, "Profile updated successfully");
        } else {
          if (responseData["message"] is Map) {
            errorMessage = responseData["message"].values.join("\n");
          } else {
            errorMessage = responseData["message"] ?? "Failed to update profile.";
          }
          AlertService.error(context, errorMessage);
        }
      } else {
        // No image file, use regular JSON request
        Map<String, dynamic> finalData = {
          "name": updatedData["name"],
          "gender": updatedData["gender"],
          "birthday": updatedData["birthday"],
          "email": updatedData["email"],
          "address": updatedData["address"],
          "phone": updatedData["phone"],
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
          errorMessage = '';
          AlertService.success(context, "Profile updated successfully");
        } else {
          if (responseData["message"] is Map) {
            errorMessage = responseData["message"].values.join("\n");
          } else {
            errorMessage = responseData["message"] ?? "Failed to update profile.";
          }
          AlertService.error(context, errorMessage);
        }
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
      AlertService.error(context, errorMessage);
    }
    notifyListeners();
  }

  /// New function to sign out the user.
  Future<void> signOut(BuildContext context) async {
    try {
      // Get the current access token.
      String? token = await getAccessToken();
      if (token == null) {
        AlertService.error(context, "No token found. Already signed out?");
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
        userData = null;
        notifyListeners();

        AlertService.success(context, "Signed out successfully");

        Get.offAll(() => const LoginView());

      } else {
        AlertService.error(context, "Sign out failed: ${response.statusCode}");
      }
    } catch (e) {
      AlertService.error(context, "An error occurred: $e");
    }
  }

  /// New function to delete the user's account.
  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Retrieve the current access token.
      String? token = await getAccessToken();
      if (token == null) {
        AlertService.error(context, "No token found. You may already be signed out.");
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
        userData = null;
        notifyListeners();

        AlertService.success(context, "Account deleted successfully");
        // Navigate to login page.
        Get.offAll(() => LoginView());
      } else {
        String errorMsg = jsonResponse["message"] ?? "Failed to delete account.";
        AlertService.error(context, errorMsg);
      }
    } catch (e) {
      AlertService.error(context, "An error occurred: $e");
    }
  }

}
