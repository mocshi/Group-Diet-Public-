import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/common.dart';
import 'calendar.dart';
import 'dash_board.dart';
import 'member.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _controller;
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = 0;
    _controller = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _controller?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();

    //スマホヘッダーを表示
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    late final List<Widget> _widgetOptions = <Widget>[
      const DashboardScreen(),
      CalendarScreen(myself: mainProvider.myself),
      const MemberListPage(),
    ];
    return Scaffold(
      body: Stack(children: [
        PageView(controller: _controller, children: _widgetOptions),
        mainProvider.isLoadFlg
            ? AppParts.loadingImage
            : const SizedBox(height: 1),
      ]),
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          backgroundColor: getMainColor(context),
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_month,
              ),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: numUnread(mainProvider.myself['id']),
              label: 'Member',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.white,
          selectedItemColor: (mainProvider.myself['mainColor'] <= 4)
              ? Colors.blue
              : Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  StreamBuilder numUnread(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('chat')
            .where('partner', isEqualTo: uid)
            .where("isRead", isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int _noReadcount = snapshot.data!.docs.length;

            String _res = "";
            (_noReadcount == 0) ? _res = "" : _res = _noReadcount.toString();
            return badges.Badge(
                showBadge: (_res.isEmpty) ? false : true,
                badgeContent:
                    Text(_res, style: const TextStyle(color: Colors.white)),
                child: const Icon(
                  Icons.savings,
                ));
          } else {
            return AppParts.loadingImage;
          }
        });
  }
}
