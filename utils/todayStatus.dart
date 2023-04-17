import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'common.dart';
import 'firebase_data.dart';
import 'package:badges/badges.dart' as badges;

class TodayStatus extends StatefulWidget {
  const TodayStatus({
    Key? key,
    required Map<String, String> we_id,
  })  : _we_id = we_id,
        super(key: key);
  final Map<String, String> _we_id;

  @override
  _TodayStatusState createState() => _TodayStatusState();
}

class _TodayStatusState extends State<TodayStatus> {
  List<Widget> response = [];
  late BuildContext _context;
  late DocumentSnapshot<Object?>? _myself;
  late int _date_int;
  late String _date;
  late MainProvider mainProvider;

  @override
  void initState() {
    _date_int = getIntToday();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider = context.watch<MainProvider>();
    List<Container> icons = memIcon(widget._we_id).toList();

    response = [];
    icons.asMap().forEach((key, element) {
      response.add(StreamBuilder(
          stream: FirebaseData.getDataSnapshot(
              uid: widget._we_id.values.elementAt(key), day: getIntToday()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List fields = [];

              if (snapshot.data!.docs.isNotEmpty) {
                fields = snapshot.data!.docs[0]['fields'].toList();
              }

              Color color_weight =
                  (fields.contains(AppParts.option_list_jp.keys.elementAt(0)))
                      ? Colors.green
                      : Colors.grey;

              Color color_breakfast =
                  (fields.contains(AppParts.option_list_jp.keys.elementAt(1)))
                      ? Colors.green
                      : Colors.grey;

              Color color_lunch =
                  (fields.contains(AppParts.option_list_jp.keys.elementAt(2)))
                      ? Colors.green
                      : Colors.grey;

              Color color_dinner =
                  (fields.contains(AppParts.option_list_jp.keys.elementAt(3)))
                      ? Colors.green
                      : Colors.grey;

              Color color_exercise =
                  (fields.contains(AppParts.option_list_jp.keys.elementAt(4)))
                      ? Colors.green
                      : Colors.grey;

              double space = 5.0;
              if (MediaQuery.of(context).size.width - 130 - 230 > 0) {
                space = (MediaQuery.of(context).size.width - 130 - 230) / 4;
              }
              return Row(
                children: [
                  element,
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 130,
                        child: Wrap(
                          spacing: space,
                          children: [
                            Container(
                                width: 70,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    badges.Badge(
                                        badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.white),
                                        showBadge: (color_weight == Colors.grey)
                                            ? false
                                            : true,
                                        badgeContent: const Icon(
                                          Icons.done,
                                          size: 8,
                                          color: Colors.green,
                                        ),
                                        child: Icon(
                                            Icons.monitor_weight_outlined,
                                            color: color_weight)),
                                    Text(AppParts.option_list_jp.values
                                        .elementAt(0))
                                  ],
                                )),
                            Container(
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    badges.Badge(
                                        badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.white),
                                        showBadge:
                                            (color_breakfast == Colors.grey)
                                                ? false
                                                : true,
                                        badgeContent: const Icon(
                                          Icons.done,
                                          size: 8,
                                          color: Colors.green,
                                        ),
                                        child: Icon(Icons.restaurant,
                                            color: color_breakfast)),
                                    Text(AppParts.option_list_jp.values
                                        .elementAt(1))
                                  ],
                                )),
                            Container(
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    badges.Badge(
                                        badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.white),
                                        showBadge: (color_lunch == Colors.grey)
                                            ? false
                                            : true,
                                        badgeContent: const Icon(
                                          Icons.done,
                                          size: 8,
                                          color: Colors.green,
                                        ),
                                        child: Icon(Icons.restaurant,
                                            color: color_lunch)),
                                    Text(AppParts.option_list_jp.values
                                        .elementAt(2))
                                  ],
                                )),
                            Container(
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    badges.Badge(
                                        badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.white),
                                        showBadge: (color_dinner == Colors.grey)
                                            ? false
                                            : true,
                                        badgeContent: const Icon(
                                          Icons.done,
                                          size: 8,
                                          color: Colors.green,
                                        ),
                                        child: Icon(Icons.restaurant,
                                            color: color_dinner)),
                                    Text(AppParts.option_list_jp.values
                                        .elementAt(3))
                                  ],
                                )),
                            Container(
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    badges.Badge(
                                        badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.white),
                                        showBadge:
                                            (color_exercise == Colors.grey)
                                                ? false
                                                : true,
                                        badgeContent: const Icon(
                                          Icons.done,
                                          size: 8,
                                          color: Colors.green,
                                        ),
                                        child: Icon(Icons.sports_martial_arts,
                                            color: color_exercise)),
                                    Text(AppParts.option_list_jp.values
                                        .elementAt(4))
                                  ],
                                )),
                          ],
                        ),
                      ))
                ],
              );
            } else {
              return AppParts.loadingImage;
            }
          }));
    });

    return Column(children: response);
  }
}
