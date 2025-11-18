import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/AppointmentsController.dart';
import 'MyAppointmentsPage.dart';
import 'RequestAppointment.dart';
import 'AppointmentDetailsPage.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> _appointments = [];
  bool _isLoading = false; // Local loading flag

  final AppointmentsController appointmentsController =
  Get.put(AppointmentsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedAppointments =
      await appointmentsController.fetchAppointments();
      setState(() {
        _appointments = fetchedAppointments;
      });
    } catch (e) {
      // Optionally, show a SnackBar with the error.
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _goToAppointmentPreview(Map<String, String> appointment) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailPage(appointment: appointment),
      ),
    );

    if (result != null) {
      if (result['action'] == 'cancel') {
        // Appointment was canceled; refresh from the API
        _loadAppointments();
      } else {
        // Appointment was edited; update local list if needed
        setState(() {
          final index = _appointments.indexWhere(
                (appt) => appt['id'] == result['id'],
          );
          if (index != -1) {
            _appointments[index] = result;
          }
        });
      }
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a Stack to build custom background, circular icon, and AppBar.
      body: Stack(
        children: [
          // (1) Background image.
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // (2) Positioned circular lotus icon.
          Positioned(
            top: 140,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )

          ),
          // (3) Positioned content: Tabs and Tab Views.
          Positioned.fill(
            top: 280,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.orangeAccent,
                  labelColor: Colors.orangeAccent,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "My Appointments"),
                    Tab(text: "Request Appointment"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      MyAppointmentsPage(
                        appointments: _appointments,
                        onTapAppointment: (appointment) {
                          _goToAppointmentPreview(appointment);
                        },
                      ),
                      RequestAppointmentPage(
                        onAppointmentAdded: (appointmentData) {
                          _loadAppointments();
                          _tabController.animateTo(0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // (4) Custom AppBar at the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "Appointments",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (5) Loading overlay (shows circular progress indicator).
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
