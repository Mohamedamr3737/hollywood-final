// add_comment_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../controller/requests_controller.dart';
import 'package:s_medi/general/services/alert_service.dart';

class AddCommentPage extends StatefulWidget {
  final String ticketId; // e.g. "58"

  const AddCommentPage({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  final RequestsController _requestsController = RequestsController();

  String? _filePath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  // Pick any document (PDF, docx, etc.)
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.first.path;
      });
    }
  }

  // Pick images/videos (media)
  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.first.path;
      });
    }
  }

  // Submit the comment to the API
  Future<void> _submitComment() async {
    final commentText = _messageCtrl.text.trim();
    if (commentText.isEmpty) {
      AlertService.warning(context, "Please enter a message");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the controller function to POST the comment
      final responseJson = await _requestsController.addComment(
        ticketId: widget.ticketId,
        commentText: commentText,
        filePath: _filePath, // optional
      );

      // The server usually returns { "data": { ...comment... }, "status": true, ... }
      // We'll extract the new comment object
      final newComment = responseJson['data']; // e.g. { "id": 72, "comment": "...", "files": [...] }

      // Return the new comment to the previous screen
      Navigator.of(context).pop(newComment);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same top background + lotus style
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
          // (B) Lotus
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
          // (C) AppBar
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
                "Add Comment",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // (D) Form
          Positioned.fill(
            top: 250,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (_errorMessage != null) ...[
                      Text(
                        "Error: $_errorMessage",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Message
                    TextFormField(
                      controller: _messageCtrl,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: "Message",
                        hintText: "Enter your comment",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Attached file
                    Row(
                      children: [
                        const Text("Attached file:"),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _pickDocument,
                          child: const Text("Document", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _pickMedia,
                          child: const Text("Media", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (_filePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _filePath!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Add Comment
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Add Comment",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}