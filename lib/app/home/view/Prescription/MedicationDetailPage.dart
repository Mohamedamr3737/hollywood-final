import 'package:flutter/material.dart';
import '../../../../general/consts/colors.dart';

class MedicationDetailPage extends StatefulWidget {
  // The entire prescription object, e.g.:
  // {
  //   "id": 5,
  //   "created_at": "2019-10-21T15:28:39.000000Z",
  //   "doctor": {"id": 2, "name": "Dr Ahmed Nassar"},
  //   "medications": [
  //     {
  //       "product_id": 2,
  //       "medication_name": "Regimax",
  //       "times": "3",
  //       "form": "Cap",
  //       "comment": "قبل الاكل"
  //     },
  //     ...
  //   ]
  // }
  final Map<String, dynamic> prescription;

  const MedicationDetailPage({
    Key? key,
    required this.prescription,
  }) : super(key: key);

  @override
  State<MedicationDetailPage> createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  // "Set a reminder" => show a time picker
  void _setReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set at ${time.format(context)}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from the prescription map
    final docName = widget.prescription['doctor']?['name'] ?? 'Unknown Doctor';
    final medications = widget.prescription['medications'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
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
                      docName,
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
                        ),
                        child: const Icon(
                          Icons.medication,
                          size: 50,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Medication Details',
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
            child: medications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.medication, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('No Medication Found!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('No medications for this prescription.', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: medications.length,
                    itemBuilder: (ctx, i) {
                      final medItem = medications[i];
                      final medName = medItem['medication_name'] ?? '';
                      final times = medItem['times']?.toString() ?? '';
                      final form = medItem['form'] ?? '';
                      final comment = medItem['comment'] ?? '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.medication, color: Color(0xFF2E7D8F), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    medName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Times: $times', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                Text('Form: $form', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Comment: $comment', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _setReminder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D8F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.alarm),
                                label: const Text('Set A Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
