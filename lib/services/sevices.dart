import 'package:flutter/material.dart';

class ServicesMainPage extends StatelessWidget {
  const ServicesMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Professional Header with Gradient
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D8F),
                  Color(0xFF1A5F6F),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Healthcare Services',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Welcome Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Comprehensive Care',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Discover our full range of medical services',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Services Categories
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Primary Services
                  _buildServiceCategory(
                    context,
                    'Primary Care',
                    'Essential healthcare services for everyday needs',
                    Icons.local_hospital,
                    const Color(0xFF2E7D8F),
                    [
                      'General Consultations',
                      'Health Checkups',
                      'Preventive Care',
                      'Chronic Disease Management',
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Specialized Services
                  _buildServiceCategory(
                    context,
                    'Specialized Care',
                    'Expert care from specialized medical professionals',
                    Icons.medical_services,
                    const Color(0xFFFF6B35),
                    [
                      'Cardiology',
                      'Dermatology',
                      'Orthopedics',
                      'Neurology',
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Diagnostic Services
                  _buildServiceCategory(
                    context,
                    'Diagnostics',
                    'Advanced diagnostic and imaging services',
                    Icons.biotech,
                    const Color(0xFF2E7D8F),
                    [
                      'Laboratory Tests',
                      'Medical Imaging',
                      'Pathology',
                      'Radiology',
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Emergency Services
                  _buildServiceCategory(
                    context,
                    'Emergency Care',
                    '24/7 emergency medical services and urgent care',
                    Icons.emergency,
                    const Color(0xFFFF6B35),
                    [
                      'Emergency Room',
                      'Urgent Care',
                      'Trauma Care',
                      'Critical Care',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> services,
  ) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Services List
          ...services.map((service) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle learn more or book
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Learn more about $title'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
