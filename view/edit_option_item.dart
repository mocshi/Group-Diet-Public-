import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import '../utils/firebare_storage.dart';
import '../utils/firebase_info.dart';
import '../utils/firebase_user.dart';
import 'intro2.dart';

class EditOptionPage extends StatefulWidget {
  const EditOptionPage({Key? key, required Map<String, dynamic> user})
      : _user = user,
        super(key: key);

  final Map<String, dynamic> _user;

  @override
  State<StatefulWidget> createState() {
    return _EditOptionPage();
  }
}

class _EditOptionPage extends State<EditOptionPage> {
  late Map<String, dynamic> _user;
  bool _isLoading = false;
  TextEditingController _selectItem_Controller = TextEditingController();
  TextEditingController _itemName = TextEditingController();

  late List _option_item_n;
  late List _option_item_v;
  late bool isChangeFlg;

  @override
  void initState() {
    isChangeFlg = true;
    _itemName = TextEditingController();
    _option_item_n = ["weight", "breakfast", "lunch", "dinner", "exercise"];
    _option_item_v = [
      "num",
      "search_food",
      "search_food",
      "search_food",
      "search_exercise",
    ];
    _user = widget._user;
    super.initState();
  }

  void _add_option_item(n, v) {
    setState(() {
      _option_item_n.add(n);
      _option_item_v.add(v);
    });
  }

  void _rm_option_item(i) {
    setState(() {
      _option_item_n.removeAt(i);
      _option_item_v.removeAt(i);
    });
  }

  void _change_selected(i) {
    setState(() {
      _selectItem_Controller.text = i;
    });
  }

