// ignore_for_file: unused_import, file_names, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s_medi/serv/ServicesPage.dart';
import 'package:s_medi/serv/servicespage.dart';

class ServiceDetailPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final service;

  const ServiceDetailPage({required this.service, Key? key}) : super(key: key);

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Image
            Center(
              child: Image.network(
                widget.service.imagePath,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Title and Details
            Text(
              widget.service.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(widget.service.details, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            // Display two static images under the details
            if (widget.service.detailImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    widget.service.detailImages[0],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  if (widget.service.detailImages.length > 1)
                    Image.network(
                      widget.service.detailImages[1],
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
