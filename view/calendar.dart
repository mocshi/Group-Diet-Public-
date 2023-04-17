import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_diet/utils/firebase_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/customLineChart.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key, required Map<String, dynamic> myself})
      : _myself = myself,
        super(key: key);

  final Map<String, dynamic> _myself;

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late TextEditingController _dateInput_From = TextEditingController();
  late TextEditingController _dateInput_To = TextEditingController();
  TextEditingController _AlertFrom = TextEditingController();
  TextEditingController _AlertTo = TextEditingController();
  late int numLineChild;

  @override
  void initState() {
    _AlertFrom.text = "";
    _AlertTo.text = "";
    numLineChild = 1;
    DateTime maxDate = DateTime.now();
    DateTime minDate = reformDateTime(int2Date(widget._myself['createdAt']));
    _dateInput_From.text = DateFormat('yyyy/MM/dd').format(minDate);
    _dateInput_To.text = DateFormat('yyyy/MM/dd').format(maxDate);

    super.initState();
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  Map<DateTime, List<dynamic>> createEventList(
      List<QueryDocumentSnapshot> data, MainProvider mainProvider) {
    Map<DateTime, List<dynamic>> response = {};
    Color mainColor =
        AppParts.colorList.values.toList()[mainProvider.myself['mainColor']];

    data.forEach((element) {
      List<Widget> event = [];
      int _date = element['date'];
      List _fields = [];
      int index = 0;

      List myfields = stringToList(mainProvider.myself['option_item_n']);
      myfields.forEach((f) {
        if (element['fields'].contains(f)) _fields.add(f);
      });
      element['fields'].forEach((f) {
        if (!element['fields'].contains(f)) _fields.add(f);
      });

      _fields.forEach((value) {
        String title;
        Widget subtitle = const SizedBox(width: 1);
        (AppParts.option_list_jp.containsKey(value))
            ? title = AppParts.option_list_jp[value]!
            : title = value;

        var data = element[value];
        if (data.runtimeType == int || data.runtimeType == double) {
          subtitle = Text(
            data.toString(),
            style: const TextStyle(fontSize: 13),
          );
        } else if (data.runtimeType == String) {
          subtitle = AppParts.listValuesYN[data]!;
        } else if (data.runtimeType == List<dynamic>) {
          List<Widget> item = [];

          double _total = 0;
          data.forEach((d) {
            String listText = "";
            if (value == "exercise") {
              double _weight = -1;
              if (_fields.contains("weight")) {
                _weight = element['weight'] + 0.0;
              }

              if (_weight > 0) {
                double cal = getCalorieBurnfromMETs(
                  h: double.parse(d['time_h']),
                  m: double.parse(d['METs']),
                  w: _weight.toDouble(),
                );
                _total = _total + cal;
                listText =
                    "${d['title']}: ${d['time_h'].toString()}h: ${cal.toInt().toString()}kcal";
              } else {
                listText =
                    "${d['title']}: ${d['time_h'].toString()}h:\n [!]体重を入力すると消費カロリーが算出されます";
              }
            } else {
              double cal =
                  double.parse(d['cal']) * double.parse(d['gramme']) / 100;
              _total = _total + cal;
              listText = "${d['title']}: ${d['gramme']}g: ${cal.toInt()}kcal";
            }

            item.add(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: mainColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(listText, style: const TextStyle(fontSize: 13)),
              ),
            ));
          });

          subtitle = Wrap(
            children: item,
          );
          title = "$title (合計${_total.toInt()}kcal)";
        }

        event.add(Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.circle,
                          color: mainColor,
                          size: 15,
                        ),
                        title: Text(title),
                        subtitle: subtitle)))));
        index++;
      });

      response[int2Date(_date)] = event;
    });
    return response;
  }

  SliverAppBar appBarCalendar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height / 10 * 1,
      pinned: true,
      backgroundColor: AppParts.backColor,
      title: const Text('Calendar',
          style: TextStyle(
            color: AppParts.charColor,
          )),
      bottom: TabBar(tabs: <Widget>[
        Tab(
            icon: Icon(
          Icons.calendar_month,
          color: getMainColor(context),
        )),
        Tab(
            icon: Icon(
          Icons.line_axis,
          color: getMainColor(context),
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = context.read<MainProvider>();

    return Scaffold(
        body: SafeArea(
            child: DefaultTabController(
                length: 2,
                child: CustomScrollView(slivers: [
                  appBarCalendar(context),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SingleChildScrollView(
                          child: FutureBuilder(
                              future: FirebaseData.getAllData(
                                  uid: mainProvider.myself['id']),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Error get data');
                                } else if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data != null) {
                                  Map<DateTime, List<dynamic>> eventsList =
                                      createEventList(
                                          snapshot.data!.docs, mainProvider);

                                  final events = LinkedHashMap<DateTime, List>(
                                    equals: isSameDay,
                                    hashCode: getHashCode,
                                  )..addAll(eventsList);

                                  List getEvent(DateTime day) {
                                    return events[day] ?? [];
                                  }

                                  DateTime firstDay = DateTime.now();
                                  eventsList.forEach(
                                    (key, value) {
                                      if (firstDay.compareTo(key) > 0) {
                                        firstDay = key;
                                      }
                                    },
                                  );

                                  List fieldsName = stringToList(
                                      mainProvider.myself['option_item_n']);
                                  List fieldsType = stringToList(
                                      mainProvider.myself['option_item_v']);

                                  Map<String, String> pdwnlist = {};
                                  pdwnlist['体重(kg)'] = "weight";
                                  pdwnlist['摂取カロリー(kcal)'] = "foods";
                                  pdwnlist['たんぱく質(g)'] = "P";
                                  pdwnlist['脂質(g)'] = "F";
                                  pdwnlist['炭水化物(g)'] = "C";
                                  fieldsName.asMap().forEach((index, element) {
                                    if (!AppParts.option_list_jp
                                        .containsKey(element)) {
                                      pdwnlist[element] = fieldsType[index];
                                    }
                                  });

                                  List<Widget> lineChild = [];
                                  int num = 0;
                                  while (num < numLineChild) {
                                    lineChild.add(CreateLineChart(
                                      list: pdwnlist,
                                      snapshot: snapshot.data,
                                      createdAt: int2Date(
                                          mainProvider.myself['createdAt']),
                                      From: _dateInput_From.text,
                                      To: _dateInput_To.text,
                                      numLine: numLineChild,
                                    ));
                                    num++;
                                  }

                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        10 *
                                        7.5,
                                    child: TabBarView(children: [
                                      //Calendar
                                      SingleChildScrollView(
                                          child: createCalendar(
                                        events: events,
                                        firstDay: firstDay,
                                      )),
                                      //LineChart
                                      Column(children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10 *
                                              6.4,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: lineChild,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Card(
                                                          //color: AppParts.mainColor.withOpacity(0.2),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                _dateInput_From
                                                                    .text,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                              ))),
                                                      // const Expanded(
                                                      //     child: SizedBox()),
                                                      MaterialButton(
                                                        onPressed: () {
                                                          _openAlertBox(
                                                              context);
                                                        },
                                                        color: getMainColor(
                                                            context),
                                                        textColor: Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        shape:
                                                            const CircleBorder(),
                                                        child: const Icon(
                                                          Icons.calendar_month,
                                                          size: 30,
                                                        ),
                                                      ),
                                                      MaterialButton(
                                                        onPressed: () {
                                                          if (numLineChild >=
                                                              3) {
                                                            customSnackBar(
                                                                content:
                                                                    "グラフは3つ以上追加できません");
                                                          } else {
                                                            setState(() {
                                                              numLineChild++;
                                                            });
                                                          }
                                                        },
                                                        color: getMainColor(
                                                            context),
                                                        textColor: Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        shape:
                                                            const CircleBorder(),
                                                        child: const Icon(
                                                          Icons.add_chart,
                                                          size: 30,
                                                        ),
                                                      ),
                                                      // const Expanded(
                                                      //     child: SizedBox()),
                                                      Card(
                                                          //color: AppParts.mainColor.withOpacity(0.2),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                  _dateInput_To
                                                                      .text,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          13)))),
                                                    ],
                                                  )),
                                            )),
                                      ]),
                                    ]),
                                  );
                                } else {
                                  return Column(children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                    ),
                                    Center(child: AppParts.loadingImage)
                                  ]);
                                }
                              })),
                    ]),
                  ),
                ]))));
  }

  _openAlertBox(BuildContext context) {
    MainProvider mainProvider = context.read<MainProvider>();
    final _formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          _AlertFrom.text = _dateInput_From.text;
          _AlertTo.text = _dateInput_To.text;
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
                        "From - To",
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.calendar_month,
                            color: getMainColor(context),
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
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextFormField(
                          controller: _AlertFrom,
                          decoration: const InputDecoration(labelText: "From"),
                          readOnly: true,
                          validator: (value) {
                            if (value == null) {
                              return '値を入力ください。';
                            }
                            if (value.isEmpty) {
                              return '値を入力ください。';
                            }
                            if (value.indexOf(' ') >= 0 && value.trim() == '') {
                              return '空文字は受け付けていません。';
                            }

                            if (value.indexOf('　') >= 0 && value.trim() == '') {
                              return '空文字は受け付けていません。';
                            }
                            if (_AlertTo.text.isNotEmpty) {
                              if (transString2Date(value)
                                  .isAfter(transString2Date(_AlertTo.text))) {
                                return 'Toより前の日付を選択ください。';
                              }
                            }

                            return null;
                          },
                          onTap: () async {
                            DateTime initdate;
                            DateTime fdate;
                            DateTime ldate;

                            fdate = int2Date(mainProvider.myself['createdAt']);
                            ldate = DateTime.now();
                            (_AlertFrom.text == "")
                                ? initdate = DateTime.now()
                                : initdate = transString2Date(_AlertFrom.text);

                            showCustomDatePicker(
                                context, initdate, fdate, ldate, (pickedDate) {
                              String formattedDate =
                                  DateFormat('yyyy/MM/dd').format(pickedDate);

                              _AlertFrom.text = formattedDate;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextFormField(
                          controller: _AlertTo,
                          decoration: const InputDecoration(labelText: "To"),
                          readOnly: true,
                          validator: (value) {
                            if (value == null) {
                              return '値を入力ください。';
                            }
                            if (value.isEmpty) {
                              return '値を入力ください。';
                            }
                            if (value.indexOf(' ') >= 0 && value.trim() == '') {
                              return '空文字は受け付けていません。';
                            }

                            if (value.indexOf('　') >= 0 && value.trim() == '') {
                              return '空文字は受け付けていません。';
                            }
                            if (_AlertFrom.text.isNotEmpty) {
                              if (transString2Date(value).isBefore(
                                  transString2Date(_AlertFrom.text))) {
                                return 'Fromより後の日付を選択ください。';
                              }
                            }

                            return null;
                          },
                          onTap: () async {
                            DateTime initdate;
                            DateTime fdate;
                            DateTime ldate;

                            fdate = int2Date(mainProvider.myself['createdAt']);
                            ldate = DateTime.now();
                            (_AlertTo.text == "")
                                ? initdate = DateTime.now()
                                : initdate = transString2Date(_AlertTo.text);

                            showCustomDatePicker(
                                context, initdate, fdate, ldate, (pickedDate) {
                              String formattedDate =
                                  DateFormat('yyyy/MM/dd').format(pickedDate);

                              _AlertTo.text = formattedDate;
                            });
                          },
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
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
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _dateInput_From.text = _AlertFrom.text;
                          _dateInput_To.text = _AlertTo.text;
                        });

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

class createCalendar extends StatefulWidget {
  const createCalendar({
    Key? key,
    required DateTime firstDay,
    required LinkedHashMap<DateTime, List> events,
  })  : _firstDay = firstDay,
        _events = events,
        super(key: key);

  final DateTime _firstDay;
  final LinkedHashMap<DateTime, List> _events;

  @override
  _createCalendarState createState() => _createCalendarState();
}

class _createCalendarState extends State<createCalendar> {
  late DateTime _selected;
  late DateTime _focused;
  final ScrollController _scrollController_calendar = ScrollController();
  final ScrollController _scrollController_event = ScrollController();

  @override
  void initState() {
    _selected = DateTime.now();
    _focused = DateTime.now();
    super.initState();
  }

  List getEvent(DateTime day) {
    return widget._events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: MediaQuery.of(context).size.height / 10 * 4,
        padding: const EdgeInsets.all(5),
        child: TableCalendar(
          shouldFillViewport: true,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
          ),
          firstDay: widget._firstDay,
          lastDay: DateTime.now(),
          eventLoader: getEvent,
          selectedDayPredicate: (day) {
            return isSameDay(_selected, day);
          },
          onDaySelected: (selected, focused) {
            if (!isSameDay(_selected, selected)) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
            }
          },
          focusedDay: _focused,
          calendarBuilders:
              CalendarBuilders(markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return _buildEventsMarker(date, events);
            }
          }),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(5),
        height: MediaQuery.of(context).size.height / 10 * 3,
        child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController_event,
            child: SingleChildScrollView(
              controller: _scrollController_event,
              child: Column(
                children: getEvent(_selected).map((event) {
                  return Padding(
                      padding: const EdgeInsets.all(5), child: event);
                }).toList(),
              ),
            )),
      ),
    ]);
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 5,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[300],
        ),
        width: 12.0,
        height: 12.0,
        child: Center(
          child: Text(
            //'${events.length}',
            '',
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}

class CreateLineChart extends StatefulWidget {
  const CreateLineChart(
      {super.key,
      required Map<String, String> list,
      required QuerySnapshot<Map<String, dynamic>>? snapshot,
      required DateTime createdAt,
      required String From,
      required String To,
      required int numLine})
      : _list = list,
        _createdAt = createdAt,
        _snapshot = snapshot,
        _From = From,
        _To = To,
        _numLine = numLine;

  final Map<String, String> _list;
  final QuerySnapshot<Map<String, dynamic>>? _snapshot;
  final DateTime _createdAt;
  final String _From;
  final String _To;
  final int _numLine;
  @override
  State<CreateLineChart> createState() => _CreateLineChartState();
}

class _CreateLineChartState extends State<CreateLineChart> {
  late String dropdownValue;
  @override
  void initState() {
    dropdownValue = widget._list.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 20 * 1,
          child: DropdownButton<String>(
            alignment: Alignment.center,
            value: dropdownValue,
            style: const TextStyle(color: AppParts.charColor, fontSize: 15),
            underline: Container(
              height: 2,
              color: getMainColor(context).withOpacity(0.5),
            ),
            onChanged: (String? value) {
              setState(() {
                dropdownValue = value!;
              });
            },
            items:
                widget._list.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                alignment: Alignment.center,
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        CustomLineChart(
            snapshot: widget._snapshot,
            firstDate: widget._createdAt,
            lastDate: DateTime.now(),
            From: widget._From,
            To: widget._To,
            numLine: widget._numLine,
            fieldTye: {dropdownValue: widget._list[dropdownValue].toString()})
      ],
    );
  }
}
