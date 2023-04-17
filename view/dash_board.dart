import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_diet/utils/firebase_info.dart';
import 'package:group_diet/view/Record.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/firebase_member.dart';
import '../utils/firebase_user.dart';
import '../utils/google_auth.dart';
import '../utils/perOfGoal.dart';
import '../utils/statisticsIn7.dart';
import '../utils/todayStatus.dart';
import 'edit_user.dart';
import 'help.dart';
import 'info.dart';
import 'package:badges/badges.dart' as badges;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
  }) : super(key: key);

  static Drawer dashboardDrawer(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(mainProvider.myself['account_name']),
                const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 18,
                    ))
              ],
            ),
            accountEmail: Text(
              'Your ID: ${mainProvider.myself['id']}',
              style: const TextStyle(fontSize: 13),
            ),
            onDetailsPressed: () async {
              final box = context.findRenderObject() as RenderBox?;

              await Share.share('''アプリ：Group Diet
個人ID：${mainProvider.myself['id']}

初めての方は次のホームページにアクセスし、アプリをダウンロードください。
https://nice713.notion.site/Group-Diet-e1af9c539b184ea1bdfe24d05316a846''',
                  subject: "個人IDの共有",
                  sharePositionOrigin:
                      box!.localToGlobal(Offset.zero) & box.size);
            },
            currentAccountPicture: CircleAvatar(
              foregroundImage: NetworkImage(mainProvider.myself['icon_url']),
              backgroundColor: Colors.white,
              backgroundImage: Image.asset("lib/assets/appicon.png").image,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter:
                    const ColorFilter.mode(Colors.black38, BlendMode.darken),
                image: Image.network(
                  mainProvider.myself['iconBack_url'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ).image,
                fit: BoxFit.cover,
              ),
              color: AppParts.char_sub_Color,
            ),
            arrowColor: Colors.white.withOpacity(0),
          ),
          ListTile(
            title: const Text('アカウント設定'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUserPage(user: mainProvider.myself),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('ヘルプ'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('ホームページ'),
            onTap: () {
              final url = Uri.parse(
                  'https://nice713.notion.site/Group-Diet-e1af9c539b184ea1bdfe24d05316a846');
              launchUrl(url);
            },
          ),
          ListTile(
            title: const Text('お問い合わせ'),
            onTap: () {
              final url = Uri.parse(
                  'https://nice713.notion.site/c52255c8cbb3439cb0342af5ce2907d4');
              launchUrl(url);
            },
          ),
          ListTile(
            title: const Text('利用規約'),
            onTap: () {
              final url = Uri.parse(
                  'https://nice713.notion.site/2eb67663bb064533bd426ed989f20c9e');
              launchUrl(url);
            },
          ),
          ListTile(
            title: const Text('プライバシーポリシー'),
            onTap: () {
              final url = Uri.parse(
                  'https://nice713.notion.site/9c96dcbb34394c30991e3036408eae80');
              launchUrl(url);
            },
          ),
          ListTile(
            title: const Text('ログアウト'),
            onTap: () {
              Authentication.signOut(context: context).then((value) {
                navigateFNC(context);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DocumentSnapshot<Object?>? myself;
  late Map<String, String> req_from_o_id;
  late Map<String, String> req_from_m_id;
  late Map<String, String> member_id;
  late ScrollController _scrollController_member = ScrollController();

  @override
  void initState() {
    myself = null;
    req_from_o_id = {};
    req_from_m_id = {};
    member_id = {};
    _scrollController_member = ScrollController();
    super.initState();
  }

  SliverAppBar appBar_dash_board(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();

    return SliverAppBar(
      actions: <Widget>[
        InkWell(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: NumUnread(uid: mainProvider.myself['id'])),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InfoPage(
                    user: mainProvider.myself,
                  ),
                ),
              );
            }),
      ],
      iconTheme: const IconThemeData(color: AppParts.char_sub_Color),
      backgroundColor: AppParts.backColor,
      pinned: true,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          "Home",
          style: TextStyle(
            color: AppParts.charColor,
          ),
        ),
      ),
    );
  }

  StreamBuilder numUnread(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseInfo.getInfoNotReadSnapshot(uid: uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int _noReadcount = snapshot.data!.docs.length;

            String _res = "";
            (_noReadcount == 0) ? _res = "" : _res = _noReadcount.toString();
            return badges.Badge(
                showBadge: (_res.isEmpty) ? false : true,
                badgeContent: Text(_res),
                child: const Icon(
                  Icons.notifications,
                ));
          } else {
            return AppParts.loadingImage;
          }
        });
  }

  Future recordNavigation(bool isReplace, BuildContext context, Widget screen) {
    late Function navi;
    if (isReplace) {
      navi = Navigator.pushReplacement;
    } else {
      navi = Navigator.push;
    }

    return navi(
      context,
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            alignment: Alignment.center,
            scale: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(seconds: 1),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return screen;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();

    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd');
    String date = outputFormat.format(now);
    Map<String, String> we_id;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> _member;

    return Scaffold(
        drawer: SizedBox(
            width: MediaQuery.of(context).size.width / 4 * 3,
            child: DashboardScreen.dashboardDrawer(context)),
        floatingActionButton: SizedBox(
            width: 50,
            child: FloatingActionButton(
              onPressed: () {
                recordNavigation(
                    false,
                    context,
                    RecordPage(
                        context: context, myself: myself, mem_id: member_id));
              },
              backgroundColor: getMainColor(context),
              child: const Icon(Icons.edit),
            )),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (mainProvider.myself['lastseen'] != getIntToday()) {
                  FirebaseUser.updateUser(
                      docid: mainProvider.myself['id'],
                      data: {'lastseen': getIntToday()});

                  Map<String, dynamic> value = mainProvider.myself;
                  value['lastseen'] = getIntToday();
                  mainProvider.changeUser(value);
                }
              });
            },
            child: CustomScrollView(
              slivers: [
                appBar_dash_board(context),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Column(children: <Widget>[
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseUser.getUserSnapshot(
                              docid: mainProvider.myself['id']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              myself = snapshot.data!;

                              return StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseMember.getMemberSnapshot(
                                      uid: mainProvider.myself['id']),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      member_id = {};
                                      we_id = {
                                        mainProvider.myself['id']:
                                            mainProvider.myself['id']
                                      };
                                      _member = snapshot2.data!.docs;
                                      _member.forEach((element) {
                                        if (element['member'].contains(
                                            mainProvider.myself['id'])) {
                                          (element['member'][0] ==
                                                  mainProvider.myself['id'])
                                              ? member_id[element.id] =
                                                  element['member'][1]
                                              : member_id[element.id] =
                                                  element['member'][0];
                                        }
                                      });
                                      we_id.addAll(member_id);

                                      return Column(
                                        children: [
                                          //Today's Status
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  childrenPadding:
                                                      const EdgeInsets.all(10),
                                                  initiallyExpanded: true,
                                                  title: Text(
                                                    '本日(${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day})の記録状況',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            AppParts.charColor),
                                                  ),
                                                  children: [
                                                    TodayStatus(we_id: we_id)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          //Percentage
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  childrenPadding:
                                                      const EdgeInsets.all(10),
                                                  initiallyExpanded: true,
                                                  title: const Text(
                                                    '達成度(%)',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            AppParts.charColor),
                                                  ),
                                                  children: percentageGoal
                                                      .percentageList(we_id),
                                                ),
                                              ),
                                            ),
                                          ),
                                          //Excersice in Last 7 days
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  childrenPadding:
                                                      const EdgeInsets.all(10),
                                                  initiallyExpanded: true,
                                                  title: const Text(
                                                    "１週間の統計",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            AppParts.charColor),
                                                  ),
                                                  children: StatisticsIn7
                                                      .rankingEXCList(we_id),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          )
                                        ],
                                      );
                                    } else {
                                      return AppParts.loadingImage;
                                    }
                                  });
                            } else {
                              return AppParts.loadingImage;
                            }
                          })
                    ])
                  ]),
                ),
              ],
            )));
  }
}

class NumUnread extends StatelessWidget {
  final String _uid;
  const NumUnread({super.key, required String uid}) : _uid = uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseInfo.getInfoNotReadSnapshot(uid: _uid),
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
                  Icons.notifications,
                ));
          } else {
            return AppParts.loadingImage;
          }
        });
  }
}
