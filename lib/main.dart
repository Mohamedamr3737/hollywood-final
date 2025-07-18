import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import './app/auth/controller/token_controller.dart';
import './general/consts/consts.dart';
import 'app/auth/view/login_page.dart';
import 'app/home/view/home.dart';
import 'app/home/controller/profile_controller.dart';
import 'app/home/controller/notifications_controller.dart';
import 'app/widgets/splash_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase if needed.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  Get.put(NotificationsController());
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isLogin = false;
  bool _showSplash = true;

  checkIfLogin() async {
      if (await getAccessToken()!=null) {
        setState(() {
          isLogin = true;
        });
      }else {
        setState(() {
          isLogin = false;
        });      }
  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
    // Hide splash after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smedical',
      theme: ThemeData(
        primaryColor: AppColors.primeryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4B2EAD)),
        useMaterial3: true,
      ),
      home: _showSplash
          ? SplashScreen(
              onFinish: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : (isLogin ? const Home() : const LoginView()),
    );
  }
}
