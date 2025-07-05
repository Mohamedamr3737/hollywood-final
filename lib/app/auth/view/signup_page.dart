import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/app/auth/controller/signup_controller.dart';
import 'package:s_medi/app/home/view/home.dart';
import 'package:s_medi/app/widgets/coustom_textfield.dart';
import 'package:s_medi/app/widgets/loading_indicator.dart';
import 'package:s_medi/app/widgets/coustom_button.dart';
import 'package:s_medi/general/consts/colors.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SignupController());
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Background image with overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        image: DecorationImage(
                          image: const NetworkImage(
                            'https://st5.depositphotos.com/62628780/65781/i/450/depositphotos_657816120-stock-photo-natural-hair-sunflower-portrait-black.jpg',
                          ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.withOpacity(0.8),
                            BlendMode.overlay,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // AppBar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      title: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  
                  // Welcome text
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join Hollywood Clinic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Start your health journey with us',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Full Name',
                        textcontroller: controller.nameController,
                        hint: "Enter your full name",
                        icon: Icon(Icons.person_outline, color: AppColors.primaryColor),
                        validator: controller.validateName,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Phone Number',
                        textcontroller: controller.phoneController,
                        icon: Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                        hint: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Email Address',
                        textcontroller: controller.emailController,
                        icon: Icon(Icons.email_outlined, color: AppColors.primaryColor),
                        hint: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gender Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.surfaceColor,
                              border: Border.all(color: AppColors.bgDarkColor),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              hint: Text(
                                "Select Gender",
                                style: TextStyle(color: AppColors.textLight),
                              ),
                              items: ['Male', 'Female', 'Other']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                controller.selectedGender.value = value!;
                              },
                              validator: (value) => value == null
                                  ? 'Please select a gender'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Password',
                        textcontroller: controller.passwordController,
                        icon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
                        hint: "Create a password",
                        obscureText: true,
                        validator: controller.validatePassword,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Confirm Password',
                        textcontroller: controller.confirmPasswordController,
                        icon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
                        hint: "Confirm your password",
                        obscureText: true,
                        validator: controller.validateConfirmPassword,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Terms and conditions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          "By creating an account, you agree to our Terms of Service and Privacy Policy. You will receive a confirmation code on your mobile.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Obx(
                        () => CoustomButton(
                          onTap: () async {
                            await controller.signupUser(context);
                          },
                          title: 'Create Account',
                          isLoading: controller.isLoading.value,
                          width: double.infinity,
                          icon: Icons.person_add_outlined,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
