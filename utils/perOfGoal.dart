import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'common.dart';
import 'firebase_data.dart';
import 'firebase_user.dart';

class percentageGoal extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  percentageGoal({required this.seriesList, required this.animate});

  static List<Row> percentageList(Map<String, String> listUid) {
    List<Row> response = [];

    List<Container> icons = memIcon(listUid);
    List<Expanded> percentage_Chart = percentageGoal.createWithID(listUid);
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
                      stream: FirebaseData.getLastDataSnapshot(uid: uid),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          double pervalue = 0;
                          double last_weight =
                              snapshot.data!['weight_init'] + 0.0;
                          int index = 0;

                          if (snapshot2.data!.docs.isNotEmpty) {
                            List fields = [];
                            while (index != snapshot2.data!.docs.length) {
                              fields = snapshot2.data!.docs[index]['fields'];
                              if (fields.contains("weight")) {
                                last_weight =
                                    snapshot2.data!.docs[index]['weight'] + 0.0;
                                break;
                              } else {
                                index++;
                              }
                            }
                          }

                          pervalue = 100 *
                              (snapshot.data!['weight_init'] - last_weight) /
                              (snapshot.data!['weight_init'] -
                                  snapshot.data!['weight_goal']);

                          return Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 10),
                              child: percentageGoal(
                                seriesList: _createData(
                                    pervalue.toInt(),
                                    charts.ColorUtil.fromDartColor(
                                        getMainColor(context))),
                                animate: true,
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

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      animationDuration: const Duration(milliseconds: 500),
      vertical: false,
      //barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      primaryMeasureAxis: const charts.NumericAxisSpec(
        viewport: charts.NumericExtents(0, 100),
      ),
      // defaultRenderer: charts.BarRendererConfig(
      //     groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
    );
  }

  static List<charts.Series<OrdinalGoal, String>> _createData(
      int value, charts.Color color) {
    final data = [
      OrdinalGoal('data', value, color),
    ];

    return [
      charts.Series<OrdinalGoal, String>(
        id: 'Goal',
        domainFn: (OrdinalGoal sales, _) => sales.user,
        measureFn: (OrdinalGoal sales, _) => sales.pctg,
        colorFn: (OrdinalGoal sales, _) => sales.color,
        data: data,
        // labelAccessorFn: (OrdinalSales sales, _) =>
        //     '${sales.year}: ${sales.sales.toString()}%',
        // insideLabelStyleAccessorFn: (OrdinalSales sales, _) {
        //   return charts.TextStyleSpec(color: charts.MaterialPalette.white);
        // },
        // outsideLabelStyleAccessorFn: (OrdinalSales sales, _) {
        //   return charts.TextStyleSpec(color: charts.MaterialPalette.black);
        // },
      ),
    ];
  }
}

class OrdinalGoal {
  final String user;
  final int pctg;
  final charts.Color color;

  OrdinalGoal(this.user, this.pctg, this.color);
}
