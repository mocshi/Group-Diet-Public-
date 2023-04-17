import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../utils/common.dart';
import '../utils/gadmod.dart';
import '../utils/inputDataForm.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({
    Key? key,
    required BuildContext context,
    required DocumentSnapshot<Object?>? myself,
    required Map mem_id,
  })  : _context = context,
        _myself = myself,
        _mem_id = mem_id,
        super(key: key);

  final BuildContext _context;
  final DocumentSnapshot<Object?>? _myself;
  final Map _mem_id;

  @override
  State<StatefulWidget> createState() {
    return _RecordPageState();
  }
}

class _RecordPageState extends State<RecordPage> {
  late int _date_int;
  late String _date;

  @override
  void initState() {
    MobileAds.instance.initialize();
    _date_int = getIntToday();
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd');
    _date = outputFormat.format(now);
  }

  void changeDateInt(int value) {
    setState(() {
      _date_int = value;
    });
  }

  void changeDateString(String value) {
    setState(() {
      _date = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String _title;

    (_date_int == getIntToday()) ? _title = "$_date(本日)" : _title = "$_date";

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: getMainColor(context),
          title: Text('記録 $_title'),
        ),
        floatingActionButton: SizedBox(
          width: 50,
          child: FloatingActionButton(
              backgroundColor: getMainColor(context),
              child: const Icon(Icons.calendar_month),
              onPressed: () async {
                DateTime initdate;
                DateTime fdate;
                DateTime ldate;

                fdate = int2Date(widget._myself!['createdAt'])
                    .add(const Duration(days: -365));
                ldate = DateTime.now();
                (_date == "")
                    ? initdate = DateTime.now()
                    : initdate = DateFormat('yyyy/MM/dd').parse(_date);

                showCustomDatePicker(context, initdate, fdate, ldate,
                    (pickedDate) {
                  String formattedDate =
                      DateFormat('yyyy/MM/dd').format(pickedDate);
                  changeDateString(formattedDate);
                  formattedDate = DateFormat('yyyyMMdd').format(pickedDate);
                  changeDateInt(int.parse(formattedDate));
                });
              }),
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: InputDataForm(
                          day: _date_int,
                          context: context,
                          myself: widget._myself,
                          mem_id: widget._mem_id,
                        )))),
            const Center(
              child: AdBanner(size: AdSize.banner),
            ),
          ],
        ));
  }
}
