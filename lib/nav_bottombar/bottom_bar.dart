import 'package:flutter/material.dart';
import 'package:royalvista/nav_bottombar/profile.dart';
import 'package:royalvista/nav_bottombar/spotrate.dart';
import 'package:royalvista/nav_bottombar/ratealert.dart';
import 'package:royalvista/nav_bottombar/showpages/bottom_sheetpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'more.dart';



int _currentIndex = 0;

List<Widget> _pages = [
  Spotrate(),
  Ratealert(),
  Profile(),
 More(),
];


class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
  @override
  Widget build(BuildContext context) {
    return       Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Color(0xFF777777),
              primaryColor: Colors.red,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(labelMedium: new TextStyle(color: Colors.yellow))),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            showSelectedLabels: true,
            selectedItemColor: Colors.white,
            selectedIconTheme: IconThemeData(
              color: Colors.orangeAccent,
            ),
            unselectedItemColor: Colors.green,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard, color: Color(0xFFBFA13A)),
                label: 'Spot rate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_rounded,
                    color: Color(0xFFBFA13A)),
                label: 'Rate alert',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,
                    color: Color(0xFFBFA13A)),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Bottomsheet();
                        },
                      );
                    },
                    child: Icon(Icons.more, color: Color(0xFFBFA13A))),
                label: 'More',
              ),
            ],
          )),
    );

  }
}
