import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'customPieChart.dart';

class perOfGoal extends StatelessWidget {
  perOfGoal({
    super.key,
    required AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
    required DocumentSnapshot<Object?>? myself,
    required double last_weight,
  })  : _snapshot = snapshot,
        _myself = myself,
        _last_weight = last_weight;

  final DocumentSnapshot<Object?>? _myself;
  final AsyncSnapshot<QuerySnapshot<Object?>> _snapshot;
  final double _last_weight;

  late double cal_1;
  late double cal_2;
  late double cal_3;
  late double _p;
  late double _f;
  late double _c;
  late double cal_4;
  late int total_cal;
  late int total_energy;
  late int bmr;
  late int energyPAL;

  @override
  Widget build(BuildContext context) {
    Container response;
    cal_1 = 0;
    cal_2 = 0;
    cal_3 = 0;
    cal_4 = 0;
    _p = 0;
    _f = 0;
    _c = 0;

    if (_snapshot.data!.docs.isNotEmpty) {
      List fields = _snapshot.data!.docs[0]['fields'].toList();

      if (fields.contains("breakfast")) {
        List item = _snapshot.data!.docs[0]['breakfast'].toList();
        item.forEach((element) {
          cal_1 = cal_1 +
              double.parse(element['cal']) *
                  double.parse(element['gramme']) /
                  100;
          _p = _p +
              transCalSymbrol2Num(element['P']) *
                  double.parse(element['gramme']) /
                  100;

          _f = _f +
              transCalSymbrol2Num(element['F']) *
                  double.parse(element['gramme']) /
                  100;

          _c = _c +
              transCalSymbrol2Num(element['C']) *
                  double.parse(element['gramme']) /
                  100;
        });
      }
      if (fields.contains("lunch")) {
        List item = _snapshot.data!.docs[0]['lunch'];
        item.forEach((element) {
          cal_2 = cal_2 +
              double.parse(element['cal']) *
                  double.parse(element['gramme']) /
                  100;

          _p = _p +
              transCalSymbrol2Num(element['P']) *
                  double.parse(element['gramme']) /
                  100;

          _f = _f +
              transCalSymbrol2Num(element['F']) *
                  double.parse(element['gramme']) /
                  100;

          _c = _c +
              transCalSymbrol2Num(element['C']) *
                  double.parse(element['gramme']) /
                  100;
        });
      }
      if (fields.contains("dinner")) {
        List item = _snapshot.data!.docs[0]['dinner'];
        item.forEach((element) {
          cal_3 = cal_3 +
              double.parse(element['cal']) *
                  double.parse(element['gramme']) /
                  100;

          _p = _p +
              transCalSymbrol2Num(element['P']) *
                  double.parse(element['gramme']) /
                  100;

          _f = _f +
              transCalSymbrol2Num(element['F']) *
                  double.parse(element['gramme']) /
                  100;

          _c = _c +
              transCalSymbrol2Num(element['C']) *
                  double.parse(element['gramme']) /
                  100;
        });
      }
      if (fields.contains("exercise")) {
        List item = _snapshot.data!.docs[0]['exercise'];
        item.forEach((element) {
          cal_4 = cal_4 +
              getCalorieBurnfromMETs(
                  h: double.parse(element['time_h']),
                  w: _last_weight.toDouble(),
                  m: double.parse(element['METs']));
        });
      }
    }

    int age = getAge(_myself!['birth']);
    bmr = getBMRfromGanpule(
            a: age.toDouble(),
            h: _myself!['height'].toDouble(),
            w: _last_weight.toDouble(),
            s: _myself!['sex'])
        .toInt();

    energyPAL = getCalorieBurnfromPAL(
            a: age.toDouble(),
            bmr: bmr.toDouble(),
            level: int.parse(_myself!['pal']))
        .toInt();

    total_cal = cal_1.toInt() + cal_2.toInt() + cal_3.toInt();
    total_energy = bmr + cal_4.toInt() + energyPAL;

    double reqP = getReqPperDay(
        bmr: bmr.toDouble(),
        energyPAL: energyPAL.toDouble(),
        exercise: cal_4,
        stress: double.parse(_myself!['stress']));

    double reqF = getReqFperDay(
        bmr: bmr.toDouble(),
        energyPAL: energyPAL.toDouble(),
        exercise: cal_4,
        stress: double.parse(_myself!['stress']));

    double reqC = getReqCperDay(
        bmr: bmr.toDouble(),
        energyPAL: energyPAL.toDouble(),
        exercise: cal_4,
        stress: double.parse(_myself!['stress']));

    if (bmr < 0) {
      energyPAL = 0;
      total_cal = 0;
      total_energy = 0;
      reqP = 0;
      reqF = 0;
      reqC = 0;
      bmr = 0;
    }

    response = Container(
      padding: const EdgeInsets.all(5),
      child: (bmr != 0)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Wrap(spacing: 10, children: [
                              Text("基礎代謝: ${bmr}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: AppParts.char_sub_Color)),
                              Text("生活活動: ${energyPAL}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: AppParts.char_sub_Color)),
                              Text("運動消費: ${cal_4.toInt()}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: AppParts.char_sub_Color)),
                              Text("合計消費カロリー: ${total_energy}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 1,
                                      color: AppParts.char_sub_Color)),
                              Text("合計摂取カロリー: ${total_cal}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: (total_cal > total_energy)
                                          ? Colors.red.shade300
                                          : AppParts.char_sub_Color)),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.blueGrey,
                                          ),
                                          Text(" 基礎代謝",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.lightGreen,
                                          ),
                                          Text(" 理想カロリー",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.redAccent,
                                          ),
                                          Text(" 超過カロリー",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.lime,
                                          ),
                                          Text(" 朝食",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.cyan,
                                          ),
                                          Text(" 昼食",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                        Row(children: const [
                                          Icon(
                                            Icons.brightness_1,
                                            size: 12,
                                            color: Colors.indigo,
                                          ),
                                          Text(" 夕食",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13,
                                                  color:
                                                      AppParts.char_sub_Color)),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      onPressed: () {
                                        _openAlertBox(context);
                                      },
                                      icon: Icon(
                                        Icons.help,
                                        color: getMainColor(context),
                                      )),
                                ],
                              ),
                            ]),
                          ),
                          Container(
                              height: 100,
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                  right: 10, left: 10, bottom: 10),
                              child: _customBarChart(
                                maxX: total_energy.toDouble(),
                                seriesList: _createData([
                                  cal_1.toInt(),
                                  cal_2.toInt(),
                                  cal_3.toInt()
                                ], [
                                  charts.ColorUtil.fromDartColor(Colors.lime),
                                  charts.ColorUtil.fromDartColor(Colors.cyan),
                                  charts.ColorUtil.fromDartColor(Colors.indigo),
                                ]),
                                animate: true,
                              )),
                        ]))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              child: Stack(
                                children: [
                                  Center(
                                      child: Text(
                                          (_p / reqP * 100).toInt().toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: ((_p / reqP * 100) > 100)
                                                  ? Colors.redAccent
                                                  : AppParts.char_sub_Color))),
                                  GaugeChart.generateChart(
                                      "P", (_p / reqP * 100).toInt()),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text("タンパク質",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color)),
                                Text(
                                    "${_p.toInt().toString()}g / ${reqP.toInt().toString()}g",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              child: Stack(
                                children: [
                                  Center(
                                      child: Text(
                                          (_f / reqF * 100).toInt().toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: ((_f / reqF * 100) > 100)
                                                  ? Colors.redAccent
                                                  : AppParts.char_sub_Color))),
                                  GaugeChart.generateChart(
                                      "F", (_f / reqF * 100).toInt()),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text("脂質",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color)),
                                Text(
                                    "${_f.toInt().toString()}g / ${reqF.toInt().toString()}g",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              child: Stack(
                                children: [
                                  Center(
                                      child: Text(
                                          (_c / reqC * 100).toInt().toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: ((_c / reqC * 100) > 100)
                                                  ? Colors.redAccent
                                                  : AppParts.char_sub_Color))),
                                  GaugeChart.generateChart(
                                      "C", (_c / reqC * 100).toInt()),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text("炭水化物",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color)),
                                Text(
                                    "${_c.toInt().toString()}g / ${reqC.toInt().toString()}g",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: AppParts.char_sub_Color))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          : Row(
              children: [
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 5 * 1,
                  child: Image.asset(
                    'lib/assets/appicon.png',
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 5 * 3,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "計算できませんでした。アカウント設定値を確認ください。",
                      style: TextStyle(color: AppParts.char_sub_Color),
                    ))
              ],
            ),
    );

    return response;
  }

  charts.BarChart _customBarChart({
    required double maxX,
    required List<charts.Series<dynamic, String>> seriesList,
    required bool animate,
  }) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      animationDuration: const Duration(milliseconds: 500),
      vertical: false,
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            const charts.TickSpec<num>(0),
            charts.TickSpec<num>((maxX / 4 * 1).toInt()),
            charts.TickSpec<num>((maxX / 4 * 2).toInt()),
            charts.TickSpec<num>((maxX / 4 * 3).toInt()),
            charts.TickSpec<num>((maxX).toInt()),
          ],
        ),
        viewport: charts.NumericExtents(0, maxX.toInt()),
      ),
      defaultRenderer: charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
    );
  }

  List<charts.Series<OrdinalGoal, String>> _createData(
      List<int> value, List<charts.Color> color) {
    final data = [
      OrdinalGoal('data1', 1, charts.MaterialPalette.green.shadeDefault),
    ];

    List<charts.Series<OrdinalGoal, String>> response = [];

    int index = 0;
    value.forEach((element) {
      final data = [
        OrdinalGoal('data1', element, color[index]),
      ];
      response.add(
        charts.Series<OrdinalGoal, String>(
          id: 'Cal1',
          domainFn: (OrdinalGoal sales, _) => sales.user,
          measureFn: (OrdinalGoal sales, _) => sales.pctg,
          colorFn: (OrdinalGoal sales, _) => sales.color,
          data: data,
        ),
      );
      index++;
    });

    int idealCal = energyPAL + cal_4.toInt() - int.parse(_myself!['stress']);
    int overCal = total_energy - bmr - idealCal;
    if (idealCal < 0) {
      idealCal = total_energy - bmr;
      overCal = 0;
    }
    response.add(
      charts.Series<OrdinalGoal, String>(
        id: 'Cal2',
        domainFn: (OrdinalGoal sales, _) => sales.user,
        measureFn: (OrdinalGoal sales, _) => sales.pctg,
        colorFn: (OrdinalGoal sales, _) => sales.color,
        data: [
          OrdinalGoal(
              'data2', bmr, charts.ColorUtil.fromDartColor(Colors.blueGrey)),
          OrdinalGoal('data2', idealCal,
              charts.ColorUtil.fromDartColor(Colors.lightGreen)),
          OrdinalGoal('data2', overCal,
              charts.ColorUtil.fromDartColor(Colors.redAccent)),
        ],
      ),
    );

    return response;
  }

  _openAlertBox(BuildContext context) {
    ScrollController _scrollcontroller = ScrollController();

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
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'lib/assets/help/totalCalHelp.png',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height / 7,
                    child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollcontroller,
                        child: SingleChildScrollView(
                            controller: _scrollcontroller,
                            child: const Text(
                              "下バーが摂取カロリーを表してます、下バーの長さが上バーの緑部分に収まるように食事をしましょう。",
                              style: TextStyle(fontSize: 13),
                            ))),
                  ),
                  const Divider(
                    color: AppParts.char_sub_Color,
                    height: 4.0,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class OrdinalGoal {
  final String user;
  final int pctg;
  final charts.Color color;

  OrdinalGoal(this.user, this.pctg, this.color);
}
