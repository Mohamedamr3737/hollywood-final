// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:ui';
import 'package:s_medi/about/about.dart';
import 'package:s_medi/app/auth/controller/login_controller.dart';
import 'package:s_medi/app/auth/view/MainPage.dart';
// ignore: unused_import
import 'package:s_medi/app/widgets/coustom_textfield.dart';
import 'package:s_medi/general/consts/consts.dart';
import 'package:s_medi/serv/servicespage.dart';
import '../reset_password/reset_password.dart';
import '../../widgets/loading_indicator.dart';
import 'signup_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  
  // Create a unique form key for this specific login view
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _scrollToField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight > 0) {
          // Scroll to a more reasonable position instead of maxScrollExtent
          final targetOffset = _scrollController.position.maxScrollExtent * 0.3;
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableHeight = screenHeight - keyboardHeight;

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f6),
      resizeToAvoidBottomInset: true,
      body: GetBuilder<LoginController>(
        init: LoginController(),
        dispose: (_) => Get.delete<LoginController>(),
        builder: (controller) {
          return SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient overlay
                Positioned.fill(
                  child: Container(
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
                ),

                // Main scrollable content
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: keyboardHeight > 0 ? availableHeight : screenHeight,
                          minWidth: screenWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: keyboardHeight == 0 ? 120 : 10,
                          ),
                          child: Column(
                            children: [
                              // Top safe area padding
                              SizedBox(height: MediaQuery.of(context).padding.top + 20),

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    // Image section with adaptive height
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: keyboardHeight > 0 
                                          ? availableHeight * 0.12 
                                          : availableHeight * 0.25,
                                      width: double.infinity,
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
                                            child: Stack(
                                              children: [
                                                // Main image
                                                Positioned.fill(
                                                  child: Image.network(
                                                    'https://st5.depositphotos.com/62628780/65781/i/450/depositphotos_657816120-stock-photo-natural-hair-sunflower-portrait-black.jpg',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey.shade300,
                                                        child: const Center(
                                                          child: Icon(Icons.image_not_supported),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                // Glass reflection overlay
                                                Positioned.fill(
                                                  child: Container(
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

                                    const SizedBox(height: 16),

                                    // Welcome text with glassmorphism container
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Text(
                                            'Welcome to Hollywood Clinic',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black.withOpacity(0.8),
                                              letterSpacing: -0.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Form container - Use unique form key
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                                          child: Form(
                                            key: _loginFormKey, // Use local form key
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Phone number field
                                                _buildGlassmorphismTextField(
                                                  controller: controller.emailController,
                                                  validator: controller.validateemail,
                                                  icon: Icons.phone,
                                                  hint: "Enter your phone number",
                                                ),

                                                const SizedBox(height: 16),

                                                // Password field
                                                _buildGlassmorphismTextField(
                                                  controller: controller.passwordController,
                                                  validator: controller.validpass,
                                                  icon: Icons.key,
                                                  hint: AppString.passwordHint,
                                                  isPassword: true,
                                                ),

                                                const SizedBox(height: 16),

                                                // Forget password link
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Get.to(() => const UsernameResetPage());
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
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
                                                        "Forget Password ?",
                                                        style: TextStyle(
                                                          color: Colors.black.withOpacity(0.7),
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 24),

                                                // Login button
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.75,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(25),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Colors.black.withOpacity(0.9),
                                                        Colors.black.withOpacity(0.7),
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.3),
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
                                                      if (_loginFormKey.currentState?.validate() ?? false) {
                                                        await controller.loginUser(context);
                                                      }
                                                    },
                                                    child: controller.isLoading.value
                                                        ? const LoadingIndicator()
                                                        : Text(
                                                      AppString.login,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 20),

                                                // Sign up link
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      AppString.dontHaveAccount,
                                                      style: TextStyle(
                                                        color: Colors.black.withOpacity(0.6),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Properly dispose current controller before navigation
                                                        Get.delete<LoginController>();
                                                        Get.offAll(() => const SignupView());
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
                                                          AppString.signup,
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
                                              ],
                                            ),
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
                    ),
                  ),
                ),

                // Bottom navigation - Only show when keyboard is not visible
                if (keyboardHeight == 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth,
                      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 16,
                              bottom: MediaQuery.of(context).padding.bottom + 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(25),
                              ),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildNavItem(
                                    icon: Icons.group,
                                    label: "Services",
                                    onTap: () {
                                      _onNavTap();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ServicesPage()),
                                      );
                                    },
                                  ),

                                  // Center home button with special animation
                                  GestureDetector(
                                    onTap: () {
                                      _onNavTap();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MainPage()),
                                      );
                                    },
                                    child: AnimatedBuilder(
                                      animation: _scaleAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _scaleAnimation.value,
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
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
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(30),
                                                    child: Image.network(
                                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps',
                                                      width: 35,
                                                      height: 35,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.home, color: Colors.black54);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  _buildNavItem(
                                    icon: Icons.info_outline,
                                    label: "About",
                                    onTap: () {
                                      _onNavTap();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AboutPage()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
      width: double.infinity,
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
              fontSize: 16,
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
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.black.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}