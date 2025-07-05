import 'package:s_medi/about/about.dart';
import 'package:s_medi/app/auth/controller/login_controller.dart';
import 'package:s_medi/app/auth/view/MainPage.dart';
import 'package:s_medi/app/widgets/coustom_textfield.dart';
import 'package:s_medi/general/consts/consts.dart';
import 'package:s_medi/serv/servicespage.dart';
import '../reset_password/reset_password.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/coustom_button.dart';
import 'signup_page.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(LoginController());
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image with overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
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
                    
                    // Welcome content
                    Positioned(
                      bottom: 40,
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
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Hollywood Clinic',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Login Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      Text(
                        'Enter your credentials to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      CoustomTextField(
                        label: 'Phone Number',
                        validator: controller.validateemail,
                        textcontroller: controller.emailController,
                        icon: Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                        hint: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CoustomTextField(
                        label: 'Password',
                        validator: controller.validpass,
                        textcontroller: controller.passwordController,
                        icon: Icon(Icons.lock_outline, color: AppColors.primaryColor),
                        hint: AppString.passwordHint,
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => const UsernameResetPage());
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Obx(
                        () => CoustomButton(
                          onTap: () async {
                            await controller.loginUser(context);
                          },
                          title: AppString.login,
                          isLoading: controller.isLoading.value,
                          width: double.infinity,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppString.dontHaveAccount,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => const SignupView());
                            },
                            child: Text(
                              AppString.signup,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom Navigation
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(
                      context,
                      Icons.medical_services_outlined,
                      "Services",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ServicesPage()),
                      ),
                    ),
                    _buildBottomNavItem(
                      context,
                      Icons.home_outlined,
                      "Home",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      ),
                    ),
                    _buildBottomNavItem(
                      context,
                      Icons.info_outline,
                      "About",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
