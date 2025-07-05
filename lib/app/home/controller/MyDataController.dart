import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/controller/token_controller.dart';
import 'package:get/get.dart';

// -----------------------------
// Model Classes
// -----------------------------

// Data item (each image entry)
class DataItem {
  final int id;
  final String image;
  final String date;

  DataItem({
    required this.id,
    required this.image,
    required this.date,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      id: json['id'],
      image: json['image'],
      date: json['date'],
    );
  }
}

// Compare data with first and last images (if needed later)
class CompareData {
  final DataItem first;
  final DataItem last;

  CompareData({
    required this.first,
    required this.last,
  });

  factory CompareData.fromJson(Map<String, dynamic> json) {
    return CompareData(
      first: DataItem.fromJson(json['first']),
      last: DataItem.fromJson(json['last']),
    );
  }
}

// Response data that contains both my_data and compare
class DataResponse {
  final List<DataItem> myData;
  final CompareData compare;

  DataResponse({
    required this.myData,
    required this.compare,
  });

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    var list = json['my_data'] as List;
    List<DataItem> myDataList =
    list.map((item) => DataItem.fromJson(item)).toList();

    return DataResponse(
      myData: myDataList,
      compare: CompareData.fromJson(json['compare']),
    );
  }
}

class Category {
  final int id;
  final String title;

  Category({required this.id, required this.title});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
    );
  }
}

/// -----------------------------------------
/// Controller class to fetch categories
/// -----------------------------------------
class MyDataController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var myDataList = <DataItem>[].obs;
  var categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await fetchCategories();
      // Fetch data for the first category if available
      if (categories.isNotEmpty) {
        await fetchMyData(categories.first.id);
      }
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  Future<void> fetchMyData(int categoryId) async {
    try {
      isLoading(true);
      errorMessage('');
      
      final dataResponse = await fetchData(categoryId);
      myDataList.assignAll(dataResponse.myData);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    try {
      String? token = await getAccessToken();
      const String apiUrl =
          'https://portal.ahmed-hussain.com/api/patient/my-data/categories';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == true) {
          final List<dynamic> data = body['data'];
          final categoryList = data.map((json) => Category.fromJson(json)).toList();
          categories.assignAll(categoryList);
        } else {
          throw Exception('API error: ${body['message']}');
        }
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
      rethrow;
    }
  }

  Future<DataResponse> fetchData(int categoryId) async {
    String? token = await getAccessToken();
    final String apiUrl =
        'https://portal.ahmed-hussain.com/api/patient/my-data/data?category_id=$categoryId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      if (jsonBody['status'] == true) {
        return DataResponse.fromJson(jsonBody['data']);
      } else {
        throw Exception('API Error: ${jsonBody['message']}');
      }
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }
}
