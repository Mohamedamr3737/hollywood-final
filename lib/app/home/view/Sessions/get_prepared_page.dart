import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class GetPreparedPage extends StatelessWidget {
  final String htmlContent;
  final String header;

  const GetPreparedPage({super.key, required this.htmlContent, required this.header });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(header),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: htmlContent,
          style: {
            "body": Style(
              fontSize: FontSize(16.0),
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          },
        ),
      ),
    );
  }
}
