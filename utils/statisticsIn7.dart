import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'common.dart';
import 'firebase_data.dart';
import 'firebase_user.dart';

class StatisticsIn7 {
  static List<Row> rankingEXCList(Map<String, String> listUid) {
    List<Row> response = [];
    List<Container> icons = memIcon(listUid);
    List<Expanded> percentage_Chart = StatisticsIn7.createWithID(listUid);
    int index = 0;
    icons.forEach((element) {
      response.add(Row(
        children: [element, percentage_Chart[index]],
      ));
      index++;
    });

    return response;
  }

  static List<Expanded> createWithID(Map listUid) {
    List<Expanded> response = [];

    listUid.forEach((key, uid) {
      response.add(Expanded(
          child: FutureBuilder(
              future: FirebaseUser.getUser(docid: uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseData.getDataLast7DaySnapshot(
                          uid: uid, today: DateTime.now()),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          List<Color> rcolors = List.filled(7, Colors.grey);

                          double total_EXC = 0;
                          double total_RCAL = 0;
                          double last_weight =
                              snapshot.data!['weight_init'] + 0.0;

                          if (snapshot2.data!.docs.isNotEmpty) {
                            List fields = [];

                            snapshot2.data!.docs.forEach((element) {
                              double _thisTotal_EXC = 0;
                              double cal_1 = 0;
                              double cal_2 = 0;
                              double cal_3 = 0;

                              rcolors[int2Date(getIntToday())
                                  .difference(int2Date(element['date']))
                                  .inDays] = Colors.green;

                              fields = element['fields'];

                              if (fields.contains("weight")) {
                                last_weight = element['weight'] + 0.0;
                              }

                              if (fields.contains("exercise")) {
                                List datas = element['exercise'];

                                datas.forEach((element2) {
                                  _thisTotal_EXC = _thisTotal_EXC +
                                      getCalorieBurnfromMETs(
                                        h: double.parse(element2['time_h']),
                                        w: last_weight.toDouble(),
                                        m: double.parse(element2['METs']),
                                      );
                                });
                                total_EXC = total_EXC + _thisTotal_EXC;
                              }

                              if (fields.contains("breakfast")) {
                                List datas = element['breakfast'];

                                datas.forEach((element2) {
                                  cal_1 = cal_1 +
                                      double.parse(element2['cal']) *
                                          double.parse(element2['gramme']) /
                                          100;
                                });
                              }

                              if (fields.contains("lunch")) {
                                List datas = element['lunch'];

                                datas.forEach((element2) {
                                  cal_2 = cal_2 +
                                      double.parse(element2['cal']) *
                                          double.parse(element2['gramme']) /
                                          100;
                                });
                              }

                              if (fields.contains("dinner")) {
                                List datas = element['dinner'];

                                datas.forEach((element2) {
                                  cal_3 = cal_3 +
                                      double.parse(element2['cal']) *
                                          double.parse(element2['gramme']) /
                                          100;
                                });
                              }

                              int age = getAge(snapshot.data!['birth']);
                              double bmr = getBMRfromGanpule(
                                  a: age.toDouble(),
                                  h: snapshot.data!['height'].toDouble(),
                                  w: last_weight.toDouble(),
                                  s: snapshot.data!['sex']);

                              int energyPAL = getCalorieBurnfromPAL(
                                      a: age.toDouble(),
                                      bmr: bmr.toDouble(),
                                      level: int.parse(snapshot.data!['pal']))
                                  .toInt();

                              total_RCAL = total_RCAL +
                                  (bmr +
                                      energyPAL +
                                      _thisTotal_EXC -
                                      cal_1 -
                                      cal_2 -
                                      cal_3);
                            });
                          }

                          return Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: double.infinity,
                              child: Wrap(
                                spacing: 5,
                                children: [
                                  Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.5 +
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3 +
                                              10,
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "記録状況",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                Wrap(
                                                  spacing: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3 +
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3.5 +
                                                          10 -
                                                          240 -
                                                          10) /
                                                      6,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[6],
                                                          child: const Center(
                                                            child: Text(
                                                              "6",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[5],
                                                          child: const Center(
                                                            child: Text(
                                                              "5",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[4],
                                                          child: const Center(
                                                            child: Text(
                                                              "4",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[3],
                                                          child: const Center(
                                                            child: Text(
                                                              "3",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[2],
                                                          child: const Center(
                                                            child: Text(
                                                              "2",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[1],
                                                          child: const Center(
                                                            child: Text(
                                                              "1",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: CircleAvatar(
                                                          maxRadius: 10,
                                                          backgroundColor:
                                                              rcolors[0],
                                                          child: const Center(
                                                            child: Text(
                                                              "0",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                )
                                              ]))),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      child: ListTile(
                                        title: const Text(
                                          "運動量",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                            "${total_EXC.toInt().toString()}kcal",
                                            textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      child: ListTile(
                                        title: const Text(
                                          "制限カロリー",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        subtitle: Text(
                                            "${total_RCAL.toInt().toString()}kcal",
                                            textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        } else {
                          return AppParts.loadingImage;
                        }
                      });
                } else {
                  return AppParts.loadingImage;
                }
              })));
    });

    return response;
  }
}
