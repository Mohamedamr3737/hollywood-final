// ticket_details_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/requests_controller.dart';
import 'AddCommentPageRequest.dart';
import '../../../../general/consts/colors.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid ticket ID")),
      );
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
                      onPressed: () => Navigator.pop(context, _request),
                    ),
                    title: const Text(
                      'Ticket Details',
                      style: TextStyle(
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
                          Icons.support_agent_outlined,
                          size: 50,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Request Information',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card
                  Container(
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
                              child: const Icon(Icons.title, color: Color(0xFF2E7D8F), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subject,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Details Card
                  Container(
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
                              child: const Icon(Icons.description, color: Color(0xFF2E7D8F), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Files Section
                  if (files.isNotEmpty) ...[
                    Container(
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
                                child: const Icon(Icons.attach_file, color: Color(0xFF2E7D8F), size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Attachments',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: files.map((file) {
                              final fileLink = file['link']?.toString() ?? '';
                              return SizedBox(
                                width: 120,
                                child: FileItem(fileLink: fileLink),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Info Card
                  Container(
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
                              child: const Icon(Icons.info, color: Color(0xFF2E7D8F), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Information',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('Date: $createdAt', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('Status: $status', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                        if (_closeErrorMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _closeErrorMessage!,
                                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comments Section
                  Container(
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
                              child: const Icon(Icons.comment, color: Color(0xFF2E7D8F), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Comments',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (comments.isEmpty)
                          Text(
                            'No comments yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          )
                        else
                          Column(
                            children: comments.map((comment) {
                              final commentText = comment['comment']?.toString() ?? '';
                              final commentBy = comment['user']?['name']?.toString() ?? 'Unknown';
                              final commentDate = comment['created_at']?.toString() ?? '';
                              final commentFiles = comment['files'] as List<dynamic>? ?? [];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(commentText, style: const TextStyle(fontSize: 16)),
                                    if (commentFiles.isNotEmpty) ...[
                                      const SizedBox(height: 8),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      "By: $commentBy on $commentDate",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D8F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _goToAddComment,
                    icon: const Icon(Icons.comment),
                    label: const Text(
                      "New comment",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isClosing ? null : _closeTicket,
                    icon: _isClosing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.close),
                    label: _isClosing
                        ? const SizedBox.shrink()
                        : const Text(
                            "Close Ticket",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    final fileName = fileLink.split('/').last;
    final shortName = fileName.length > 15 ? '${fileName.substring(0, 15)}...' : fileName;

    return InkWell(
      onTap: () async {
        final url = Uri.parse(fileLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.file_present, color: Colors.grey[600], size: 24),
            const SizedBox(height: 4),
            Text(
              shortName,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
