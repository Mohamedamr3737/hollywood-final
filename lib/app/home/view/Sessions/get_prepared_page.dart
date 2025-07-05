import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../general/consts/colors.dart';

class GetPreparedPage extends StatelessWidget {
  final String htmlContent;
  final String header;

  const GetPreparedPage({super.key, required this.htmlContent, required this.header });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              Container(
                height: 280,
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
                              'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
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
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          header,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ),
                    // Circular Icon and Title
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Session Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Html(
                      data: htmlContent,
                      style: {
                        "body": Style(
                          fontSize: FontSize(16.0),
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 12),
                        ),
                        "h1": Style(
                          fontSize: FontSize(24.0),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D8F),
                          margin: Margins.only(bottom: 16, top: 8),
                        ),
                        "h2": Style(
                          fontSize: FontSize(20.0),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D8F),
                          margin: Margins.only(bottom: 12, top: 8),
                        ),
                        "h3": Style(
                          fontSize: FontSize(18.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          margin: Margins.only(bottom: 10, top: 8),
                        ),
                        "ul": Style(
                          margin: Margins.only(bottom: 12, left: 20),
                        ),
                        "ol": Style(
                          margin: Margins.only(bottom: 12, left: 20),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 4),
                        ),
                        "strong": Style(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D8F),
                        ),
                        "em": Style(
                          fontStyle: FontStyle.italic,
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
