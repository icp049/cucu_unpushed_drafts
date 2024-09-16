import 'package:cucu/pages/menu_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cucu/pages/add_post.dart';
import 'package:cucu/pages/edit_profile.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cucu/pages/viewphoto_page.dart';

class MyProfilePage extends StatefulWidget {
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Color scaffoldBackgroundColor = Colors.white; // Default color
   Color primaryFontColor = Colors.black; // Default font color


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fetchUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;

            // Update the scaffoldBackgroundColor
            String? colorString = userData['profilePrimaryColor'];
            scaffoldBackgroundColor = colorString != null ? hexToColor(colorString) : Colors.white;


              String? fontColorString = userData['profileFontColor'];
            primaryFontColor = fontColorString != null ? hexToColor(fontColorString) : Colors.black;

            return Scaffold(
              backgroundColor: scaffoldBackgroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCoverPhoto(userData['bannerImageUrl'], userData['imageUrl']),
                    _buildProfileSection(userData['imageUrl'], userData['name'], userData['username']),
                    _buildSocialMetrics(),
                    _buildProfileMenu(),
                    _buildMockList(), // Add mock list here
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPostPage()),
                  );
                },
                backgroundColor: Colors.black,
                child: Icon(Icons.add, color: Colors.white),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Stream<DocumentSnapshot> _fetchUserDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('Users').doc(user.email).snapshots();
    } else {
      throw Exception('User not logged in');
    }
  }

  Widget _buildCoverPhoto(String? bannerImageUrl, String? profileImageUrl) {
    return Stack(
      children: [
        // Cover photo
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bannerImageUrl != null && bannerImageUrl.isNotEmpty
                  ? NetworkImage(bannerImageUrl)
                  : AssetImage('assets/default_cover.png') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scaffoldBackgroundColor, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
              backgroundColor: Colors.grey[300],
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(String? imageUrl, String name, String username) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryFontColor),
                ),
                SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(fontSize: 18, color: primaryFontColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMetrics() {
    const int friendsCount = 27;
    const int followersCount = 1721;
    const int followingCount = 102;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialMetric('Friends', friendsCount),
          SizedBox(width: 16),
          _buildSocialMetric('Followers', followersCount),
          SizedBox(width: 16),
          _buildSocialMetric('Following', followingCount),
        ],
      ),
    );
  }

  Widget _buildSocialMetric(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: primaryFontColor),
        ),
      ],
    );
  }

  Widget _buildMockList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 24, color: primaryFontColor),
              SizedBox(width: 8),
              Text(
                'Posts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryFontColor),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 600,
          child: StreamBuilder<QuerySnapshot>(
            stream: _fetchUserPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                var posts = snapshot.data!.docs;

                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 15,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index].data() as Map<String, dynamic>;

                    double verticalPadding = index.isOdd && index ~/ 2 == 0 ? 50.0 : 0;
                    EdgeInsets sidePadding = index.isEven
                        ? EdgeInsets.only(left: 16.0)
                        : EdgeInsets.only(right: 16.0);

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePadding.left,
                        verticalPadding,
                        sidePadding.right,
                        8.0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewPhotoPage(
                                photoUrl: post['imageUrl'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.primaries[index % Colors.primaries.length],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: post['imageUrl'] != null
                                ? Image.network(
                                    post['imageUrl'],
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No posts available'));
              }
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _fetchUserPostsStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('MyPosts')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      throw Exception('User not logged in');
    }
  }

Widget _buildProfileMenu() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        _buildProfileMenuItem(Icons.explore, 'Explore', 0),
        SizedBox(height: 16),
        _buildProfileMenuItem(Icons.message, 'Messages', 1),
        SizedBox(height: 16),
        _buildProfileMenuItem(Icons.notifications, 'Notifications', 2),
        SizedBox(height: 16),
        _buildProfileMenuItem(Icons.emoji_events, 'Achievements', 3),
      ],
    ),
  );
}

  Widget _buildProfileMenuItem(IconData icon, String label, int pageIndex) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        // Navigate to the MainPage, where the bottom navigation will handle switching pages
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuLandingPage(initialPage: pageIndex)),  // Navigate to the new MainPage
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: primaryFontColor,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );
}


  Color hexToColor(String hexString) {
    hexString = hexString.replaceAll('#', '');
    int colorInt = int.parse(hexString, radix: 16);
    if (hexString.length == 6) {
      colorInt += 0xFF000000;
    }
    return Color(colorInt);
  }
}
