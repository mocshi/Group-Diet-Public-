import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_diet/utils/firebase_data.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'common.dart';

class customSearchField extends StatefulWidget {
  const customSearchField({
    Key? key,
    required String title,
    required String uid,
    required IconData icon,
    required int date,
    required String docid,
    required List<Map> data,
    required List fields,
    required String mode,
    required double weight,
    required bool isYourself,
  })  : _title = title,
        _uid = uid,
        _date = date,
        _icon = icon,
        _docid = docid,
        _data = data,
        _fields = fields,
        _mode = mode,
        _weight = weight,
        _isYourself = isYourself,
        super(key: key);

  final String _title;
  final String _uid;
  final IconData _icon;
  final int _date;
  final String _docid;
  final List<Map> _data;
  final List _fields;
  final String _mode;
  final double _weight;
  final bool _isYourself;

  @override
  _customSearchFieldState createState() => _customSearchFieldState();
}

class _customSearchFieldState extends State<customSearchField> {
  ScrollController _scrollcontroller_search = ScrollController();
  ScrollController _scrollcontroller_select = ScrollController();

  late List<Map> items_search;
  late List<Map> items_select;
  late List<Widget> selectList;
  late bool isSelectManual;

  @override
  void initState() {
    isSelectManual = false;
    items_search = [];
    selectList = [];
    items_select = widget._data.toList();
    super.initState();
  }

  void updateItemSearch(List<Map> value) {
    setState(() {
      items_search = value;
    });
  }

  void updateItemSelect(List<Map> value) {
    setState(() {
      items_select = value.toList();
    });
  }

