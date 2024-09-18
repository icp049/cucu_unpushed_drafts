import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cucu/pages/viewphoto_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final int _postsPerPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (_isLoading) return; // Avoid fetching if already loading

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('createdAt', descending: true)
          .limit(_postsPerPage);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        final posts = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        setState(() {
          _posts.addAll(posts);
          _lastDocument = querySnapshot.docs.last;
          _hasMore = querySnapshot.docs.length == _postsPerPage;
        });
      } else {
        setState(() {
          _hasMore = false; // No more posts to load
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
Future<String?> _fetchUserProfileImage() async {
  User? user = FirebaseAuth.instance.currentUser;

  // Check if the user is authenticated
  if (user == null) {
    print('No authenticated user found.');
    return null;
  }

  try {

    final userDoc = await FirebaseFirestore.instance.collection("Users").doc(user.email).get();

    if (userDoc.exists) {
 
      return userDoc.data()?['imageUrl'] as String?;
    } else {
      print('User document does not exist.');
      return null;
    }
  } catch (e) {
    print('Error fetching user profile image: $e');
    return null;
  }
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Explore'),
    ),
    body: NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchPosts();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Center(child: CircularProgressIndicator());
          }

          final post = _posts[index];

          return FutureBuilder<String?>( 
            future: _fetchUserProfileImage(),
            builder: (context, snapshot) {
              String? profileImageUrl = snapshot.data;

              return GestureDetector( 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPhotoPage(
                        photoUrl: post['imageUrl'],
                        postText: post['postText'] ?? 'No text available',
                        postedBy: post['postedBy'] ?? 'Unknown',
                        createdAt: post['createdAt'].toDate(), 
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // "Posted by" section with circular profile image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : AssetImage('assets/default_profile.png') as ImageProvider,
                              backgroundColor: Colors.grey.shade300,
                              child: profileImageUrl == null || profileImageUrl.isEmpty
                                  ? Icon(Icons.person, size: 20, color: Colors.grey)
                                  : null,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              '${post['postedBy'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                  
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          post['postText'] ?? 'No text available',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                 
                      if (post['imageUrl'] != null)
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.network(
                              post['imageUrl']!,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                        ),

                
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Posted on: ${post['createdAt']?.toDate().toString() ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
}
