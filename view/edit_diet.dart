import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import 'edit_option_item.dart';

class EditDietPage extends StatefulWidget {
  const EditDietPage({Key? key, required Map<String, dynamic> user})
      : _user = user,
        super(key: key);

  final Map<String, dynamic> _user;

  @override
  State<StatefulWidget> createState() {
    return _EditDietPage();
  }
}

class _EditDietPage extends State<EditDietPage> {
  TextEditingController _selectItem_PAL_Controller = TextEditingController();
  TextEditingController _selectItem_Stress_Controller = TextEditingController();

  late bool _isChangeFlg;

  @override
  void initState() {
    _isChangeFlg = true;

    super.initState();
  }

  void _changePalSelected(i) {
    setState(() {
      _selectItem_PAL_Controller.text = i;
    });
  }

  void _changeStressSelected(i) {
    setState(() {
      _selectItem_Stress_Controller.text = i;
    });
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if (widget._user.containsKey('id') && _isChangeFlg) {
      _selectItem_PAL_Controller.text = widget._user['pal'];
      _selectItem_Stress_Controller.text = widget._user['stress'];
      _isChangeFlg = false;
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> _user_edit = widget._user;

                    _user_edit['pal'] = _selectItem_PAL_Controller.text;
                    _user_edit['stress'] = _selectItem_Stress_Controller.text;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditOptionPage(
                          user: _user_edit,
                        ),
                      ),
                    );
                  }
                },
                icon: const Text("次へ"))
          ],
          backgroundColor: getMainColor(context),
          title: const Text(
            '活動レベル・頑張り度合い',
            style: TextStyle(fontSize: 15),
          ),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'lib/assets/help/edit_diet1.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '''普段の生活の中で消費されるカロリーを計算するため、活動レベルを選択しましょう。
続いて、月にどれくらい痩せたいか選択することで1日に制限すべきカロリーがグラフに表示されます。自身に合う頑張り度合いを選択しましょう。''',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ])),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "活動レベル",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Column(
                                  children: [
                                    RadioListTile(
                                        title: Text(
                                            AppParts.palList.entries
                                                .elementAt(0)
                                                .value,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: AppParts.palList.entries
                                            .elementAt(0)
                                            .key,
                                        groupValue:
                                            _selectItem_PAL_Controller.text,
                                        onChanged: (value) =>
                                            _changePalSelected(value)),
                                    RadioListTile(
                                        title: Text(
                                            AppParts.palList.entries
                                                .elementAt(1)
                                                .value,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: AppParts.palList.entries
                                            .elementAt(1)
                                            .key,
                                        groupValue:
                                            _selectItem_PAL_Controller.text,
                                        onChanged: (value) =>
                                            _changePalSelected(value)),
                                    RadioListTile(
                                        title: Text(
                                            AppParts.palList.entries
                                                .elementAt(2)
                                                .value,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: AppParts.palList.entries
                                            .elementAt(2)
                                            .key,
                                        groupValue:
                                            _selectItem_PAL_Controller.text,
                                        onChanged: (value) =>
                                            _changePalSelected(value)),
                                    SizedBox(
                                        height: 15,
                                        child: SingleChildScrollView(
                                          reverse: true,
                                          child: TextFormField(
                                            controller:
                                                _selectItem_PAL_Controller,
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
                                                return '活動レベルを選択ください。';
                                              }
                                              if (value.isEmpty) {
                                                return '活動レベルを選択ください。';
                                              }

                                              return null;
                                            },
                                          ),
                                        )),
                                  ],
                                ),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "頑張り度合い",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Column(
                                  children: [
                                    RadioListTile(
                                        title: Text(
                                            AppParts.stressList.entries
                                                .elementAt(0)
                                                .value,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: AppParts.stressList.entries
                                            .elementAt(0)
                                            .key,
                                        groupValue:
                                            _selectItem_Stress_Controller.text,
                                        onChanged: (value) =>
                                            _changeStressSelected(value)),
                                    RadioListTile(
                                        title: Text(
                                            AppParts.stressList.entries
                                                .elementAt(1)
                                                .value,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: AppParts.stressList.entries
                                            .elementAt(1)
                                            .key,
                                        groupValue:
                                            _selectItem_Stress_Controller.text,
                                        onChanged: (value) =>
                                            _changeStressSelected(value)),
                                    SizedBox(
                                        height: 15,
                                        child: SingleChildScrollView(
                                          reverse: true,
                                          child: TextFormField(
                                            controller:
                                                _selectItem_Stress_Controller,
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
                                                return '頑張り度合いを選択ください。';
                                              }
                                              if (value.isEmpty) {
                                                return '頑張り度合いを選択ください。';
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
              ))
        ]))));
  }
}
