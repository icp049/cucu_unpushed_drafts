import 'package:flutter/material.dart';

class ViewPhotoPage extends StatelessWidget {
  final String photoUrl;
  final String postText;
  final String postedBy;
  final DateTime createdAt;

  ViewPhotoPage({
    required this.photoUrl,
    required this.postText,
    required this.postedBy,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(), // Adds a back button
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: photoUrl.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(photoUrl, fit: BoxFit.cover),
                  SizedBox(height: 16),
                  Text(postText, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Posted by: $postedBy', style: TextStyle(fontSize: 14)),
                  Text('Posted on: ${createdAt.toLocal()}',
                      style: TextStyle(fontSize: 14)),
                ],
              )
            : Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
      ),
    );
  }
}
