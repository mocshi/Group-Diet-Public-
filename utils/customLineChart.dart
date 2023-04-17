import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'common.dart';

import 'package:charts_flutter/src/text_style.dart' as style;

import 'package:charts_flutter/src/text_element.dart' as txt_element;

class CustomLineChart extends StatefulWidget {
  const CustomLineChart(
      {Key? key,
      required QuerySnapshot<Map<String, dynamic>>? snapshot,
      required Map fieldTye,
      required DateTime firstDate,
      required DateTime lastDate,
      required String From,
      required String To,
      required int numLine})
      : _snapshot = snapshot,
        _fieldType = fieldTye,
        _firstDate = firstDate,
        _lastDate = lastDate,
        _From = From,
        _To = To,
        _numLine = numLine,
        super(key: key);

  final QuerySnapshot<Map<String, dynamic>>? _snapshot;
  final Map _fieldType;
  final DateTime _firstDate;
  final DateTime _lastDate;
  final String _From;
  final String _To;
  final int _numLine;

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late TextEditingController _dateInput_From = TextEditingController();
  late TextEditingController _dateInput_To = TextEditingController();
  late List<charts.Series<dynamic, DateTime>> seriesList;
  late bool animate;
  @override
  void initState() {
    _dateInput_From.text = widget._From;
    _dateInput_To.text = widget._To;
    seriesList = [];
    animate = true;
    super.initState();
  }

  CustomCircleSymbolRenderer ccyr = CustomCircleSymbolRenderer();

