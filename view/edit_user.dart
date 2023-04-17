import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_diet/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/firebare_storage.dart';
import 'edit_diet.dart';
import 'package:badges/badges.dart' as badges;

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key, required Map user})
      : _user = user,
        super(key: key);

  final Map _user;

  @override
  State<StatefulWidget> createState() {
    return _EditUserPage();
  }
}

class _EditUserPage extends State<EditUserPage> {
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _weight_now_Controller = TextEditingController();
  TextEditingController _weight_goal_Controller = TextEditingController();
  TextEditingController _height_Controller = TextEditingController();
  TextEditingController _birth_Controller = TextEditingController();
  TextEditingController _selectItem_Sex_Controller = TextEditingController();
  TextEditingController _selectItem_PAL_Controller = TextEditingController();
  TextEditingController _selectItem_Stress_Controller = TextEditingController();

  late bool _isChangeFlg;
  late String _imgUrl;
  late String _imgBackUrl;
  var _toggleBackgroundImage = false;
  var _toggleBackgroundImage2 = false;
  late int _selectedColor;

  @override
  void initState() {
    _selectedColor = AppParts.mainColor;
    _isChangeFlg = true;
    _imgUrl = AppParts.iconList['pink']!;
    _imgBackUrl = AppParts.iconList['pink']!;
    super.initState();
  }

  void _change_selectedColor(value) {
    setState(() {
      _selectedColor = value;
    });
  }

  void _change_imgUrl(value) {
    setState(() {
      _imgUrl = value;
    });
  }

  void _change_imgBackUrl(value) {
    setState(() {
      _imgBackUrl = value;
    });
  }

  void _change_tbgI(value) {
    setState(() {
      _toggleBackgroundImage = value;
    });
  }

  void _change_tbgI2(value) {
    setState(() {
      _toggleBackgroundImage2 = value;
    });
  }

