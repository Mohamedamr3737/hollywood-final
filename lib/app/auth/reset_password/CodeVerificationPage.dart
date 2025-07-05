import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'NewPasswordPage.dart';
import '../../widgets/coustom_textfield.dart';
import '../../widgets/coustom_button.dart';
import '../../../general/consts/colors.dart';

class CodeVerificationPage extends StatefulWidget {
  final String username;
  const CodeVerificationPage({Key? key, required this.username})
      : super(key: key);

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyCode() async {
    final url = Uri.parse("https://portal.ahmed-hussain.com/api/patient/auth/check-otp");
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(url, body: {
        "phone": widget.username,
        "code": codeController.text,
      });
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true) {
          VxToast.show(context, msg: jsonResponse["message"] ?? "Recovery code is valid.");
          Get.to(() => NewPasswordPage(
            username: widget.username,
            otp: codeController.text,
          ));
        } else {
          VxToast.show(context, msg: jsonResponse["message"] ?? "Incorrect verification code");
        }
      } else {
        VxToast.show(context, msg: "Server error: ${response.statusCode}");
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
                        'Verification',
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
                            Icons.verified_user,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Enter Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Code sent to ${widget.username}',
                          style: const TextStyle(
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
                            'Verification Code',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter the code we sent to your phone',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          CoustomTextField(
                            label: 'Verification Code',
                            textcontroller: codeController,
                            icon: Icon(Icons.code_outlined, color: AppColors.primaryColor),
                            hint: 'Enter verification code',
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          CoustomButton(
                            onTap: () {
                              if (codeController.text.isNotEmpty) {
                                verifyCode();
                              } else {
                                VxToast.show(context, msg: "Please enter the code");
                              }
                            },
                            title: "Verify Code",
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
