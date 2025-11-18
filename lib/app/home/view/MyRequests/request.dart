// requests_flow.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/requests_controller.dart'; // <-- Import your controller
import 'AddTicketPageRequest.dart';
import 'TicketDetailsPageRequest.dart';

class MyRequestsPage extends StatefulWidget {
  final int category; // e.g. "Ask Doctor", "Sessions", etc.

  const MyRequestsPage({Key? key, required this.category}) : super(key: key);

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // We'll store each request as a Map<String, dynamic>
  final List<Map<String, dynamic>> openRequests = [];
  final List<Map<String, dynamic>> resolvedRequests = [];
  final List<Map<String, dynamic>> closedRequests = [];
  final List<Map<String, dynamic>> closedByCustomerRequests = [];

  bool _isLoading = false;
  String? _errorMessage;

  final _requestsController = RequestsController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  // Fetch requests from the API and distribute them by status
  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestsList = await _requestsController.fetchMyRequests(widget.category);

      // Temporary lists to categorize by status
      final List<Map<String, dynamic>> open = [];
      final List<Map<String, dynamic>> resolved = [];
      final List<Map<String, dynamic>> closed = [];
      final List<Map<String, dynamic>> closedByCustomer = [];

      for (final r in requestsList) {
        final status = r['status'] ?? '';

        // Sort each request into the right list
        if (status == 'open') {
          open.add(r);
        } else if (status == 'Resolved') {
          resolved.add(r);
        } else if (status == 'Closed') {
          closed.add(r);
        } else if (status == 'Closed by customer') {
          closedByCustomer.add(r);
        }
      }

      // Update our lists
      setState(() {
        openRequests
          ..clear()
          ..addAll(open);
        resolvedRequests
          ..clear()
          ..addAll(resolved);
        closedRequests
          ..clear()
          ..addAll(closed);
        closedByCustomerRequests
          ..clear()
          ..addAll(closedByCustomer);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // "Add new ticket" button
  void _goToAddTicket() async {
    // In your code, AddTicketPage returns a "Ticket",
    // but you can change it to return a Map<String, dynamic> if you prefer
    final newRequest = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddTicketPage(category: widget.category),
      ),
    );
    if (newRequest != null) {
      // Typically new requests are "open"
      setState(() {
        openRequests.add(newRequest);
      });
    }
  }

  // Tapping on a request -> see details
  // If the user updates the request status, reflect in our lists
  void _goToRequestDetails(Map<String, dynamic> request) async {
    // // In your code, TicketDetailsPage expects a "Ticket" class,
    // // but you can change it to accept a Map<String, dynamic> instead
    final updatedRequest = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => TicketDetailsPage(request: request),
      ),
    );
    if (updatedRequest != null) {
      // Remove it from all lists first
      openRequests.removeWhere((r) => r['id'].toString() == updatedRequest['id'].toString());
      resolvedRequests.removeWhere((r) => r['id'].toString() == updatedRequest['id'].toString());
      closedRequests.removeWhere((r) => r['id'].toString() == updatedRequest['id'].toString());
      closedByCustomerRequests.removeWhere((r) => r['id'].toString() == updatedRequest['id'].toString());

      // Re-insert based on updated status
      final newStatus = updatedRequest['status'] ?? '';
      if (newStatus == 'open') {
        openRequests.add(updatedRequest);
      } else if (newStatus == 'Resolved') {
        resolvedRequests.add(updatedRequest);
      } else if (newStatus == 'Closed') {
        closedRequests.add(updatedRequest);
      } else if (newStatus == 'Closed by customer') {
        closedByCustomerRequests.add(updatedRequest);
      }

      setState(() {});
    }
  }

  // Build a single request card
  Widget _buildRequestCard(Map<String, dynamic> request) {
    // Extract the fields
    final subject = request['subject'] ?? '';
    final description = request['description'] ?? '';
    final createdAt = request['created_at'] ?? '';

    // We'll store the first file link in "filePath"
    final files = request['files'] as List<dynamic>? ?? [];
    String? filePath;
    if (files.isNotEmpty) {
      filePath = files[0]['link']?.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToRequestDetails(request),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title label
            const Text(
              "Title",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            // Subject
            Text(
              subject,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Details label
            const Text(
              "Details",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            // Description
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // File path (if any)
            if (filePath != null && filePath.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      filePath,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Date label
            const Text(
              "Date",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              createdAt,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Build a list of requests for each tab
  Widget _buildRequestsList(List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          "Empty Tickets!",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _buildRequestCard(req);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Decide what to show: spinner, error, or normal tabbed UI
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Text(
          "Error: $_errorMessage",
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    } else {
      content = Column(
        children: [
          Container(
            color: const Color(0xFF000610),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orangeAccent,
              labelColor: Colors.orangeAccent,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              tabs: const [
                Tab(text: "open"),
                Tab(text: "Resolved"),
                Tab(text: "Closed"),
                Tab(text: "Closed by customer"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(openRequests),
                _buildRequestsList(resolvedRequests),
                _buildRequestsList(closedRequests),
                _buildRequestsList(closedByCustomerRequests),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // (1) Sparkly background
          Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  'https://t3.ftcdn.net/jpg/03/66/08/34/360_F_366083470_jTuk7ZhaXxlk3paaPIxxPv2jUQhe1tQb.jpg',                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // (2) Lotus icon
          Positioned(
            top: 110,
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
          // (3) AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "My Requests",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (4) Main content (tabs, spinner, or error)
          Positioned.fill(
            top: 250,
            child: content,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: _goToAddTicket,
        label: const Text(
          "Add new ticket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
