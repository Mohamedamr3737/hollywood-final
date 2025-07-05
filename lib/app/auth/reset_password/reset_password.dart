import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'CodeVerificationPage.dart';
import '../../widgets/coustom_textfield.dart';
import '../../widgets/coustom_button.dart';
import '../../../general/consts/colors.dart';

class UsernameResetPage extends StatefulWidget {
  const UsernameResetPage({Key? key}) : super(key: key);

  @override
  _UsernameResetPageState createState() => _UsernameResetPageState();
}

class _UsernameResetPageState extends State<UsernameResetPage> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendVerificationCode(String phone) async {
    final url = Uri.parse("https://portal.ahmed-hussain.com/api/patient/auth/forget-password");

    try {
      final response = await http.post(url, body: {"phone": phone});
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true) {
          String message = jsonResponse["message"];
          String cleanMessage = message.replaceAll(RegExp(r'\d+$'), '').trim();

          VxToast.show(context, msg: cleanMessage);
          Get.to(() => CodeVerificationPage(username: phone));
        } else {
          VxToast.show(context, msg: jsonResponse["message"] ?? "Error occurred");
        }
      } else {
        VxToast.show(context, msg: "Server error: ${response.statusCode}");
      }
    } catch (e) {
      VxToast.show(context, msg: "Error: $e");
    }
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
                        'Reset Password',
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
                            Icons.lock_reset,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Enter your phone number to receive a verification code',
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
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll send you a verification code',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          CoustomTextField(
                            label: 'Phone Number',
                            textcontroller: phoneController,
                            icon: Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                            hint: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          CoustomButton(
                            onTap: () async {
                              String phone = phoneController.text;
                              if (phone.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                await sendVerificationCode(phone);
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                VxToast.show(context, msg: "Please enter a phone number");
                              }
                            },
                            title: "Send Verification Code",
                            isLoading: isLoading,
                            width: double.infinity,
                            icon: Icons.send_outlined,
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
