import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class ServicesController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var services = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final bearerToken = await getAccessToken();
      const url = 'https://portal.ahmed-hussain.com/api/patient/services';

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
          final servicesList = List<Map<String, dynamic>>.from(jsonData['data']);
          services.assignAll(servicesList);
        } else {
          // If API doesn't return data, use default services
          services.assignAll(_getDefaultServices());
        }
      } else {
        // If API fails, use default services
        services.assignAll(_getDefaultServices());
      }
    } catch (e) {
      errorMessage(e.toString());
      // Use default services on error
      services.assignAll(_getDefaultServices());
    } finally {
      isLoading(false);
    }
  }

  List<Map<String, dynamic>> _getDefaultServices() {
    return [
      {
        'id': 1,
        'title': 'Consultations',
        'description': 'Expert medical consultations with experienced doctors',
        'icon': 'person_search',
        'color': '#2E7D8F',
        'features': [
          'General Health Checkups',
          'Specialist Consultations',
          'Preventive Care',
          'Health Screenings'
        ]
      },
      {
        'id': 2,
        'title': 'Diagnostics',
        'description': 'Advanced diagnostic services and laboratory tests',
        'icon': 'biotech',
        'color': '#FF6B35',
        'features': [
          'Laboratory Tests',
          'Medical Imaging',
          'Pathology Services',
          'Radiology'
        ]
      },
      {
        'id': 3,
        'title': 'Treatments',
        'description': 'Comprehensive treatment plans tailored to your needs',
        'icon': 'healing',
        'color': '#2E7D8F',
        'features': [
          'Medical Procedures',
          'Surgical Services',
          'Therapy Programs',
          'Rehabilitation'
        ]
      },
      {
        'id': 4,
        'title': 'Wellness',
        'description': 'Wellness programs and preventive healthcare services',
        'icon': 'spa',
        'color': '#FF6B35',
        'features': [
          'Nutrition Counseling',
          'Fitness Programs',
          'Mental Health Support',
          'Lifestyle Coaching'
        ]
      },
      {
        'id': 5,
        'title': 'Emergency',
        'description': '24/7 emergency medical services and urgent care',
        'icon': 'emergency',
        'color': '#2E7D8F',
        'features': [
          'Emergency Room',
          'Urgent Care',
          'Trauma Services',
          'Critical Care'
        ]
      },
      {
        'id': 6,
        'title': 'Pharmacy',
        'description': 'Full-service pharmacy with prescription management',
        'icon': 'local_pharmacy',
        'color': '#FF6B35',
        'features': [
          'Prescription Filling',
          'Medication Counseling',
          'Health Products',
          'Delivery Services'
        ]
      }
    ];
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'person_search':
        return Icons.person_search;
      case 'biotech':
        return Icons.biotech;
      case 'healing':
        return Icons.healing;
      case 'spa':
        return Icons.spa;
      case 'emergency':
        return Icons.emergency;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.medical_services;
    }
  }

  Color _getColorFromString(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2E7D8F);
    }
  }

  IconData getServiceIcon(Map<String, dynamic> service) {
    final iconName = service['icon'] ?? 'medical_services';
    return _getIconFromString(iconName);
  }

  Color getServiceColor(Map<String, dynamic> service) {
    final colorHex = service['color'] ?? '#2E7D8F';
    return _getColorFromString(colorHex);
  }
} 