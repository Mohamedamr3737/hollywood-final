import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/general/consts/consts.dart';
import 'package:s_medi/general/services/alert_service.dart';

class SignupController extends GetxController {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var selectedGender = ''.obs;
  var isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  signupUser(BuildContext context) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/patient/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'gender': selectedGender.value,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['status']) {
        print(responseData['status']);

        // Assuming the API returns a success message
        AlertService.success(context, 'Signup Successful!');
      } else {
        print(responseData);

        String errorMessage = 'Signup Failed!';

        if (responseData['message'] is Map && responseData['message'].isNotEmpty) {
          // Get the first error message dynamically
          var firstKey = responseData['message'].keys.first;
          var firstError = responseData['message'][firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          } else if (firstError is String) {
            errorMessage = firstError;
          }
        }

        AlertService.error(context, errorMessage);
      }

    } catch (e) {
      AlertService.error(context, 'An error occurred. Please try again later.');
    } finally {
      isLoading(false);
    }
  }

  // Validations
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    RegExp emailRegExp = RegExp(r'^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
