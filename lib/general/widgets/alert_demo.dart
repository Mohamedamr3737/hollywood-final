// import 'package:flutter/material.dart';
// import '../services/alert_service.dart';

// class AlertDemo extends StatelessWidget {
//   const AlertDemo({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Liquid Glass Alert Demo'),
//         backgroundColor: Colors.purple,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Liquid Glass Alert System Demo',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
            
//             // Success Alert
//             ElevatedButton(
//               onPressed: () => AlertService.success(context, "Operation completed successfully!"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Show Success Alert',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Error Alert
//             ElevatedButton(
//               onPressed: () => AlertService.error(context, "Something went wrong! Please try again."),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Show Error Alert',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Warning Alert
//             ElevatedButton(
//               onPressed: () => AlertService.warning(context, "Please check your input before proceeding."),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Show Warning Alert',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Info Alert
//             ElevatedButton(
//               onPressed: () => AlertService.info(context, "Here's some helpful information for you."),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Show Info Alert',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Custom Alert
//             ElevatedButton(
//               onPressed: () => AlertService.show(
//                 context,
//                 message: "This is a custom alert with longer duration",
//                 type: AlertType.info,
//                 duration: const Duration(seconds: 5),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Show Custom Alert (5s)',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 30),
            
//             const Text(
//               'Features:\n'
//               '• Liquid glass design with blur effects\n'
//               '• Smooth animations and transitions\n'
//               '• Auto-dismiss with customizable duration\n'
//               '• Tap to dismiss functionality\n'
//               '• Color-coded by alert type\n'
//               '• Unified API for all alerts',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white70,
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