  void updateIsSelectManual(bool value) {
    setState(() {
      isSelectManual = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> subtitleList =
        createSelectList(widget._data.toList(), false, setState);

    String ttl_cal = getTotalCal(widget._data.toList()).toString();

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(5),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: getMainColor(context),
          child: Icon(
            widget._icon,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
      onTap: () {
        if (widget._isYourself) {
          updateItemSearch([]);
          updateItemSelect(widget._data);
          _openAlertBox(context);
        }
      },
      title: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Text(
                "${widget._title} (${ttl_cal}kcal)",
                style: const TextStyle(fontSize: 15),
              ),
              const Expanded(child: SizedBox()),
              (widget._isYourself)
                  ? const Icon(
                      Icons.edit,
                      size: 20,
                    )
                  : const SizedBox()
            ],
          )),
      subtitle: Wrap(spacing: 5.0, runSpacing: 5.0, children: subtitleList),
    );
  }

  _openAlertBox(BuildContext context) {
    MainProvider mainProvider = context.read<MainProvider>();
    TextEditingController _searchController = TextEditingController();
    TextEditingController _textController_manual_title =
        TextEditingController();
    TextEditingController _textController_manual_cal = TextEditingController();
    TextEditingController _textController_manual_P = TextEditingController();
    TextEditingController _textController_manual_F = TextEditingController();
    TextEditingController _textController_manual_C = TextEditingController();
    TextEditingController _textController_manual_gramme =
        TextEditingController();
    bool initFlg = true;

    isSelectManual = false;
    _textController_manual_P.text = "0";
    _textController_manual_F.text = "0";
    _textController_manual_C.text = "0";
    _textController_manual_cal.text = "100";

    List<dynamic> foodsrc = [];
    final _formKey = GlobalKey<FormState>();
    final focusNode = FocusNode();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: const EdgeInsets.only(
                top: 10.0,
              ),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState_Alert) {
                return FutureBuilder(
                    future: csvImport('lib/assets/${widget._mode}.csv'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        foodsrc = snapshot.data!.toList();

                        selectList = createSelectList(
                            items_select, true, setState_Alert);

                        if (widget._mode == "METs" && initFlg) {
                          List<Map<dynamic, dynamic>> edata = [];
                          snapshot.data!.forEach((element) {
                            edata.add({
                              'title': element[0],
                              'subtitle': "METs: ${element[2]}",
                              'METs': element[2],
                              'manual': ""
                            });
                          });

                          items_search = edata.toList();
                          initFlg = false;
                        }

                        return Focus(
                            focusNode: focusNode,
                            child: GestureDetector(
                                onTap: focusNode.requestFocus,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                widget._title,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(
                                                    widget._icon,
                                                    color:
                                                        getMainColor(context),
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
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            10 *
                                                            9,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              20 *
                                                              13,
                                                          child: TextField(
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                            controller:
                                                                _searchController,
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              hintStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              hintText:
                                                                  'Search Text',
                                                              prefixIcon:
                                                                  const Icon(Icons
                                                                      .search),
                                                              suffixIcon:
                                                                  (_searchController
                                                                              .text !=
                                                                          "")
                                                                      ? IconButton(
                                                                          icon:
                                                                              const Icon(Icons.clear),
                                                                          onPressed:
                                                                              () {
                                                                            setState_Alert(() {
                                                                              updateItemSearch([]);
                                                                              _searchController.text = "";
                                                                            });
                                                                          },
                                                                        )
                                                                      : null,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                borderSide:
                                                                    const BorderSide(
                                                                  color: AppParts
                                                                      .char_sub_Color,
                                                                ),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                borderSide:
                                                                    const BorderSide(
                                                                  color: AppParts
                                                                      .char_sub_Color,
                                                                ),
                                                              ),
                                                              isDense: true,
                                                            ),
                                                            onTap: () {
                                                              setState_Alert(
                                                                  () {
                                                                updateIsSelectManual(
                                                                    false);
                                                              });
                                                            },
                                                            onSubmitted:
                                                                (v) async {
                                                              List<Map> items =
                                                                  [];
                                                              bool isHit = true;

                                                              if (widget
                                                                      ._mode ==
                                                                  "food") {
                                                                QuerySnapshot
                                                                    manualFood =
                                                                    await FirebaseData
                                                                        .getAllFood(
                                                                            uid:
                                                                                widget._uid);

                                                                manualFood.docs
                                                                    .forEach(
                                                                        (element) {
                                                                  foodsrc.add([
                                                                    element[
                                                                        'title'],
                                                                    "",
                                                                    element[
                                                                        'cal'],
                                                                    element[
                                                                        'P'],
                                                                    element[
                                                                        'F'],
                                                                    element[
                                                                        'C'],
                                                                    element[
                                                                        'gramme'],
                                                                    element.id,
                                                                  ]);
                                                                });
                                                              }

                                                              String _text = v
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\\'),
                                                                      '\\\\)')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\.'),
                                                                      '\\.')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\^'),
                                                                      '\\^')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\$'),
                                                                      '\\\$')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\|'),
                                                                      '\\|')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\['),
                                                                      '\\[')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\]'),
                                                                      '\\]')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\('),
                                                                      '\\(')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\)'),
                                                                      '\\)')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\{'),
                                                                      '\\{')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\}'),
                                                                      '\\}')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\+'),
                                                                      '\\+')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\*'),
                                                                      '\\*')
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\?'),
                                                                      '\\?');

                                                              foodsrc.forEach(
                                                                  (element) {
                                                                if (RegExp(r'.*' +
                                                                            _text +
                                                                            '.*')
                                                                        .hasMatch(element[
                                                                            0]) ||
                                                                    RegExp(r'.*' +
                                                                            _text +
                                                                            '.*')
                                                                        .hasMatch(
                                                                            element[1])) {
                                                                  isHit = false;
                                                                  if (widget
                                                                          ._mode ==
                                                                      "food") {
                                                                    Map d = {
                                                                      'title':
                                                                          element[
                                                                              0],
                                                                      'subtitle':
                                                                          "100gあたり: ${element[2]}kcal,\n P: ${element[3]}, F: ${element[4]}, C: ${element[5]}",
                                                                      'cal':
                                                                          element[
                                                                              2],
                                                                      'P': element[
                                                                          3],
                                                                      'F': element[
                                                                          4],
                                                                      'C': element[
                                                                          5],
                                                                      'gramme':
                                                                          element[
                                                                              6]
                                                                    };
                                                                    (element.length ==
                                                                            8)
                                                                        ? d['manual'] =
                                                                            element[
                                                                                7]
                                                                        : d['manual'] =
                                                                            "";
                                                                    items
                                                                        .add(d);
                                                                  } else {
                                                                    items.add({
                                                                      'title':
                                                                          element[
                                                                              0],
                                                                      'subtitle':
                                                                          "METs: ${element[2]}",
                                                                      'METs':
                                                                          element[
                                                                              2],
                                                                      'manual':
                                                                          ""
                                                                    });
                                                                  }
                                                                }
                                                              });

                                                              if (isHit) {
                                                                customSnackBar(
                                                                    content:
                                                                        "見つかりませんでした...");
                                                              }

                                                              setState_Alert(
                                                                  () {
                                                                updateItemSearch(
                                                                    items);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              20 *
                                                              1,
                                                          child: (widget
                                                                      ._mode ==
                                                                  "food")
                                                              ? MaterialButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState_Alert(
                                                                        () {
                                                                      updateItemSearch(
                                                                          []);
                                                                      _searchController
                                                                          .text = "";

                                                                      updateIsSelectManual(
                                                                          true);

                                                                      _textController_manual_title
                                                                          .text = "";
                                                                      _textController_manual_gramme
                                                                              .text =
                                                                          "100";
                                                                      _textController_manual_cal
                                                                          .text = "";
                                                                      _textController_manual_P
                                                                              .text =
                                                                          "0";
                                                                      _textController_manual_F
                                                                              .text =
                                                                          "0";
                                                                      _textController_manual_C
                                                                              .text =
                                                                          "0";
                                                                    });
                                                                  },
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(5),
                                                                  shape:
                                                                      const CircleBorder(),
                                                                  child: const Icon(
                                                                      Icons
                                                                          .edit,
                                                                      size: 18),
                                                                )
                                                              : const SizedBox(),
                                                        )
                                                      ],
                                                    )),
                                                const Divider(
                                                  color:
                                                      AppParts.char_sub_Color,
                                                  height: 4.0,
                                                ),
                                                (isSelectManual)
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10,
                                                                left: 10),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child: Text(
                                                                    "手動登録",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  )),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                                child: InkWell(
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(5),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: getMainColor(
                                                                          context),
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              5.0)),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                      "ADD",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              14),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    if (_formKey
                                                                        .currentState!
                                                                        .validate()) {
                                                                      if (widget
                                                                              ._mode ==
                                                                          "food") {
                                                                        Map<String,
                                                                                dynamic>
                                                                            newfood =
                                                                            {
                                                                          'title':
                                                                              "(手動) ${_textController_manual_title.text}",
                                                                          'cal':
                                                                              _textController_manual_cal.text,
                                                                          'P': _textController_manual_P
                                                                              .text,
                                                                          'F': _textController_manual_F
                                                                              .text,
                                                                          'C': _textController_manual_C
                                                                              .text,
                                                                          'gramme':
                                                                              _textController_manual_gramme.text
                                                                        };

                                                                        QuerySnapshot
                                                                            food =
                                                                            await FirebaseData.getFood(
                                                                                uid: widget._uid,
                                                                                foodname: _textController_manual_title.text);

                                                                        QuerySnapshot
                                                                            manualFood =
                                                                            await FirebaseData.getAllFood(uid: widget._uid);

                                                                        if (food.docs.length >
                                                                            0) {
                                                                          customSnackBar(
                                                                              content: "既に登録されています。");
                                                                        } else if (manualFood.docs.length >=
                                                                            20) {
                                                                          customSnackBar(
                                                                              content: "20件以上登録することはできません。");
                                                                        } else {
                                                                          FirebaseData.addFood(uid: widget._uid, value: newfood).then((value) =>
                                                                              customSnackBar(content: "フードをライブラリに登録しました。"));

                                                                          items_select
                                                                              .add(newfood);
                                                                        }
                                                                      }

                                                                      setState_Alert(
                                                                          () {
                                                                        updateItemSelect(
                                                                            items_select);
                                                                      });
                                                                    } else {
                                                                      customSnackBar(
                                                                          content:
                                                                              "追加に失敗しました。値を確認ください。");
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ]),
                                                      )
                                                    : const SizedBox(),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  height: (isSelectManual)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          2.3
                                                      : MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              2.3 +
                                                          40,
                                                  child: Scrollbar(
                                                    thumbVisibility: true,
                                                    controller:
                                                        _scrollcontroller_search,
                                                    child: (isSelectManual)
                                                        ? SingleChildScrollView(
                                                            controller:
                                                                _scrollcontroller_search,
                                                            child: Form(
                                                                key: _formKey,
                                                                child: Column(
                                                                    children: [
                                                                      Wrap(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_title,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "フード名",
                                                                                ),
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return 'フード名を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return 'フード名を入力ください。';
                                                                                  }

                                                                                  if (value.indexOf(' ') >= 0 && value.trim() == '') {
                                                                                    return '空文字は受け付けていません。';
                                                                                  }

                                                                                  if (value.indexOf('　') >= 0 && value.trim() == '') {
                                                                                    return '空文字は受け付けていません。';
                                                                                  }
                                                                                  if (value.length > 15) {
                                                                                    return '15文字以下にしてください。';
                                                                                  }
                                                                                  if (value.contains(RegExp(r'\.|\^|\$|\||\\|\[|\]|\(|\)|\{|\}|\+|\*|\?'))) {
                                                                                    return '次の文字は入力できません。: .^\$|\\[](){}+*?';
                                                                                  }
                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_gramme,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "食事量[g]",
                                                                                ),
                                                                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                                    try {
                                                                                      final text = newValue.text;
                                                                                      if (text.isNotEmpty) double.parse(text);
                                                                                      return newValue;
                                                                                    } catch (e) {}
                                                                                    return oldValue;
                                                                                  }),
                                                                                ],
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return '食事量[g]を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return '食事量[g]を入力ください。';
                                                                                  }

                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                      const Padding(
                                                                          padding: EdgeInsets.all(
                                                                              5),
                                                                          child:
                                                                              Text(
                                                                            "100g辺りの栄養価",
                                                                            style:
                                                                                TextStyle(fontSize: 14),
                                                                          )),
                                                                      Wrap(
                                                                          children: [
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width / 3,
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_cal,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "カロリー[kcal]",
                                                                                ),
                                                                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                                    try {
                                                                                      final text = newValue.text;
                                                                                      if (text.isNotEmpty) double.parse(text);
                                                                                      return newValue;
                                                                                    } catch (e) {}
                                                                                    return oldValue;
                                                                                  }),
                                                                                ],
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return 'カロリー[kcal]を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return 'カロリー[kcal]を入力ください。';
                                                                                  }

                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width / 3,
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_P,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "タンパク質[g]",
                                                                                ),
                                                                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                                    try {
                                                                                      final text = newValue.text;
                                                                                      if (text.isNotEmpty) double.parse(text);
                                                                                      return newValue;
                                                                                    } catch (e) {}
                                                                                    return oldValue;
                                                                                  }),
                                                                                ],
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }

                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width / 3,
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_F,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "脂質[g]",
                                                                                ),
                                                                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                                    try {
                                                                                      final text = newValue.text;
                                                                                      if (text.isNotEmpty) double.parse(text);
                                                                                      return newValue;
                                                                                    } catch (e) {}
                                                                                    return oldValue;
                                                                                  }),
                                                                                ],
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }

                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width / 3,
                                                                              padding: const EdgeInsets.all(10),
                                                                              child: TextFormField(
                                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                controller: _textController_manual_C,
                                                                                decoration: const InputDecoration(
                                                                                  labelText: "炭水化物[g]",
                                                                                ),
                                                                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                                    try {
                                                                                      final text = newValue.text;
                                                                                      if (text.isNotEmpty) double.parse(text);
                                                                                      return newValue;
                                                                                    } catch (e) {}
                                                                                    return oldValue;
                                                                                  }),
                                                                                ],
                                                                                validator: (value) {
                                                                                  if (value == null) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }
                                                                                  if (value.isEmpty) {
                                                                                    return '含有量[g]を入力ください。';
                                                                                  }

                                                                                  return null;
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ])
                                                                    ])),
                                                          )
                                                        : ListView.builder(
                                                            itemCount:
                                                                items_search
                                                                    .length,
                                                            controller:
                                                                _scrollcontroller_search,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              Map item =
                                                                  items_search[
                                                                      index];
                                                              TextEditingController
                                                                  _calController =
                                                                  TextEditingController();
                                                              if (widget
                                                                      ._mode ==
                                                                  "food") {
                                                                if (item['gramme'] !=
                                                                        "0" &&
                                                                    _calController
                                                                            .text ==
                                                                        "") {
                                                                  _calController
                                                                      .text = item[
                                                                          'gramme']
                                                                      .toString();
                                                                }
                                                              }

                                                              return ExpansionTile(
                                                                title: ListTile(
                                                                  title: Text(
                                                                      item[
                                                                          'title'],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13)),
                                                                  subtitle:
                                                                      Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          item[
                                                                              'subtitle'],
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: AppParts.char_sub_Color)),
                                                                    ],
                                                                  ),
                                                                  trailing: (item[
                                                                              'manual']
                                                                          .isNotEmpty)
                                                                      ? IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("登録フードの削除"),
                                                                                  content: Text("以下フードを削除してよろしいですか。\n${item['title']}"),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      child: const Text("Cancel"),
                                                                                      onPressed: () => Navigator.pop(context),
                                                                                    ),
                                                                                    TextButton(
                                                                                      child: const Text("OK"),
                                                                                      onPressed: () async {
                                                                                        bool res = await FirebaseData.deleteFood(docid: item['manual'], uid: widget._uid);
                                                                                        if (res) {
                                                                                          setState_Alert(() => items_search.removeAt(index));
                                                                                        } else {
                                                                                          customSnackBar(content: "フードの削除に失敗しました。");
                                                                                        }

                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.delete,
                                                                            size:
                                                                                20,
                                                                          ))
                                                                      : null,
                                                                ),
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            60,
                                                                        width: MediaQuery.of(context).size.width /
                                                                            10 *
                                                                            5,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _calController,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            labelStyle:
                                                                                const TextStyle(
                                                                              fontSize: 12,
                                                                              color: AppParts.char_sub_Color,
                                                                            ),
                                                                            labelText: (widget._mode == "food")
                                                                                ? '食事量[g]'
                                                                                : "運動時間[h]",
                                                                            suffixIcon:
                                                                                IconButton(
                                                                              onPressed: () {
                                                                                if (_calController.text.isNotEmpty) {
                                                                                  if (widget._mode == "food") {
                                                                                    items_select.insert(0, {
                                                                                      'title': item['title'],
                                                                                      'cal': item['cal'],
                                                                                      'P': item['P'],
                                                                                      'F': item['F'],
                                                                                      'C': item['C'],
                                                                                      'gramme': _calController.text
                                                                                    });
                                                                                  } else {
                                                                                    items_select.insert(0, {
                                                                                      'title': item['title'],
                                                                                      'METs': item['METs'],
                                                                                      'time_h': _calController.text
                                                                                    });
                                                                                  }

                                                                                  setState_Alert(() {
                                                                                    updateItemSelect(items_select);
                                                                                  });
                                                                                }
                                                                              },
                                                                              icon: const Icon(
                                                                                Icons.save,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          keyboardType: const TextInputType.numberWithOptions(
                                                                              decimal: true,
                                                                              signed: false),
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                                                            TextInputFormatter.withFunction((oldValue,
                                                                                newValue) {
                                                                              try {
                                                                                final text = newValue.text;
                                                                                if (text.isNotEmpty) {
                                                                                  double.parse(text);
                                                                                }
                                                                                return newValue;
                                                                              } catch (e) {}
                                                                              return oldValue;
                                                                            }),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                ),
                                                const Divider(
                                                  color:
                                                      AppParts.char_sub_Color,
                                                  height: 4.0,
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  "長押しで選択を解除できます。",
                                                  style: TextStyle(
                                                      color: AppParts
                                                          .char_sub_Color,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            8,
                                                    child: Scrollbar(
                                                        thumbVisibility: true,
                                                        controller:
                                                            _scrollcontroller_select,
                                                        child:
                                                            SingleChildScrollView(
                                                          controller:
                                                              _scrollcontroller_select,
                                                          child: Wrap(
                                                            spacing: 5.0,
                                                            runSpacing: 5.0,
                                                            children:
                                                                selectList,
                                                          ),
                                                        ))),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            child: Container(
                                              height: 45,
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              decoration: BoxDecoration(
                                                color: getMainColor(context),
                                                borderRadius: const BorderRadius
                                                        .only(
                                                    bottomLeft:
                                                        Radius.circular(32.0),
                                                    bottomRight:
                                                        Radius.circular(32.0)),
                                              ),
                                              child: const Text(
                                                "Save",
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            onTap: () async {
                                              if (items_select.length > 0) {
                                                String key = widget._title;
                                                if (AppParts.option_list_jp
                                                    .containsValue(
                                                        widget._title)) {
                                                  key = AppParts
                                                      .option_list_jp.keys
                                                      .firstWhere((key) =>
                                                          AppParts.option_list_jp[
                                                              key] ==
                                                          widget._title);
                                                }

                                                if (widget._docid != "") {
                                                  (widget._fields.contains(key))
                                                      ? null
                                                      : widget._fields.add(key);

                                                  FirebaseData.updateData(
                                                          data: FirebaseData
                                                              .creatUpdateData(
                                                                  keyName: key,
                                                                  data:
                                                                      items_select,
                                                                  fields: widget
                                                                      ._fields),
                                                          uid: widget._uid,
                                                          dataid: widget._docid)
                                                      .then((value) {
                                                    customSnackBar(
                                                        content: "記録しました！");
                                                  });
                                                } else {
                                                  FirebaseData.addData(
                                                          value: FirebaseData
                                                              .createData(
                                                                  date: widget
                                                                      ._date,
                                                                  keyName: key,
                                                                  data:
                                                                      items_select),
                                                          uid: widget._uid)
                                                      .then((value) {
                                                    customSnackBar(
                                                        content: "記録しました！");
                                                  });
                                                }

                                                Navigator.pop(context);
                                              } else {
                                                customSnackBar(
                                                    content:
                                                        "登録するアイテムを選択ください。");
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ))));
                      } else {
                        return SizedBox(child: AppParts.loadingImage);
                      }
                    });
              }));
        });
  }

  int getTotalCal(List<Map> items) {
    double res = 0;
    items.asMap().forEach((int i, Map element) {
      if (widget._mode == "food") {
        res = res +
            double.parse(element['cal']) *
                double.parse(element['gramme']) /
                100;
      } else {
        res = res +
            getCalorieBurnfromMETs(
              h: double.parse(element['time_h']),
              m: double.parse(element['METs']),
              w: widget._weight.toDouble(),
            );
      }
    });
    return res.toInt();
  }

  List<Widget> createSelectList(
      List<Map> items, bool tapFlg, Function _setstate) {
    List<Widget> response = [];
    items.asMap().forEach((int i, Map element) {
      String listText = "";
      if (widget._mode == "food") {
        listText =
            "${element['title']}: ${element['gramme']}g: ${(double.parse(element['cal']) * double.parse(element['gramme']) / 100).toInt()}kcal";
      } else {
        (widget._weight > 0)
            ? listText =
                "${element['title']}: ${element['time_h']}h: ${getCalorieBurnfromMETs(
                h: double.parse(element['time_h']),
                m: double.parse(element['METs']),
                w: widget._weight.toDouble(),
              ).toInt()}kcal"
            : listText =
                "${element['title']}: ${element['time_h']}h:\n [!]体重を入力すると消費カロリーが算出されます";
      }
      Widget _container = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: getMainColor(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(listText, style: const TextStyle(fontSize: 13)),
        ),
      );
      if (tapFlg) {
        response.add(InkWell(
          onLongPress: () {
            items_select.removeAt(i);
            _setstate(() {
              updateItemSelect(items_select);
            });
          },
          child: _container,
        ));
      } else {
        response.add(_container);
      }
    });

    return response;
  }
}
