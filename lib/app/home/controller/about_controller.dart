import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class AboutController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var aboutData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutData();
  }

  Future<void> fetchAboutData() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final bearerToken = await getAccessToken();
      const url = 'https://portal.ahmed-hussain.com/api/patient/about';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          aboutData.assignAll(jsonData['data']);
        } else {
          // If API doesn't return data, use default values
          aboutData.assignAll({
            'title': 'Welcome to HealthCare+',
            'mission': 'To deliver exceptional healthcare services that improve the quality of life for our patients through innovative treatments, compassionate care, and cutting-edge technology.',
            'services_description': 'We offer a wide range of medical services including consultations, diagnostics, treatments, wellness programs, and specialized care tailored to your needs.',
            'contact': {
              'phone': '+1 (555) 123-4567',
              'email': 'info@healthcareplus.com',
              'address': '123 Healthcare St, Medical City, MC 12345',
              'website': 'www.healthcareplus.com'
            }
          });
        }
      } else {
        // If API fails, use default values
        aboutData.assignAll({
          'title': 'Welcome to HealthCare+',
          'mission': 'To deliver exceptional healthcare services that improve the quality of life for our patients through innovative treatments, compassionate care, and cutting-edge technology.',
          'services_description': 'We offer a wide range of medical services including consultations, diagnostics, treatments, wellness programs, and specialized care tailored to your needs.',
          'contact': {
            'phone': '+1 (555) 123-4567',
            'email': 'info@healthcareplus.com',
            'address': '123 Healthcare St, Medical City, MC 12345',
            'website': 'www.healthcareplus.com'
          }
        });
      }
    } catch (e) {
      errorMessage(e.toString());
      // Use default values on error
      aboutData.assignAll({
        'title': 'Welcome to HealthCare+',
        'mission': 'To deliver exceptional healthcare services that improve the quality of life for our patients through innovative treatments, compassionate care, and cutting-edge technology.',
        'services_description': 'We offer a wide range of medical services including consultations, diagnostics, treatments, wellness programs, and specialized care tailored to your needs.',
        'contact': {
          'phone': '+1 (555) 123-4567',
          'email': 'info@healthcareplus.com',
          'address': '123 Healthcare St, Medical City, MC 12345',
          'website': 'www.healthcareplus.com'
        }
      });
    } finally {
      isLoading(false);
    }
  }
} 