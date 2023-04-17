import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

import '../utils/common.dart';

class Chat_Page extends StatefulWidget {
  const Chat_Page(
      {Key? key,
      required String docid,
      required Map myself,
      required Map member})
      : _docid = docid,
        _myself = myself,
        _member = member,
        super(key: key);

  final String _docid;
  final Map _myself;
  final Map _member;

  @override
  _Chat_PageState createState() => _Chat_PageState();
}

class _Chat_PageState extends State<Chat_Page> {
  List<types.Message> _messages = [];
  String randomId = randomString();
  int countTdaymsg = 0;
  late final _user = types.User(
    id: widget._myself['id'],
  );

  void _addMessage(types.TextMessage message) async {
    await FirebaseFirestore.instance
        .collection('member')
        .doc(widget._docid)
        .collection('chat')
        .add({
      //'name': message.author.firstName,
      'createdAt': message.createdAt,
      'id': message.author.id,
      'text': message.text,
      'isRead': false,
      'partner': widget._member['id'],
    });
  }

  // メッセージ送信時の処理
  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomId,
      text: message.text,
    );

    bool no_emoji_flg = false;
    List<String> moji = [];

    //サロゲートペア対応
    moji = message.text.characters.toList().toSet().toList();
    List emoji_list = AppParts.emoji_list.toSet().toList();
    moji.forEach((element) {
      if (!emoji_list.contains(element) &&
          '☺️' != element &&
          '🫥' != element &&
          '☹' != element &&
          '☠' != element &&
          '✌' != element &&
          '✌️' != element &&
          '☝' != element &&
          '✍' != element &&
          '❣' != element) {
        no_emoji_flg = true;
      }
    });

    if (no_emoji_flg) {
      customSnackBar(content: "一部の絵文字のみ入力できます");
    } else if (countTdaymsg >= 10) {
      customSnackBar(content: "チャットは1日に10通まで送れます。");
    } else {
      _addMessage(textMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: getMainColor(context),
          title: Text(widget._member['account_name']),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.help,
                color: Colors.white,
              ),
              onPressed: () {
                _openHelpBox(context);
              },
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            // 投稿メッセージ一覧の取得
            stream: FirebaseFirestore.instance
                .collection('member')
                .doc(widget._docid)
                .collection('chat')
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                countTdaymsg = 0;
                final message = snapshot.data?.docs
                    .map((d) => types.TextMessage(
                          author: types.User(
                              id: d['id'],
                              imageUrl: (d['id'] != widget._myself['id'])
                                  ? widget._member['icon_url']
                                  : null),
                          createdAt: d['createdAt'],
                          id: d['id'],
                          text: d['text'],
                        ))
                    .toList();

                _messages = [...?message];
                snapshot.data!.docs.forEach((e) {
                  if (e['id'] == widget._myself['id']) {
                    if (DateTime.fromMillisecondsSinceEpoch(e['createdAt'])
                                .year ==
                            DateTime.now().year &&
                        DateTime.fromMillisecondsSinceEpoch(e['createdAt'])
                                .day ==
                            DateTime.now().day &&
                        DateTime.fromMillisecondsSinceEpoch(e['createdAt'])
                                .month ==
                            DateTime.now().month) {
                      countTdaymsg++;
                    }
                  }
                  if (e['id'] == widget._member['id'] && !e['isRead']) {
                    FirebaseFirestore.instance
                        .collection('member')
                        .doc(widget._docid)
                        .collection('chat')
                        .doc(e.id)
                        .update({
                      'isRead': true,
                    });
                  }
                });

                return Chat(
                    theme: DefaultChatTheme(
                      // メッセージ入力欄の色
                      inputBackgroundColor: getMainColor(context),
                      // 送信ボタン
                      sendButtonIcon: const Icon(Icons.send),
                      sendingIcon: const Icon(Icons.update_outlined),
                    ),
                    // ユーザーの名前を表示するかどうか
                    showUserNames: true,
                    showUserAvatars: true,
                    // メッセージの配列
                    messages: _messages,
                    //onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    user: _user,
                    dateFormat: DateFormat('yyyy/MM/dd'),
                    timeFormat: DateFormat('kk:mm'),
                    textMessageOptions: const TextMessageOptions());
              } else {
                return AppParts.loadingImage;
              }
            }));
  }

  _openHelpBox(BuildContext context) {
    ScrollController _scrollcontroller = ScrollController();
    String emojiList2String = AppParts.emoji_list
        .map<String>((String value) => value.toString())
        .join('');

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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          "ヘルプ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.help,
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
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("次の絵文字だけ送信できます。\n絵文字は選択・コピーできます。",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppParts.charColor, fontSize: 13))),
                    const Divider(
                      color: AppParts.char_sub_Color,
                      height: 4.0,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: MediaQuery.of(context).size.height / 3,
                      child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollcontroller,
                          child: SingleChildScrollView(
                              controller: _scrollcontroller,
                              child: SelectableText(emojiList2String))),
                    ),
                    const Divider(
                      color: AppParts.char_sub_Color,
                      height: 4.0,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                  ]),
            ),
          );
        });
  }
}