  void _changeSexSelected(i) {
    setState(() {
      _selectItem_Sex_Controller.text = i;
    });
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final _fromO_scrollController = ScrollController();
    MainProvider mainProvider = context.read<MainProvider>();

    if (widget._user.containsKey('id') && _isChangeFlg) {
      DateTime birth = int2Date(widget._user['birth']);
      _imgUrl = widget._user['icon_url'];
      _imgBackUrl = widget._user['iconBack_url'];
      _accountNameController.text = widget._user['account_name'];
      _weight_now_Controller.text = widget._user['weight_init'].toString();
      _weight_goal_Controller.text = widget._user['weight_goal'].toString();
      _height_Controller.text = widget._user['height'].toString();
      _birth_Controller.text = DateFormat('yyyy/MM/dd').format(birth);
      _selectItem_Sex_Controller.text = widget._user['sex'];
      _selectItem_PAL_Controller.text = widget._user['pal'];
      _selectItem_Stress_Controller.text = widget._user['stress'];
      _selectedColor = widget._user['mainColor'];
      _isChangeFlg = false;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: getMainColor(context),
          title: const Text('アカウント設定', style: TextStyle(fontSize: 15)),
          actions: [
            IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    int birth =
                        int.parse(_birth_Controller.text.replaceAll("/", ""));

                    Map<String, dynamic> _user_edit = {
                      'id': (widget._user.containsKey('id'))
                          ? widget._user['id']
                          : null,
                      'user_mail': widget._user['user_mail'],
                      'icon_url': _imgUrl,
                      'mainColor': _selectedColor,
                      'iconBack_url': _imgBackUrl,
                      'account_name': _accountNameController.text,
                      'weight_init': double.parse(_weight_now_Controller.text),
                      'weight_goal': double.parse(_weight_goal_Controller.text),
                      'height': double.parse(_height_Controller.text),
                      'birth': birth,
                      'sex': _selectItem_Sex_Controller.text,
                      'pal': _selectItem_PAL_Controller.text,
                      'stress': _selectItem_Stress_Controller.text,
                      'option_item_n':
                          (widget._user.containsKey('option_item_n'))
                              ? widget._user['option_item_n']
                              : null,
                      'option_item_v':
                          (widget._user.containsKey('option_item_v'))
                              ? widget._user['option_item_v']
                              : null,
                    };
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditDietPage(
                          user: _user_edit,
                        ),
                      ),
                    );
                  }
                },
                icon: const Text("次へ"))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("アイコン",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppParts.char_sub_Color,
                                    )),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                        child: badges.Badge(
                                      onTap: () {
                                        _openRequest_BackImg();
                                      },
                                      badgeStyle: const badges.BadgeStyle(
                                        badgeColor: Colors.white,
                                      ),
                                      badgeContent: const Icon(
                                        Icons.edit,
                                        size: 15,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10 *
                                              2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10 *
                                              9,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                      Colors.black38,
                                                      BlendMode.darken),
                                              image: _toggleBackgroundImage2
                                                  ? Image.file(
                                                          File(_imgBackUrl))
                                                      .image
                                                  : Image.network(
                                                      _imgBackUrl,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ).image,
                                              fit: BoxFit.cover,
                                            ),
                                            color: AppParts.char_sub_Color,
                                          ),
                                        ),
                                      ),
                                    )),
                                    Center(
                                      child: badges.Badge(
                                        onTap: () {
                                          _openRequest();
                                        },
                                        badgeStyle: const badges.BadgeStyle(
                                          badgeColor: Colors.white,
                                        ),
                                        badgeContent: const Icon(
                                          Icons.edit,
                                          size: 15,
                                        ),
                                        child: CircleAvatar(
                                          foregroundImage:
                                              _toggleBackgroundImage
                                                  ? Image.file(File(_imgUrl))
                                                      .image
                                                  : Image.network(_imgUrl)
                                                      .image,
                                          backgroundImage: Image.asset(
                                            "lib/assets/appicon.png",
                                          ).image,
                                          backgroundColor: AppParts.backColor,
                                          radius: 40,
                                          onBackgroundImageError: (_, __) {
                                            _change_tbgI(false);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Text("メインカラー",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppParts.char_sub_Color,
                                      )),
                                  const SizedBox(width: 30),
                                  Icon(Icons.circle,
                                      color: AppParts.colorList.values
                                          .toList()[_selectedColor])
                                ]),
                                SizedBox(
                                  height: 60.0,
                                  child: ListView.builder(
                                      itemCount: AppParts.colorList.length,
                                      controller: _fromO_scrollController,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          color: AppParts.colorList.values
                                              .toList()[index],
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: TextButton(
                                                onPressed: () {
                                                  _change_selectedColor(index);
                                                },
                                                child: const SizedBox()),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: _accountNameController,
                              decoration: const InputDecoration(
                                labelText: "アカウント名",
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null) {
                                  return 'アカウント名を入力ください。';
                                }
                                if (value.isEmpty) {
                                  return 'アカウント名を入力ください。';
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
                                    r'\.|\^|\$|\||\\|\[|\]|\(|\)|\{|\}|\+|\*|\?'))) {
                                  return '次の文字は入力できません。: .^\$|\\[](){}+*?';
                                }
                                return null;
                              },
                            ),
                          ),
                          Center(
                            child: Wrap(spacing: 5, children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: _weight_now_Controller,
                                    decoration: const InputDecoration(
                                      labelText: "初期の体重(kg)",
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[0-9.]")),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        try {
                                          final text = newValue.text;
                                          if (text.isNotEmpty)
                                            double.parse(text);
                                          return newValue;
                                        } catch (e) {}
                                        return oldValue;
                                      }),
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null) {
                                        return '体重(kg)を入力ください。';
                                      }
                                      if (value.isEmpty) {
                                        return '体重(kg)を入力ください。';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: _weight_goal_Controller,
                                    decoration: const InputDecoration(
                                      labelText: "目標の体重(kg)",
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[0-9.]")),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        try {
                                          final text = newValue.text;
                                          if (text.isNotEmpty)
                                            double.parse(text);
                                          return newValue;
                                        } catch (e) {}
                                        return oldValue;
                                      }),
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null) {
                                        return '体重(kg)を入力ください。';
                                      }
                                      if (value.isEmpty) {
                                        return '体重(kg)を入力ください。';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: _height_Controller,
                                    decoration: const InputDecoration(
                                      labelText: "身長(cm)",
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true, signed: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[0-9.]")),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        try {
                                          final text = newValue.text;
                                          if (text.isNotEmpty)
                                            double.parse(text);
                                          return newValue;
                                        } catch (e) {}
                                        return oldValue;
                                      }),
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null) {
                                        return '身長(cm)を入力ください。';
                                      }
                                      if (value.isEmpty) {
                                        return '身長(cm)を入力ください。';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: _birth_Controller,
                                    decoration:
                                        const InputDecoration(labelText: "誕生日"),
                                    readOnly: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null) {
                                        return '値を入力ください。';
                                      }
                                      if (value.isEmpty) {
                                        return '値を入力ください。';
                                      }
                                      if (value.indexOf(' ') >= 0 &&
                                          value.trim() == '') {
                                        return '空文字は受け付けていません。';
                                      }

                                      if (value.indexOf('　') >= 0 &&
                                          value.trim() == '') {
                                        return '空文字は受け付けていません。';
                                      }

                                      return null;
                                    },
                                    onTap: () async {
                                      DateTime initdate;
                                      DateTime fdate;
                                      DateTime ldate;

                                      fdate = DateTime(1900, 1, 1);
                                      ldate = DateTime.now();
                                      (_birth_Controller.text == "")
                                          ? initdate = DateTime.now()
                                          : initdate = transString2Date(
                                              _birth_Controller.text);

                                      showCustomDatePicker(
                                          context, initdate, fdate, ldate,
                                          (pickedDate) {
                                        String formattedDate =
                                            DateFormat('yyyy/MM/dd')
                                                .format(pickedDate);
                                        setState(() {
                                          _birth_Controller.text =
                                              formattedDate;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "性別",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Column(
                                    children: [
                                      RadioListTile(
                                          title: Text(AppParts.listSex.entries
                                              .elementAt(0)
                                              .value),
                                          value: AppParts.listSex.entries
                                              .elementAt(0)
                                              .key,
                                          groupValue:
                                              _selectItem_Sex_Controller.text,
                                          onChanged: (value) =>
                                              _changeSexSelected(value)),
                                      RadioListTile(
                                          title: Text(AppParts.listSex.entries
                                              .elementAt(1)
                                              .value),
                                          value: AppParts.listSex.entries
                                              .elementAt(1)
                                              .key,
                                          groupValue:
                                              _selectItem_Sex_Controller.text,
                                          onChanged: (value) =>
                                              _changeSexSelected(value)),
                                      SizedBox(
                                          height: 15,
                                          child: SingleChildScrollView(
                                            reverse: true,
                                            child: TextFormField(
                                              controller:
                                                  _selectItem_Sex_Controller,
                                              readOnly: true,
                                              style: const TextStyle(
                                                color: AppParts.backColor,
                                              ),
                                              decoration: const InputDecoration(
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        AppParts.char_sub_Color,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        AppParts.char_sub_Color,
                                                  ),
                                                ),
                                              ),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              validator: (value) {
                                                if (value == null) {
                                                  return '性別を選択ください。';
                                                }
                                                if (value.isEmpty) {
                                                  return '性別を選択ください。';
                                                }

                                                return null;
                                              },
                                            ),
                                          )),
                                    ],
                                  ),
                                ]),
                          ),
                          const SizedBox(height: 40),
                        ],
                      )),
                ),
              ),
            )));
  }

  _openRequest() {
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
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['blue']!).image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgUrl(AppParts.iconList['blue']!);
                            _change_tbgI(false);
                          },
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['pink']!).image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgUrl(AppParts.iconList['pink']!);
                            _change_tbgI(false);
                          },
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['yellow']!)
                                    .image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgUrl(AppParts.iconList['yellow']!);
                            _change_tbgI(false);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getMainColor(context),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              select_icon(context).then((value) {
                                if (value != null) {
                                  _change_imgUrl(value);
                                  _change_tbgI(true);
                                } else {
                                  _change_tbgI(false);
                                }
                              });
                            },
                            child: const Icon(
                              Icons.camera_alt,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
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
                  ],
                ),
              )));
        }).then((value) => setState(() {}));
  }

  _openRequest_BackImg() {
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
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['blue']!).image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgBackUrl(AppParts.iconList['blue']!);
                            _change_tbgI2(false);
                          },
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['pink']!).image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgBackUrl(AppParts.iconList['pink']!);
                            _change_tbgI2(false);
                          },
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: CircleAvatar(
                            foregroundImage:
                                Image.network(AppParts.iconList['yellow']!)
                                    .image,
                            backgroundImage:
                                Image.asset("lib/assets/appicon.png").image,
                            backgroundColor: AppParts.backColor,
                            radius: 30,
                          ),
                          onPressed: () {
                            _change_imgBackUrl(AppParts.iconList['yellow']!);
                            _change_tbgI2(false);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getMainColor(context),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              select_icon(context).then((value) {
                                if (value != null) {
                                  _change_imgBackUrl(value);
                                  _change_tbgI2(true);
                                } else {
                                  _change_tbgI2(false);
                                }
                              });
                            },
                            child: const Icon(
                              Icons.camera_alt,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
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
                  ],
                ),
              )));
        }).then((value) => setState(() {}));
  }
}
