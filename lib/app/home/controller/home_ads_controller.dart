// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:s_medi/app/auth/controller/token_controller.dart';
import 'package:s_medi/general/consts/consts.dart';

class HomeAd {
  final int id;
  final String name;
  final String imageUrl;
  final String type;

  const HomeAd({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
  });

  factory HomeAd.fromJson(Map<String, dynamic> json) {
    return HomeAd(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      imageUrl: json['image_in_app'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

class HomeAdsController extends GetxController {
  final RxList<HomeAd> ads = <HomeAd>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchAds() async {
    final token = await getAccessToken();
    if (token == null) {
      errorMessage.value = 'Please log in to view ads.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/patient/ads/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>? ?? [];
        ads.assignAll(items.map((item) => HomeAd.fromJson(item as Map<String, dynamic>)));
      } else {
        errorMessage.value = 'Failed to load ads (${response.statusCode}).';
      }
    } catch (error) {
      errorMessage.value = 'Something went wrong while loading ads.';
    } finally {
      isLoading.value = false;
    }
  }
}