  void _resetController() {
    setState(() {
      _itemName = TextEditingController();
      _selectItem_Controller = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget._user['id'] != null && isChangeFlg) {
      _option_item_n = stringToList(widget._user['option_item_n']);
      _option_item_v = stringToList(widget._user['option_item_v']);
      isChangeFlg = false;
    }

    List<Widget> _lists = [];
    if (_option_item_n.length > 0) {
      _option_item_n.asMap().forEach((index, element) {
        _lists.add(SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Card(child: _cardWidget(index))));
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                _user['option_item_n'] = _option_item_n.join(",");
                _user['option_item_v'] = _option_item_v.join(",");

                String img =
                    await uploadFile(_user['icon_url'], _user['user_mail']);
                String imgBack = await uploadFile(
                    _user['iconBack_url'], _user['user_mail'] + ".back");
                _user['icon_url'] = img;
                _user['iconBack_url'] = imgBack;

                if (widget._user['id'] != null) {
                  String docid = _user['id'];
                  _user.remove('id');
                  bool value =
                      await FirebaseUser.updateUser(docid: docid, data: _user);
                  if (value) {
                    setState(() {
                      _isLoading = false;
                    });
                    navigateFNC(context);
                  } else {
                    customSnackBar(
                      content: 'Error: add user',
                    );
                  }
                } else {
                  DocumentReference<Map<String, dynamic>>? value =
                      await FirebaseUser.addUser(_user);
                  await FirebaseInfo.addData(
                    uid: value!.id,
                    value: FirebaseInfo.createData(
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        doc:
                            "アカウントが作成されました！これからダイエット頑張りましょう！操作方法は「Home画面の左上のアイコン」>「ヘルプ」で確認できるよ！まずはメンバーを追加しよう！"),
                  );
                  if (value != null) {
                    setState(() {
                      _isLoading = false;
                    });
                    customNavigation(true, context, IntroScreen2());
                  } else {
                    customSnackBar(
                      content: 'Error: add user',
                    );
                  }
                }
              },
              icon: const Icon(Icons.done_outline))
        ],
        automaticallyImplyLeading: true,
        backgroundColor: getMainColor(context),
        title: const Text('日々の記録', style: TextStyle(fontSize: 15)),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
            child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Image.asset(
                                  'lib/assets/help/edit_option_item1.png',
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                ),
                              ),
                            ]),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          '''体重や食事の他に管理したいものがあれば項目を用意しましょう。追加した項目には「数値」または「○,X」のいずれかの値で記録ができます。

例）走行距離(km)、筋トレ有無
''',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 15,
                  children: _lists,
                ),
              ),
              const SizedBox(height: 40)
            ]),
            _isLoading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: AppParts.loadingImage)
                : const SizedBox(height: 100),
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: getMainColor(context),
        child: const Icon(Icons.add),
        onPressed: () {
          _resetController();
          _openAlertBox(context);
        },
      ),
    );
  }

  Widget _cardWidget(int index) {
    String title;
    (AppParts.option_list_jp.containsKey(_option_item_n[index]))
        ? title = AppParts.option_list_jp[_option_item_n[index]]!
        : title = _option_item_n[index];
    String subtitle = AppParts.listValues['${_option_item_v[index]}']!;

    return ListTile(
      dense: true,
      minLeadingWidth: 5,
      horizontalTitleGap: 5,
      contentPadding: const EdgeInsets.all(10),
      title: Text(title, style: TextStyle(fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 15)),
      leading: (!AppParts.option_list_jp.containsKey(_option_item_n[index]))
          ? IconButton(
              icon: const Icon(
                Icons.delete,
                size: 20,
              ),
              color: AppParts.charColor,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('項目の削除'),
                          content: const Text("この項目を削除しますか？"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  _rm_option_item(index);
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'))
                          ],
                        ));
              },
            )
          : const SizedBox(),
    );
  }

  _openAlertBox(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: SingleChildScrollView(
                  child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          "項目の追加",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.content_paste,
                              color: getMainColor(context),
                              size: 20.0,
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
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: _itemName,
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(fontSize: 15),
                                      labelText: "項目名",
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null) {
                                        return '項目名を入力ください。';
                                      }
                                      if (value.isEmpty) {
                                        return '項目名を入力ください。';
                                      }

                                      if (value.indexOf(' ') >= 0 &&
                                          value.trim() == '') {
                                        return '空文字は受け付けていません。';
                                      }

                                      if (value.indexOf('　') >= 0 &&
                                          value.trim() == '') {
                                        return '空文字は受け付けていません。';
                                      }
                                      if (value.length > 10) {
                                        return '10文字以下にしてください。';
                                      }

                                      if (value.contains(RegExp(
                                          r'\.|\^|\$|\||\\|\[|\]|\{|\}|\+|\*|\?'))) {
                                        return '次の文字は入力できません。: .^\$|\\[]{}+*?';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "値タイプ",
                                            style: TextStyle(
                                                color: AppParts.char_sub_Color,
                                                fontSize: 15),
                                          ),
                                          Column(
                                            children: [
                                              RadioListTile(
                                                  title: Text(
                                                      AppParts
                                                          .listValues.entries
                                                          .elementAt(0)
                                                          .value,
                                                      style: const TextStyle(
                                                          fontSize: 15.0)),
                                                  value: AppParts
                                                      .listValues.entries
                                                      .elementAt(0)
                                                      .key,
                                                  groupValue:
                                                      _selectItem_Controller
                                                          .text,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _change_selected(value);
                                                    });
                                                  }),
                                              RadioListTile(
                                                  title: Text(
                                                      AppParts
                                                          .listValues.entries
                                                          .elementAt(1)
                                                          .value,
                                                      style: const TextStyle(
                                                          fontSize: 15.0)),
                                                  value: AppParts
                                                      .listValues.entries
                                                      .elementAt(1)
                                                      .key,
                                                  groupValue:
                                                      _selectItem_Controller
                                                          .text,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _change_selected(value);
                                                    });
                                                  }),
                                              SizedBox(
                                                  height: 15,
                                                  child: SingleChildScrollView(
                                                    reverse: true,
                                                    child: TextFormField(
                                                      controller:
                                                          _selectItem_Controller,
                                                      readOnly: true,
                                                      style: const TextStyle(
                                                        color:
                                                            AppParts.backColor,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppParts
                                                                .char_sub_Color,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppParts
                                                                .char_sub_Color,
                                                          ),
                                                        ),
                                                      ),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return '値タイプを選択ください。';
                                                        }
                                                        if (value.isEmpty) {
                                                          return '値タイプを選択ください。';
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ])),
                              ])),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: getMainColor(context),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32.0),
                              bottomRight: Radius.circular(32.0)),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _add_option_item(
                              _itemName.text, _selectItem_Controller.text);
                          _resetController();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              )));
        }).then((value) => setState(() {}));
  }
}
