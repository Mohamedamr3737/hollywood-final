import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import '../view/login_page.dart';
import '../../widgets/coustom_textfield.dart';
import '../../widgets/coustom_button.dart';
import '../../../general/consts/colors.dart';

class NewPasswordPage extends StatefulWidget {
  final String username;
  final String otp;
  const NewPasswordPage({Key? key, required this.username, required this.otp})
      : super(key: key);

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> updatePassword() async {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      VxToast.show(context, msg: "Please fill out both password fields");
      return;
    }
    if (newPassword != confirmPassword) {
      VxToast.show(context, msg: "Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        "https://portal.ahmed-hussain.com/api/patient/auth/forget-password-reset");

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "phone": widget.username,
            "code": widget.otp,
            "password": newPassword,
            "password_confirmation": confirmPassword,
          }));

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse["status"] == true) {
        VxToast.show(context, msg: "Password updated successfully!");
        Get.offAll(() => LoginView());
      } else {
        String errorMessage = "";
        if (jsonResponse["message"] is Map) {
          jsonResponse["message"].forEach((key, value) {
            errorMessage += (value is List ? value.join(", ") : value) + "\n";
          });
        } else {
          errorMessage = jsonResponse["message"] ?? "Failed to update password.";
        }
        VxToast.show(context, msg: errorMessage);
      }
    } catch (e) {
      VxToast.show(context, msg: "Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // AppBar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: const Text(
                        'New Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  
                  // Content
                  Positioned(
                    bottom: 30,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create New Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Your new password must be different from previous passwords',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Set New Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a strong password for your account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          CoustomTextField(
                            label: 'New Password',
                            textcontroller: newPasswordController,
                            icon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
                            hint: 'Enter new password',
                            obscureText: true,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          CoustomTextField(
                            label: 'Confirm Password',
                            textcontroller: confirmPasswordController,
                            icon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
                            hint: 'Confirm new password',
                            obscureText: true,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          CoustomButton(
                            onTap: updatePassword,
                            title: "Update Password",
                            isLoading: isLoading,
                            width: double.infinity,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
