import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:yemektarifiyeni/pages/home.dart';
import 'package:yemektarifiyeni/pages/profile.dart';
import 'package:yemektarifiyeni/pages/saved.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late home homepage;
  late saved savepage;
  late Profile profile;

@override
void initState() {
  homepage = home();
  savepage = saved();
  profile = Profile(userName: "Ömer"); // Kullanıcı adını burada sağlayın
  pages = [homepage, savepage, profile];
  super.initState();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index){
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
        Icon(
          Icons.home_outlined,
         color: Colors.white,
         ),

         Icon(
          Icons.bookmark_border,
           color: Colors.white,
           ),

          Icon(Icons.person_outline,
          color: Colors.white,
          ), 
      ]),
      body: pages[currentTabIndex],
    );
  }
}

