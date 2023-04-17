import 'package:flutter/material.dart';
import 'common.dart';
import 'firebase_data.dart';

class CustomListField extends StatefulWidget {
  const CustomListField(
      {Key? key,
      required String title,
      required String uid,
      required int date,
      required String docid,
      required String data,
      required List fields,
      required bool isYourself,
      required IconData icon})
      : _title = title,
        _uid = uid,
        _date = date,
        _icon = icon,
        _docid = docid,
        _data = data,
        _fields = fields,
        _isYourself = isYourself,
        super(key: key);

  final String _title;
  final String _uid;
  final int _date;
  final IconData _icon;
  final String _docid;
  final String _data;
  final List _fields;
  final bool _isYourself;

  @override
  _customListFieldState createState() => _customListFieldState();
}

class _customListFieldState extends State<CustomListField> {
  late TextEditingController _selectItem_Controller = TextEditingController();

  @override
  void initState() {
    (widget._data.isEmpty)
        ? _selectItem_Controller = TextEditingController()
        : _selectItem_Controller.text = widget._data.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _selectItem_Controller.text = widget._data;
    Widget? subtitle = (AppParts.listValuesYN.containsKey(widget._data))
        ? AppParts.listValuesYN[widget._data]
        : const SizedBox(width: 1);
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
      title: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Text(
                widget._title,
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
      subtitle: Align(alignment: Alignment.centerLeft, child: subtitle),
      onTap: () {
        if (widget._isYourself) {
          (widget._data.isEmpty)
              ? _selectItem_Controller = TextEditingController()
              : _selectItem_Controller.text = widget._data.toString();
          _openAlertBox(context);
        }
      },
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
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget._title,
                            style: const TextStyle(fontSize: 15),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                widget._icon,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  RadioListTile(
                                    title: AppParts.listValuesYN.entries
                                        .elementAt(0)
                                        .value,
                                    value: AppParts.listValuesYN.entries
                                        .elementAt(0)
                                        .key,
                                    groupValue: _selectItem_Controller.text,
                                    onChanged: (value) => setState(() {
                                      _selectItem_Controller.text = value!;
                                    }),
                                  ),
                                  RadioListTile(
                                    title: AppParts.listValuesYN.entries
                                        .elementAt(1)
                                        .value,
                                    value: AppParts.listValuesYN.entries
                                        .elementAt(1)
                                        .key,
                                    groupValue: _selectItem_Controller.text,
                                    onChanged: (value) => setState(() {
                                      _selectItem_Controller.text = value!;
                                    }),
                                  ),
                                  SizedBox(
                                      height: 15,
                                      child: SingleChildScrollView(
                                        reverse: true,
                                        child: TextFormField(
                                          controller: _selectItem_Controller,
                                          readOnly: true,
                                          style: const TextStyle(
                                            color: AppParts.backColor,
                                          ),
                                          decoration: const InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppParts.char_sub_Color,
                                              ),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppParts.char_sub_Color,
                                              ),
                                            ),
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null) {
                                              return '値を選択ください。';
                                            }
                                            if (value.isEmpty) {
                                              return '値を選択ください。';
                                            }

                                            return null;
                                          },
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                      InkWell(
                        child: Container(
                          height: 45,
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            String key = widget._title;
                            if (AppParts.option_list_jp
                                .containsValue(widget._title)) {
                              key = AppParts.option_list_jp.keys.firstWhere(
                                  (key) =>
                                      AppParts.option_list_jp[key] ==
                                      widget._title);
                            }

                            if (widget._docid != "") {
                              (widget._fields.contains(key))
                                  ? null
                                  : widget._fields.add(key);

                              FirebaseData.updateData(
                                      data: FirebaseData.creatUpdateData(
                                          keyName: key,
                                          data: _selectItem_Controller.text,
                                          fields: widget._fields),
                                      uid: widget._uid,
                                      dataid: widget._docid)
                                  .then((value) {
                                customSnackBar(content: "記録しました！");
                              });
                            } else {
                              FirebaseData.addData(
                                      value: FirebaseData.createData(
                                          date: widget._date,
                                          keyName: key,
                                          data: _selectItem_Controller.text),
                                      uid: widget._uid)
                                  .then((value) {
                                customSnackBar(content: "記録しました！");
                              });
                            }

                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }));
        });
  }
}
