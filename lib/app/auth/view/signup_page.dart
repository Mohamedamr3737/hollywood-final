import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/app/auth/controller/signup_controller.dart';
import 'package:s_medi/app/widgets/loading_indicator.dart';
import 'package:s_medi/general/consts/consts.dart';
import 'login_page.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  
  // Create a unique form key for this specific signup view
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToField() {
    // Improved scroll logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight > 0) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and keyboard height
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f6),
      resizeToAvoidBottomInset: true,
      body: GetBuilder<SignupController>(
        init: SignupController(),
        dispose: (_) => Get.delete<SignupController>(),
        builder: (controller) {
          return Stack(
            children: [
              // Background gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xfff8f8f6),
                      const Color(0xfff8f8f6).withOpacity(0.8),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              // Main content with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Top safe area padding
                              SizedBox(height: MediaQuery.of(context).padding.top + 20),
                              
                              // Image section with conditional height based on keyboard
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: keyboardHeight > 0 
                                    ? availableHeight * 0.15  // Smaller when keyboard is open
                                    : availableHeight * 0.25, // Normal size
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.9),
                                        blurRadius: 8,
                                        offset: const Offset(0, -3),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(50),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.8),
                                          Colors.white.withOpacity(0.4),
                                          Colors.grey.withOpacity(0.2),
                                          Colors.white.withOpacity(0.6),
                                        ],
                                        stops: const [0.0, 0.3, 0.7, 1.0],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.9),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(46),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            // Main image
                                            Container(
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    'https://st5.depositphotos.com/62628780/65781/i/450/depositphotos_657816120-stock-photo-natural-hair-sunflower-portrait-black.jpg',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(46),
                                                ),
                                              ),
                                            ),
                                            // Glass reflection overlay
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(46),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.transparent,
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.1),
                                                  ],
                                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                                ),
                                              ),
                                            ),
                                            // Glass highlight on top edge
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 2,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(0.9),
                                                      Colors.white.withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Content section
                              Flexible(
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 1,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Welcome text with glassmorphism
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.white.withOpacity(0.1),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Welcome To Hollywood Clinic',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black.withOpacity(0.8),
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Create an Account',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // Form section
                                            Form(
                                              key: _signupFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _buildGlassmorphismTextField(
                                                    controller: controller.nameController,
                                                    validator: controller.validateName,
                                                    icon: Icons.person,
                                                    hint: "Full Name",
                                                  ),

                                                  const SizedBox(height: 12),

                                                  _buildGlassmorphismTextField(
                                                    controller: controller.phoneController,
                                                    validator: controller.validatePhone,
                                                    icon: Icons.phone,
                                                    hint: "Phone Number",
                                                  ),

                                                  const SizedBox(height: 12),

                                                  _buildGlassmorphismTextField(
                                                    controller: controller.emailController,
                                                    validator: controller.validateEmail,
                                                    icon: Icons.email_outlined,
                                                    hint: "Email",
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // Glassmorphism Dropdown
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        colors: [
                                                          Colors.white.withOpacity(0.3),
                                                          Colors.white.withOpacity(0.1),
                                                        ],
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.white.withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.05),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                        child: DropdownButtonFormField<String>(
                                                          decoration: InputDecoration(
                                                            prefixIcon: Icon(
                                                              Icons.person,
                                                              color: Colors.black.withOpacity(0.6),
                                                              size: 22,
                                                            ),
                                                            hintText: "Select Gender",
                                                            hintStyle: TextStyle(
                                                              color: Colors.black.withOpacity(0.4),
                                                              fontSize: 15,
                                                            ),
                                                            border: InputBorder.none,
                                                            contentPadding: const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 16
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors.transparent,
                                                          ),
                                                          dropdownColor: Colors.white.withOpacity(0.95),
                                                          style: TextStyle(
                                                            color: Colors.black.withOpacity(0.8),
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
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
                                                    ),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  _buildGlassmorphismTextField(
                                                    controller: controller.passwordController,
                                                    validator: controller.validatePassword,
                                                    icon: Icons.lock,
                                                    hint: "Password",
                                                    isPassword: true,
                                                  ),

                                                  const SizedBox(height: 12),

                                                  _buildGlassmorphismTextField(
                                                    controller: controller.confirmPasswordController,
                                                    validator: controller.validateConfirmPassword,
                                                    icon: Icons.lock,
                                                    hint: "Confirm Password",
                                                    isPassword: true,
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // Terms and conditions with glassmorphism
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.white.withOpacity(0.2),
                                                          Colors.white.withOpacity(0.05),
                                                        ],
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.white.withOpacity(0.1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "By creating an account, you agree to our terms of service and privacy policy and you will receive a confirmation code on your mobile",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black.withOpacity(0.6),
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // Glassmorphism continue button
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.8,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(25),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        colors: [
                                                          const Color.fromARGB(255, 3, 23, 40).withOpacity(0.9),
                                                          const Color.fromARGB(255, 3, 23, 40).withOpacity(0.7),
                                                        ],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color.fromARGB(255, 3, 23, 40).withOpacity(0.3),
                                                          blurRadius: 15,
                                                          offset: const Offset(0, 8),
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white.withOpacity(0.2),
                                                          blurRadius: 1,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.transparent,
                                                        shadowColor: Colors.transparent,
                                                        shape: const StadiumBorder(),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: () async {
                                                        if (_signupFormKey.currentState?.validate() ?? false) {
                                                          await controller.signupUser(context);
                                                        }
                                                      },
                                                      child: controller.isLoading.value
                                                          ? const LoadingIndicator()
                                                          : const Text(
                                                        'Continue',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Login button section - Only show when keyboard is not visible
                              if (keyboardHeight == 0)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account?",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          // Properly dispose current controller before navigation
                                          Get.delete<SignupController>();
                                          Get.offAll(() => const LoginView());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.orange.shade300.withOpacity(0.9),
                                                Colors.orange.shade300.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            AppString.login,
                                            style: const TextStyle(
                                              color: Color.fromARGB(255, 2, 39, 69),
                                              fontSize: 19,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassmorphismTextField({
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: isPassword,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            onTap: _scrollToField,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.black.withOpacity(0.6),
                size: 22,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}