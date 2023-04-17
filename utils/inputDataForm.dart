import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common.dart';
import 'customListField.dart';
import 'customSearchField.dart';
import 'customTextField.dart';
import 'firebase_data.dart';
import 'firebase_user.dart';
import '../utils/totalCal.dart';

class InputDataForm extends StatelessWidget {
  const InputDataForm({
    Key? key,
    required BuildContext context,
    required DocumentSnapshot<Object?>? myself,
    required Map mem_id,
    required int day,
  })  : _context = context,
        _myself = myself,
        _mem_id = mem_id,
        _day = day,
        super(key: key);

  final BuildContext _context;
  final DocumentSnapshot<Object?>? _myself;
  final Map _mem_id;
  final int _day;

  @override
  Widget build(BuildContext context) {
    String _title;

    List<Widget> today_lists = [];

    //YourSelf
    List fieldName = stringToList(_myself!['option_item_n']);
    List fieldType = stringToList(_myself!['option_item_v']);
    today_lists.add(createCard(
        uid: _myself!.id,
        accountName: _myself!['account_name'],
        iconUrl: _myself!['icon_url'],
        fieldName: fieldName,
        fieldType: fieldType));

    //Member
    _mem_id.forEach(
      (key, element) {
        today_lists.add(FutureBuilder(
            future: FirebaseUser.getUser(docid: element),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                List fieldName = stringToList(snapshot.data!['option_item_n']);
                List fieldType = stringToList(snapshot.data!['option_item_v']);
                return createCard(
                    uid: snapshot.data!.id,
                    accountName: snapshot.data!['account_name'],
                    iconUrl: snapshot.data!['icon_url'],
                    fieldName: fieldName,
                    fieldType: fieldType);
              } else {
                return AppParts.loadingImage;
              }
            }));
      },
    );

    return Column(children: today_lists);
  }

  Widget createCard(
      {required String uid,
      required String accountName,
      required String iconUrl,
      required List fieldName,
      required List fieldType}) {
    Widget response = StreamBuilder<QuerySnapshot>(
        stream: FirebaseData.getDataSnapshot(uid: uid, day: _day),
        builder: (context, snapshot) {
          List<Widget> lists = [];
          List fields = [];
          String docid = "";
          if (snapshot.hasData) {
            if (snapshot.data!.docs.length > 0) {
              fields = snapshot.data!.docs[0]['fields'];
              docid = snapshot.data!.docs[0].id;
            }

            bool isYourself = false;
            (_myself!['account_name'] == accountName)
                ? isYourself = true
                : false;

            fieldType.asMap().forEach((key, element) {
              if (element == "num") {
                IconData icon = Icons.event_note_outlined;

                if (fieldName[key] == "weight") {
                  icon = Icons.monitor_weight_outlined;
                }

                String title = fieldName[key];
                if (AppParts.option_list_jp.containsKey(fieldName[key])) {
                  title = AppParts.option_list_jp[fieldName[key]]!;
                }

                double data = -1;
                if (fields.contains(fieldName[key])) {
                  data = snapshot.data!.docs[0][fieldName[key]] + 0.0;
                }

                lists.add(customTextField(
                  uid: uid,
                  icon: icon,
                  title: title,
                  date: _day,
                  docid: docid,
                  data: data,
                  fields: fields,
                  isYourself: isYourself,
                ));
              } else if (element == "search_food") {
                String title = fieldName[key];
                if (AppParts.option_list_jp.containsKey(fieldName[key])) {
                  title = AppParts.option_list_jp[fieldName[key]]!;
                }

                List<Map> data = [];
                if (fields.contains(fieldName[key])) {
                  data = snapshot.data!.docs[0][fieldName[key]].cast<Map>()
                      as List<Map>;
                }

                lists.add(customSearchField(
                  uid: uid,
                  docid: docid,
                  icon: Icons.restaurant,
                  title: title,
                  date: _day,
                  data: data,
                  fields: fields,
                  mode: "food",
                  weight: -1,
                  isYourself: isYourself,
                ));
              } else if (element == "search_exercise") {
                double weight = -1;
                if (fields.contains("weight")) {
                  weight = snapshot.data!.docs[0]["weight"] + 0.0;
                }

                String title = fieldName[key];
                if (AppParts.option_list_jp.containsKey(fieldName[key])) {
                  title = AppParts.option_list_jp[fieldName[key]]!;
                }

                List<Map> data = [];
                if (fields.contains(fieldName[key])) {
                  data = snapshot.data!.docs[0][fieldName[key]].cast<Map>()
                      as List<Map>;
                }

                lists.add(customSearchField(
                  uid: uid,
                  docid: docid,
                  icon: Icons.sports_martial_arts,
                  title: title,
                  date: _day,
                  data: data,
                  fields: fields,
                  mode: "METs",
                  weight: weight,
                  isYourself: isYourself,
                ));
              } else if (element == "yn") {
                String title = fieldName[key];
                if (AppParts.option_list_jp.containsKey(fieldName[key])) {
                  title = AppParts.option_list_jp[fieldName[key]]!;
                }

                String data = "";
                if (fields.contains(fieldName[key])) {
                  data = snapshot.data!.docs[0][fieldName[key]];
                }

                lists.add(CustomListField(
                  uid: uid,
                  icon: Icons.event_note_outlined,
                  title: fieldName[key],
                  date: _day,
                  docid: docid,
                  data: data,
                  fields: fields,
                  isYourself: isYourself,
                ));
              }
            });
            List<Widget> widgetList = [];

            if (isYourself) {
              widgetList.add(StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseData.getLastWeightSnapshot(uid: uid, day: _day),
                  builder: (context, snapshot2) {
                    if (snapshot2.hasData) {
                      double last_weight = _myself!['weight_init'] + 0.0;

                      int index = 0;
                      while (index != snapshot2.data!.docs.length) {
                        List _fields =
                            snapshot2.data!.docs[index]['fields'].toList();
                        if (_fields.contains("weight")) {
                          last_weight =
                              snapshot2.data!.docs[index]['weight'] + 0.0;
                          break;
                        } else {
                          index++;
                        }
                      }
                      return perOfGoal(
                          myself: _myself,
                          snapshot: snapshot,
                          last_weight: last_weight);
                    } else {
                      return AppParts.loadingImage;
                    }
                  }));
              widgetList.add(const SizedBox(height: 20));
            }
            widgetList.add(Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                          initiallyExpanded:
                              (_myself!['account_name'] == accountName)
                                  ? true
                                  : false,
                          title: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: CircleAvatar(
                                  foregroundImage: Image.network(iconUrl).image,
                                  backgroundImage:
                                      Image.asset("lib/assets/appicon.png")
                                          .image,
                                  backgroundColor: AppParts.backColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: (_myself!['account_name'] == accountName)
                                    ? const Text("あなた")
                                    : Text(accountName),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      "[${fields.length}/${fieldName.length}]")),
                            ],
                          ),
                          children: [Column(children: lists)]),
                    ))));

            return Column(children: widgetList);
          } else {
            return AppParts.loadingImage;
          }
        });

    return response;
  }
}
