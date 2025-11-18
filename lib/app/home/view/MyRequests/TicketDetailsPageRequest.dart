// ticket_details_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/requests_controller.dart';
import 'AddCommentPageRequest.dart';
import 'package:s_medi/general/services/alert_service.dart';

class TicketDetailsPage extends StatefulWidget {
  final Map<String, dynamic> request;

  const TicketDetailsPage({Key? key, required this.request}) : super(key: key);

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late Map<String, dynamic> _request;
  final _requestsController = RequestsController();

  bool _isClosing = false;
  String? _closeErrorMessage;

  @override
  void initState() {
    super.initState();
    // Make a local copy so we can modify or update data
    _request = Map.from(widget.request);
  }

  // Navigate to AddCommentPage, passing the ticket's ID
  // If a new comment is returned, add it to the local comments list
  Future<void> _goToAddComment() async {
    final ticketId = _request['id']?.toString() ?? '';
    if (ticketId.isEmpty) {
      AlertService.error(context, "No valid ticket ID");
      return;
    }

    final newComment = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddCommentPage(ticketId: ticketId),
      ),
    );

    if (newComment != null) {
      final commentsList = _request['comments'] as List<dynamic>;
      commentsList.add(newComment);
      setState(() {});
    }
  }

  // Close ticket by calling the new API
  Future<void> _closeTicket() async {
    final ticketId = _request['id'];
    if (ticketId == null) return;

    setState(() {
      _isClosing = true;
      _closeErrorMessage = null;
    });

    try {
      final response = await _requestsController.closeTicket(ticketId);
      final updatedTicket = response['data'] as Map<String, dynamic>;

      // Update our local _request with the new data (status, etc.)
      setState(() {
        _request = updatedTicket;
      });

      // Optionally pop back with updated data
      Navigator.of(context).pop(_request);

    } catch (e) {
      setState(() {
        _closeErrorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isClosing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = _request['subject'] ?? 'No Title';
    final description = _request['description'] ?? 'No Details';
    final createdAt = _request['created_at'] ?? '';
    final status = _request['status'] ?? '';
    final files = _request['files'] as List<dynamic>? ?? [];
    final comments = _request['comments'] as List<dynamic>? ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // (A) Sparkly background
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 150,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          // (B) Lotus circle icon
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
          // (C) Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(_request),
              ),
              title: const Text(
                "Ticket Details",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (D) Main content
          Positioned.fill(
            top: 250,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text("Title", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Details
                  const Text("Details", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  // Files (if any)
                  if (files.isNotEmpty) ...[
                    const Text("Files", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    ...files.map((f) {
                      final link = f['link']?.toString() ?? '';
                      return FileItem(fileLink: link);
                    }).toList(),
                    const SizedBox(height: 8),
                  ],

                  // Date
                  const Text("Date", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(createdAt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Status
                  const Text("Status", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  // Potential error from closing the ticket
                  if (_closeErrorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Error closing ticket: $_closeErrorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  const Divider(),

                  // Comments
                  const Text(
                    "Comments",
                    style: TextStyle(fontSize: 18, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  comments.isEmpty
                      ? const Text(
                    "No Comments!",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                      : Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (ctx, idx) {
                        final c = comments[idx] as Map<String, dynamic>;
                        final commentText = c['comment'] ?? '';
                        final commentFiles = c['files'] as List<dynamic>? ?? [];
                        final commentBy = c['by'] ?? '';
                        final commentDate = c['created_at'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(commentText, style: const TextStyle(fontSize: 16)),
                              if (commentFiles.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: commentFiles.map((cf) {
                                    final fileLink = cf['link']?.toString() ?? '';
                                    return SizedBox(
                                      width: 120,
                                      child: FileItem(fileLink: fileLink),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                "By: $commentBy on $commentDate",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // (E) Bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // "New comment" button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _goToAddComment,
                      child: const Text(
                        "New comment",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // "Close Ticket" button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isClosing ? null : _closeTicket,
                      child: _isClosing
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Close Ticket",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A small widget that displays a file link with a shortened name and opens on tap
class FileItem extends StatelessWidget {
  final String fileLink;

  const FileItem({Key? key, required this.fileLink}) : super(key: key);

  Future<void> _openFile() async {
    final uri = Uri.parse(fileLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = fileLink.split('/').last;

    return GestureDetector(
      onTap: _openFile,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
