import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'firebase_data.dart';

class customTextField extends StatefulWidget {
  const customTextField(
      {Key? key,
      required String title,
      required String uid,
      required int date,
      required String docid,
      required double data,
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
  final double _data;
  final List _fields;
  final bool _isYourself;

  @override
  _customTextFieldState createState() => _customTextFieldState();
}

class _customTextFieldState extends State<customTextField> {
  TextEditingController _txtController = TextEditingController();

  @override
  void initState() {
    (widget._data < 0)
        ? _txtController.text = ""
        : _txtController.text = widget._data.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = "";
    if (!widget._isYourself && widget._icon == Icons.monitor_weight_outlined) {
      subtitle = (widget._data < 0) ? "" : "完了！";
    } else {
      subtitle = (widget._data < 0) ? "" : widget._data.toString();
    }

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
      subtitle: Text(subtitle),
      onTap: () {
        if (widget._isYourself) {
          (widget._data < 0)
              ? _txtController.text = ""
              : _txtController.text = widget._data.toString();
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            onChanged: (value) {},
                            controller: _txtController,
                            decoration: const InputDecoration(
                                hintText: "値を入力ください", labelText: "値"),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"[0-9.]")),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                try {
                                  final text = newValue.text;
                                  if (text.isNotEmpty) double.parse(text);
                                  return newValue;
                                } catch (e) {}
                                return oldValue;
                              }),
                            ],
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
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
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
                          key = AppParts.option_list_jp.keys.firstWhere((key) =>
                              AppParts.option_list_jp[key] == widget._title);
                        }

                        if (widget._docid != "") {
                          (widget._fields.contains(key))
                              ? null
                              : widget._fields.add(key);

                          FirebaseData.updateData(
                                  data: FirebaseData.creatUpdateData(
                                      keyName: key,
                                      data: double.parse(_txtController.text),
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
                                      data: double.parse(_txtController.text)),
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
            ),
          );
        });
  }
}
