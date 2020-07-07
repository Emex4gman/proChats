import 'package:flutter/material.dart';
import 'package:prochats/pages/chats.dart';
import 'package:prochats/screens/chats.dart';
import 'package:prochats/screens/groups.dart';
import 'package:prochats/screens/home.dart';
import 'package:prochats/screens/notifications.dart';
import 'package:prochats/screens/profile.dart';
import 'package:prochats/util/state.dart';
import 'package:prochats/util/state_widget.dart';
import 'package:prochats/widgets/icon_badge.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  StateModel appState;  
  int _page = 2;

  @override
  Widget build(BuildContext context) {
            appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          // ChatsOld(),
          // Home(),
          GroupsSearch(uId: userId, uEmailId: email,),
          Chats(uId: userId, uEmailId: email,),
          // Notifications(),
          Profile(),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).primaryColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).accentColor,
          textTheme: Theme
              .of(context)
              .textTheme
              .copyWith(caption: TextStyle(color: Colors.grey[500]),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            //  BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.check,
            //   ),
            //   title: Container(height: 0.0),
            // ),
            
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.home,
            //   ),
            //   title: Container(height: 0.0),
            // ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              title: Container(height: 0.0),
            ),

           
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
              ),
              title: Container(height: 0.0),
            ),
            

            // BottomNavigationBarItem(
            //   icon: IconBadge(
            //     icon: Icons.notifications,
            //   ),
            //   title: Container(height: 0.0),
            // ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              title: Container(height: 0.0),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
