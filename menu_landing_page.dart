import 'package:flutter/material.dart';
import 'package:cucu/pages/achievements_page.dart';
import 'package:cucu/pages/messages_page.dart';
import 'package:cucu/pages/notifications_page.dart';
import 'package:cucu/pages/explore_page.dart';

class MenuLandingPage extends StatefulWidget {


  final int initialPage;

  MenuLandingPage({this.initialPage = 0}); // default to 'Explore'

  @override
  _MenuLandingPageState createState() => _MenuLandingPageState();
}

class _MenuLandingPageState extends State<MenuLandingPage> {
   late int _currentIndex;


   @override
  void initState() {
    super.initState();
    // Set the initial page based on the passed argument
    _currentIndex = widget.initialPage;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: _getPage(_currentIndex),
        
      
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
          ],
        ),
      ),
    );

  }


   Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ExplorePage();
      case 1:
        return MessagesPage();
      case 2:
        return NotificationsPage();
      case 3:
        return AchievementsPage();
      default:
        return ExplorePage();
    }
  }
}
