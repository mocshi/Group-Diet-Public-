import 'package:flutter/material.dart';
import 'package:group_diet/utils/firebase_info.dart';
import 'package:intl/intl.dart';

import '../utils/common.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key, required Map<String, dynamic> user})
      : _user = user,
        super(key: key);

  final Map<String, dynamic> _user;

  @override
  State<StatefulWidget> createState() {
    return _InfoPageState();
  }
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: getMainColor(context),
          title: const Text('通知'),
        ),
        body: FutureBuilder(
            future: FirebaseInfo.getInfo(uid: widget._user['id']),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error initializing Authentication');
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return SingleChildScrollView(
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    FirebaseInfo.readedInfo(
                        uid: widget._user['id'],
                        dataid: snapshot.data!.docs[index].id);

                    String _date = DateFormat('yyyy/MM/dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data!.docs[index]['createdAt']));

                    String title = (snapshot.data!.docs[index]['isRead'])
                        ? _date
                        : "$_date NEW";
                    return ListTile(
                      title: Text(title),
                      subtitle:
                          Text(snapshot.data!.docs[index]['doc'].toString()),
                    );
                  },
                ));
              } else {
                return AppParts.loadingImage;
              }
            }));
  }
}
