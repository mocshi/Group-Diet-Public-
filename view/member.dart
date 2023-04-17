import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import 'package:group_diet/utils/firebase_info.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/firebase_member.dart';
import '../utils/firebase_user.dart';
import 'chat_page.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({Key? key}) : super(key: key);

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberListPage> {
  late Map<String, String> req_from_o_id;
  late Map<String, String> req_from_m_id;
  late Map<String, String> member_id;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _member;

  @override
  void initState() {
    req_from_o_id = {};
    req_from_m_id = {};
    member_id = {};
    _member = [];
    super.initState();
  }

  SliverAppBar appBar_Member(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      backgroundColor: AppParts.backColor,
      title: Text('Member',
          style: TextStyle(
            color: AppParts.charColor,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = context.watch<MainProvider>();
    final _fromO_scrollController = ScrollController();
    final _fromM_scrollController = ScrollController();

    return Scaffold(
        floatingActionButton: SizedBox(
            width: 50,
            child: FloatingActionButton(
              onPressed: () {
                _openAlertBox(context);
              },
              backgroundColor: getMainColor(context),
              child: const Icon(Icons.person_add),
            )),
        body: SafeArea(
            child: CustomScrollView(
          slivers: [
            appBar_Member(context),
            SliverList(
              delegate: SliverChildListDelegate([
                Column(children: <Widget>[
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseMember.getMemberSnapshot(
                        uid: mainProvider.myself['id']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        req_from_o_id = {};
                        req_from_m_id = {};
                        member_id = {};
                        _member = snapshot.data!.docs;
                        _member.forEach((element) {
                          (element['req_from'] == mainProvider.myself['id'])
                              ? req_from_m_id[element.id] = element['req_to']
                              : null;
                          (element['req_to'] == mainProvider.myself['id'])
                              ? req_from_o_id[element.id] = element['req_from']
                              : null;
                          if (element['member']
                              .contains(mainProvider.myself['id'])) {
                            (element['member'][0] == mainProvider.myself['id'])
                                ? member_id[element.id] = element['member'][1]
                                : member_id[element.id] = element['member'][0];
                          }
                        });

                        List<Container> req_from_o =
                            _memIcon(req_from_o_id, true);
                        List<Container> req_from_m =
                            _memIcon(req_from_m_id, false);

                        return Column(
                          children: [
                            (req_from_o.length != 0)
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            '次のユーザーからリクエストが届いています',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                color: AppParts.char_sub_Color),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: Scrollbar(
                                              thumbVisibility: true,
                                              controller:
                                                  _fromO_scrollController,
                                              child: SingleChildScrollView(
                                                  controller:
                                                      _fromO_scrollController,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: req_from_o),
                                                    ],
                                                  )))),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : const SizedBox(height: 1),
                            (req_from_m.length != 0)
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            '次のユーザーにリクエストを出しています',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                color: AppParts.char_sub_Color),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: Scrollbar(
                                              thumbVisibility: true,
                                              controller:
                                                  _fromM_scrollController,
                                              child: SingleChildScrollView(
                                                  controller:
                                                      _fromM_scrollController,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: req_from_m,
                                                      ),
                                                    ],
                                                  )))),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : const SizedBox(height: 1),
                            Column(
                              children: _memList(member_id),
                            )
                          ],
                        );
                      }
                      return AppParts.loadingImage;
                    },
                  )
                ])
              ]),
            ),
          ],
        )));
  }

  List<Widget> _memList(Map mem_id) {
    List<Widget> m_list = [];
    MainProvider mainProvider = context.read<MainProvider>();

    mem_id.forEach((key, value) {
      m_list.add(FutureBuilder(
          future: FirebaseUser.getUser(docid: value),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Card(
                    child: ListTile(
                      onLongPress: () {
                        _openMember(context, snapshot, key);
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Chat_Page(
                                    member: {
                                      'id': snapshot.data!.id,
                                      'account_name':
                                          snapshot.data!['account_name'],
                                      'icon_url': snapshot.data!['icon_url'],
                                    },
                                    docid: key,
                                    myself: {'id': mainProvider.myself['id']},
                                  )),
                        );
                      },
                      title: Text(snapshot.data!['account_name']),
                      leading: CircleAvatar(
                        foregroundImage: Image.network(
                          snapshot.data!['icon_url'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ).image,
                        backgroundImage:
                            Image.asset("lib/assets/appicon.png").image,
                        backgroundColor: AppParts.backColor,
                        radius: 25,
                      ),
                      trailing: SizedBox(
                          width: 20,
                          height: 20,
                          child: numUnread(key, snapshot.data!.id)),
                    ),
                  ));
            } else {
              return AppParts.loadingImage;
            }
          }));
    });

    return m_list;
  }

  StreamBuilder numUnread(String docid, String mem_id) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('member')
            .doc(docid)
            .collection('chat')
            .where("isRead", isEqualTo: false)
            .where("id", isEqualTo: mem_id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Widget _res;
            (snapshot.data!.docs.length == 0)
                ? _res = const SizedBox(width: 1)
                : _res = CircleAvatar(
                    backgroundColor: getMainColor(context),
                    radius: 10,
                    child: Text(snapshot.data!.docs.length.toString(),
                        style: const TextStyle(
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  );

            return _res;
          } else {
            return AppParts.loadingImage;
          }
        });
  }

  List<Container> _memIcon(Map items, bool flg) {
    List<Container> response = [];
    items.forEach((key, item) {
      response.add(Container(
          alignment: Alignment.center,
          child: FutureBuilder(
              future: FirebaseUser.getUser(docid: item),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return IconButton(
                    icon: CircleAvatar(
                      foregroundImage: Image.network(
                        snapshot.data!['icon_url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ).image,
                      backgroundImage:
                          Image.asset("lib/assets/appicon.png").image,
                      backgroundColor: AppParts.backColor,
                      radius: 60,
                    ),
                    iconSize: 60,
                    onPressed: () {
                      _openRequest(context, snapshot, key, item, flg);
                    },
                  );
                } else {
                  return AppParts.loadingImage;
                }
              })));
    });

    return response;
  }

  _openRequest(
      BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
      String docid,
      String memid,
      bool flg) {
    MainProvider mainProvider = context.read<MainProvider>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: SingleChildScrollView(
                  child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          foregroundImage: Image.network(
                            snapshot.data!['icon_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ).image,
                          backgroundImage:
                              Image.asset("lib/assets/appicon.png").image,
                          backgroundColor: AppParts.backColor,
                          radius: 60,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(snapshot.data!['account_name']),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: const BoxDecoration(
                          //color: AppParts.mainColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                              bottomRight: Radius.circular(32.0)),
                        ),
                        child: (flg)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FloatingActionButton.extended(
                                    backgroundColor: Colors.red,
                                    //tooltip: 'Action!',
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Deny'),
                                    onPressed: () async {
                                      await FirebaseMember.deleteMember(
                                          docid: docid);

                                      await FirebaseInfo.addData(
                                        uid: memid,
                                        value: FirebaseInfo.createData(
                                            timestamp: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            doc:
                                                "${mainProvider.myself['account_name']}さんがリクエストを拒否しました。"),
                                      );
                                      await customSnackBar(
                                          content: "リクエストを拒否しました。");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  FloatingActionButton.extended(
                                    backgroundColor: Colors.green,
                                    //tooltip: 'Action!',
                                    icon: const Icon(Icons.check),
                                    label: const Text('Accept'),
                                    onPressed: () async {
                                      MainProvider mainProvider =
                                          context.read<MainProvider>();
                                      await FirebaseMember.updateMember(
                                          docid: docid,
                                          data: FirebaseMember.createUpdateData(
                                              member: [
                                                mainProvider.myself['id'],
                                                memid
                                              ]));

                                      await FirebaseInfo.addData(
                                          uid: memid,
                                          value: FirebaseInfo.createData(
                                              timestamp: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              doc:
                                                  "${mainProvider.myself['account_name']}さんとメンバーになりました！"));
                                      await customSnackBar(
                                          content: "リクエストを承認しました。");
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FloatingActionButton.extended(
                                    backgroundColor: getMainColor(context),
                                    //tooltip: 'Action!',
                                    icon: const Icon(Icons.clear),
                                    label: const Text('閉じる'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              )));
        }).then((value) => setState(() {}));
  }

  _openMember(
      BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
      String docid) {
    MainProvider mainProvider = context.read<MainProvider>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: SingleChildScrollView(
                  child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          foregroundImage: Image.network(
                            snapshot.data!['icon_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ).image,
                          backgroundImage:
                              Image.asset("lib/assets/appicon.png").image,
                          backgroundColor: AppParts.backColor,
                          radius: 60,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(snapshot.data!['account_name']),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: const BoxDecoration(
                          //color: AppParts.mainColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                              bottomRight: Radius.circular(32.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton.extended(
                              backgroundColor: Colors.red,
                              //tooltip: 'Action!',
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              onPressed: () async {
                                mainProvider.changeIsLoadFlg(true);
                                await FirebaseMember.deleteMember(docid: docid);
                                mainProvider.changeIsLoadFlg(false);
                                await customSnackBar(content: "メンバーから削除しました");
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )));
        }).then((value) => setState(() {}));
  }

  _openAlertBox(BuildContext context) {
    MainProvider mainProvider = context.read<MainProvider>();
    TextEditingController _memberIDController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        "ユーザー追加",
                        style: TextStyle(fontSize: 15),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.people,
                            color: getMainColor(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: TextFormField(
                        controller: _memberIDController,
                        decoration: const InputDecoration(
                            hintText: "メンバーのIDを入力ください",
                            labelText: "追加メンバーの個人ID"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null) {
                            return '値を入力ください。';
                          }
                          if (value.isEmpty) {
                            return '値を入力ください。';
                          }
                          if (value.indexOf(' ') >= 0 && value.trim() == '') {
                            return '空文字は受け付けていません。';
                          }

                          if (value.indexOf('　') >= 0 && value.trim() == '') {
                            return '空文字は受け付けていません。';
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  InkWell(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      decoration: BoxDecoration(
                        color: getMainColor(context),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: const Text(
                        "リクエスト",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        mainProvider.changeIsLoadFlg(true);

                        if (req_from_o_id
                            .containsValue(_memberIDController.text)) {
                          await customSnackBar(
                              content: 'Error: 該当メンバから既にリクエストが来ています');
                        } else if (member_id
                            .containsValue(_memberIDController.text)) {
                          await customSnackBar(content: 'Error: 既にメンバーです');
                        } else if (stringToList(mainProvider.myself['id'])
                            .contains(_memberIDController.text)) {
                          await customSnackBar(
                              content: 'Error: 自身にはリクエストできません');
                        } else if (req_from_m_id
                            .containsValue(_memberIDController.text)) {
                          await customSnackBar(content: 'Error: 既にリクエストしてます');
                        } else {
                          var req_user = await FirebaseUser.getUser(
                              docid: _memberIDController.text);
                          if (req_user.data() != null) {
                            await FirebaseMember.addMember(
                                value: FirebaseMember.createData(
                                    related: [
                                  mainProvider.myself['id'],
                                  _memberIDController.text
                                ],
                                    from: mainProvider.myself['id'],
                                    to: _memberIDController.text));

                            await FirebaseInfo.addData(
                              uid: _memberIDController.text,
                              value: FirebaseInfo.createData(
                                  timestamp:
                                      DateTime.now().millisecondsSinceEpoch,
                                  doc:
                                      "新しいリクエストが来ています。（${mainProvider.myself['account_name']}さん）"),
                            );

                            await customSnackBar(content: 'メンバーに追加リクエストしました！');
                            Navigator.pop(context);
                          } else {
                            await customSnackBar(
                                content: 'Error: メンバーが見つかりません');
                          }
                        }
                        mainProvider.changeIsLoadFlg(false);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