  @override
  Widget build(BuildContext context) {
    seriesList = _createData(widget._snapshot);
    double maxMain = 0;
    double minMain = 0;
    DateTime maxDate = DateTime.now();
    DateTime minDate = reformDateTime(widget._firstDate);
    _dateInput_From.text = widget._From;
    _dateInput_To.text = widget._To;

    seriesList[0].data.asMap().forEach((key, element) {
      if (key == 0) {
        minMain = element.sales;
        maxMain = element.sales;
        maxDate = element.time;
        minDate = element.time;
      }
      if (maxMain < element.sales) maxMain = element.sales;
      if (minMain > element.sales) minMain = element.sales;
    });

    ccyr.setMaxMain(maxMain);
    ccyr.setMinMain(minMain);
    ccyr.setMaxDate(DateFormat('yyyy/MM/dd').parse(widget._To));
    ccyr.setMinDate(DateFormat('yyyy/MM/dd').parse(widget._From));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height / 10 * 6 / widget._numLine -
                  MediaQuery.of(context).size.height / 20 * 1,
          width: MediaQuery.of(context).size.width / 30 * 29,
          child: (widget._fieldType.values.first != "yn")
              ? charts.TimeSeriesChart(
                  seriesList,
                  animate: animate,
                  domainAxis: charts.DateTimeAxisSpec(
                      viewport: charts.DateTimeExtents(
                          end: DateFormat('yyyy/MM/dd')
                              .parse(widget._To)
                              .add(const Duration(days: 1)),
                          start: DateFormat('yyyy/MM/dd').parse(widget._From)),
                      renderSpec: const charts.NoneRenderSpec()),
                  dateTimeFactory: const charts.LocalDateTimeFactory(),
                  defaultRenderer:
                      charts.LineRendererConfig(includePoints: true),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    viewport: charts.NumericExtents(
                        minMain - (maxMain / 20), maxMain + (maxMain / 20)),
                    tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                      zeroBound: false,
                      desiredTickCount: 7,
                    ),
                  ),
                  behaviors: [
                    charts.LinePointHighlighter(symbolRenderer: ccyr)
                  ],
                  selectionModels: [
                    charts.SelectionModelConfig(
                        changedListener: (charts.SelectionModel model) {
                      if (model.hasDatumSelection) {
                        ccyr.setValue(model.selectedSeries[0]
                            .measureFn(model.selectedDatum[0].index)
                            .toString());

                        ccyr.setDomain(model.selectedSeries[0]
                            .domainFn(model.selectedDatum[0].index));
                      }
                    })
                  ],
                )
              : Stack(
                  children: [
                    charts.PieChart<DateTime>(seriesList,
                        animate: animate,
                        defaultRenderer: charts.ArcRendererConfig(
                            arcRendererDecorators: [
                              charts.ArcLabelDecorator(
                                  labelPosition: charts.ArcLabelPosition.inside)
                            ])),
                    Column(
                      children: [
                        Row(children: const [
                          Icon(
                            Icons.brightness_1,
                            size: 12,
                            color: Colors.green,
                          ),
                          Text(" Yes",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: AppParts.char_sub_Color)),
                        ]),
                        Row(children: const [
                          Icon(
                            Icons.brightness_1,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                          Text(" No",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: AppParts.char_sub_Color)),
                        ]),
                        Row(children: const [
                          Icon(
                            Icons.brightness_1,
                            size: 12,
                            color: Colors.blueGrey,
                          ),
                          Text(" Unknown",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: AppParts.char_sub_Color)),
                        ]),
                      ],
                    )
                  ],
                ),
        ),
      ],
    );
  }

  List<charts.Series<TimeSeriesSales, DateTime>> _createData(
      QuerySnapshot<Map<String, dynamic>>? snapshot) {
    List<TimeSeriesSales> data = [];
    bool _dateRangeFlg_From;
    bool _dateRangeFlg_To;

    double countYes = 0;
    double countNo = 0;
    double countUnk = 0;

    snapshot!.docs.forEach((element) {
      List fields = element['fields'];

      if (_dateInput_From.text != "") {
        if (element['date'] -
                int.parse(_dateInput_From.text.replaceAll("/", "")) >=
            0) {
          _dateRangeFlg_From = true;
        } else {
          _dateRangeFlg_From = false;
        }
      } else {
        _dateRangeFlg_From = true;
      }

      if (_dateInput_To.text != "") {
        if (element['date'] -
                int.parse(_dateInput_To.text.replaceAll("/", "")) <=
            0) {
          _dateRangeFlg_To = true;
        } else {
          _dateRangeFlg_To = false;
        }
      } else {
        _dateRangeFlg_To = true;
      }

      if (_dateRangeFlg_From && _dateRangeFlg_To) {
        if (widget._fieldType.values.first == "yn") {
          if (fields.contains(widget._fieldType.keys.first)) {
            if (element[widget._fieldType.keys.first] ==
                AppParts.listValuesYN.keys.first) {
              countYes++;
            } else {
              countNo++;
            }
          } else {
            countUnk++;
          }
        } else if (widget._fieldType.values.first == "weight") {
          (fields.contains(widget._fieldType.values.first))
              ? data.add(TimeSeriesSales(
                  int2Date(element['date']),
                  element[widget._fieldType.values.first] + 0.0,
                  charts.MaterialPalette.blue.shadeDefault))
              : null;
        } else if (widget._fieldType.values.first == "foods") {
          if ((fields.contains("breakfast") ||
              fields.contains("lunch") ||
              fields.contains("dinner"))) {
            double cal = 0;
            if (fields.contains("breakfast")) {
              List item = element['breakfast'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['cal']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("lunch")) {
              List item = element['lunch'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['cal']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("dinner")) {
              List item = element['dinner'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['cal']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }

            data.add(TimeSeriesSales(
                int2Date(element['date']),
                double.parse(cal.toStringAsFixed(1)),
                charts.MaterialPalette.blue.shadeDefault));
          }
        } else if (widget._fieldType.values.first == "P") {
          if ((fields.contains("breakfast") ||
              fields.contains("lunch") ||
              fields.contains("dinner"))) {
            double cal = 0;
            if (fields.contains("breakfast")) {
              List item = element['breakfast'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['P']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("lunch")) {
              List item = element['lunch'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['P']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("dinner")) {
              List item = element['dinner'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['P']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }

            data.add(TimeSeriesSales(
                int2Date(element['date']),
                double.parse(cal.toStringAsFixed(1)),
                charts.MaterialPalette.blue.shadeDefault));
          }
        } else if (widget._fieldType.values.first == "F") {
          if ((fields.contains("breakfast") ||
              fields.contains("lunch") ||
              fields.contains("dinner"))) {
            double cal = 0;
            if (fields.contains("breakfast")) {
              List item = element['breakfast'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['F']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("lunch")) {
              List item = element['lunch'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['F']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("dinner")) {
              List item = element['dinner'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['F']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }

            data.add(TimeSeriesSales(
                int2Date(element['date']),
                double.parse(cal.toStringAsFixed(1)),
                charts.MaterialPalette.blue.shadeDefault));
          }
        } else if (widget._fieldType.values.first == "C") {
          if ((fields.contains("breakfast") ||
              fields.contains("lunch") ||
              fields.contains("dinner"))) {
            double cal = 0;
            if (fields.contains("breakfast")) {
              List item = element['breakfast'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['C']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("lunch")) {
              List item = element['lunch'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['C']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }
            if (fields.contains("dinner")) {
              List item = element['dinner'].toList();
              item.forEach((element) {
                cal = cal +
                    double.parse(element['C']) *
                        double.parse(element['gramme']) /
                        100;
              });
            }

            data.add(TimeSeriesSales(
                int2Date(element['date']),
                double.parse(cal.toStringAsFixed(1)),
                charts.MaterialPalette.blue.shadeDefault));
          }
        } else {
          if (fields.contains(widget._fieldType.keys.first)) {
            data.add(TimeSeriesSales(
                int2Date(element['date']),
                element[widget._fieldType.keys.first] + 0.0,
                charts.MaterialPalette.blue.shadeDefault));
          }
        }
      }
    });

    if (widget._fieldType.values.first == "yn") {
      data.add(TimeSeriesSales(DateTime.now(), countYes,
          charts.ColorUtil.fromDartColor(Colors.green)));
      data.add(TimeSeriesSales(DateTime.now(), countNo,
          charts.ColorUtil.fromDartColor(Colors.redAccent)));
      data.add(TimeSeriesSales(DateTime.now(), countUnk,
          charts.ColorUtil.fromDartColor(Colors.blueGrey)));
      return [
        charts.Series<TimeSeriesSales, DateTime>(
          id: 'Data',
          colorFn: (TimeSeriesSales sales, _) => sales.color,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales,
          data: data,
          labelAccessorFn: (TimeSeriesSales sales, _) => '${sales.sales}',
        )
      ];
    } else {
      return [
        charts.Series<TimeSeriesSales, DateTime>(
          id: 'Data',
          colorFn: (_, __) =>
              charts.ColorUtil.fromDartColor(getMainColor(context)),
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales,
          data: data,
        )
      ];
    }
  }
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;
  final charts.Color color;

  TimeSeriesSales(this.time, this.sales, this.color);
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  double _maxMain = 0;
  double _minMain = 0;
  DateTime? _maxDate = null;
  DateTime? _minDate = null;

  String value = "";
  DateTime domain = DateTime.now();

  void setMaxMain(v) {
    _maxMain = v;
  }

  void setMinMain(v) {
    _minMain = v;
  }

  void setMinDate(v) {
    _minDate = v;
  }

  void setMaxDate(v) {
    _maxDate = v;
  }

  void setValue(v) {
    value = v;
  }

  void setDomain(v) {
    domain = v;
  }

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    int _x = 0;
    int _y = 0;

    if ((_maxMain - _minMain) / 2 + _minMain <= double.parse(value)) {
      _y = (bounds.top + 20).round();
    } else {
      _y = (bounds.top - 30).round();
    }
    if (_maxDate != null && _minDate != null) {
      double bwnDate = _maxDate!.difference(_minDate!).inDays / 2;
      DateTime avgDate = _minDate!.add(Duration(days: bwnDate.toInt()));

      if (avgDate.difference(domain).inDays < 0) {
        _x = (bounds.left - 100).round();
      } else {
        _x = (bounds.left + 20).round();
      }
    }
    style.TextStyle textStyle = style.TextStyle();
    textStyle.color = charts.Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(txt_element.TextElement('''${value}
${DateFormat('yyyy/MM/dd').format(domain)}''', style: textStyle), _x, _y);
  }
}
