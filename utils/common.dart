import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../view/home.dart';
import '../view/intro.dart';
import '../view/sign_in.dart';
import 'firebase_user.dart';
import 'google_auth.dart';

List<Container> memIcon(Map<String, String> member_id) {
  List<Container> response = [];

  member_id.forEach((key, item) {
    response.add(Container(
        alignment: Alignment.center,
        child: FutureBuilder(
            future: FirebaseUser.getUser(docid: item),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return IconButton(
                  icon: CircleAvatar(
                    foregroundImage: Image.network(
                      snapshot.data!['icon_url'],
                    ).image,
                    backgroundImage:
                        Image.asset("lib/assets/appicon.png").image,
                    backgroundColor: AppParts.backColor,
                    radius: 40,
                  ),
                  tooltip: snapshot.data!['account_name'],
                  iconSize: 40,
                  onPressed: () {},
                );
              } else {
                return AppParts.loadingImage;
              }
            })));
  });

  return response;
}

void showCustomDatePicker(BuildContext ctx, DateTime iniDate, DateTime minDate,
    DateTime maxDate, Function fnc) {
  DateTime _date = iniDate;
  showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
            height: MediaQuery.of(ctx).size.height / 10 * 5,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(ctx).size.height / 10 * 4,
                  child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: reformDateTime(iniDate),
                      minimumDate: reformDateTime(minDate),
                      maximumDate: reformDateTime(maxDate),
                      onDateTimeChanged: (val) {
                        _date = val;
                      }),
                ),

                // Close the modal
                CupertinoButton(
                  child: const Text('OK'),
                  onPressed: () {
                    fnc(_date);
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          ));
}

DateTime reformDateTime(DateTime day) {
  return DateTime(day.year, day.month, day.day);
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

Future customNavigation(bool isReplace, BuildContext context, Widget screen) {
  late Function navi;
  if (isReplace) {
    navi = Navigator.pushReplacement;
  } else {
    navi = Navigator.push;
  }

  return navi(
    context,
    PageRouteBuilder(
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          // alignment: Alignment.center,
          position:
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.bounceOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(seconds: 1),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return screen;
      },
    ),
  );
}

void navigateFNC(BuildContext context) async {
  Map<String, dynamic>? guser = await Authentication.initializeFirebase();

  MainProvider _myProvider = Provider.of(context, listen: false);
  if (guser != null) {
    var fuser = await FirebaseUser.initializeUser(user: guser);
    if (fuser != null) {
      _myProvider.changeUser(fuser);

      customNavigation(true, context, HomeScreen());
    } else {
      _myProvider.changeUser(guser);
      customNavigation(true, context, IntroScreen(user: guser));
    }
  } else {
    //_myProvider.changeUser({});
    customNavigation(true, context, SignInScreen());
  }
}

//ハリス・ベネディクト方程式（日本人改良版）
// 男性：66.4730＋13.7516×W＋5.0033×H－6.7550×A
// 女性：655.0955＋9.5634×W＋1.8496×H－4.6756×A
//国立健康・栄養研究所の式（Ganpule の式）
// 男性：（0.0481×W＋0.0234×H－0.0138×A－0.4235）×1,000/4.186
// 女性：（0.0481×W＋0.0234×H－0.0138×A－0.9708）×1,000/4.186

//Ganplueの方が値低めなのでこっちを採用する
//
double getBMRfromHBE(
    {required double a,
    required double w,
    required double h,
    required String s}) {
  double response = 0;
  if (s == "man") {
    response = 66.4730 + 13.7516 * w + 5.0033 * h - 6.7550 * a;
  } else if (s == "woman") {
    response = 655.0955 + 9.5634 * w + 1.8496 * h - 4.6756 * a;
  }
  return response;
}

double getBMRfromGanpule(
    {required double a,
    required double w,
    required double h,
    required String s}) {
  double response = 0;
  if (s == "man") {
    response = (0.0481 * w + 0.0234 * h - 0.0138 * a - 0.4235) * 1000 / 4.186;
  } else if (s == "woman") {
    response = (0.0481 * w + 0.0234 * h - 0.0138 * a - 0.9708) * 1000 / 4.186;
  }
  return response;
}

//普段の活動レベル別の消費カロリー
double getCalorieBurnfromPAL(
    {required double a, required double bmr, required int level}) {
  double response = 0;
  double pal = 0;

  if (0 <= a && a <= 2) {
    switch (level) {
      case 1:
        pal = 1.35;
        break;
      case 2:
        pal = 1.35;
        break;
      case 3:
        pal = 1.35;
        break;
      default:
        break;
    }
  } else if (3 <= a && a <= 5) {
    switch (level) {
      case 1:
        pal = 1.45;
        break;
      case 2:
        pal = 1.45;
        break;
      case 3:
        pal = 1.45;
        break;
      default:
        break;
    }
  } else if (6 <= a && a <= 7) {
    switch (level) {
      case 1:
        pal = 1.35;
        break;
      case 2:
        pal = 1.55;
        break;
      case 3:
        pal = 1.75;
        break;
      default:
        break;
    }
  } else if (6 <= a && a <= 7) {
    switch (level) {
      case 1:
        pal = 1.35;
        break;
      case 2:
        pal = 1.55;
        break;
      case 3:
        pal = 1.75;
        break;
      default:
        break;
    }
  } else if (8 <= a && a <= 9) {
    switch (level) {
      case 1:
        pal = 1.40;
        break;
      case 2:
        pal = 1.60;
        break;
      case 3:
        pal = 1.80;
        break;
      default:
        break;
    }
  } else if (10 <= a && a <= 11) {
    switch (level) {
      case 1:
        pal = 1.45;
        break;
      case 2:
        pal = 1.65;
        break;
      case 3:
        pal = 1.85;
        break;
      default:
        break;
    }
  } else if (12 <= a && a <= 14) {
    switch (level) {
      case 1:
        pal = 1.50;
        break;
      case 2:
        pal = 1.70;
        break;
      case 3:
        pal = 1.90;
        break;
      default:
        break;
    }
  } else if (15 <= a && a <= 17) {
    switch (level) {
      case 1:
        pal = 1.55;
        break;
      case 2:
        pal = 1.75;
        break;
      case 3:
        pal = 1.95;
        break;
      default:
        break;
    }
  } else if (18 <= a && a <= 29) {
    switch (level) {
      case 1:
        pal = 1.50;
        break;
      case 2:
        pal = 1.75;
        break;
      case 3:
        pal = 2.00;
        break;
      default:
        break;
    }
  } else if (30 <= a && a <= 49) {
    switch (level) {
      case 1:
        pal = 1.50;
        break;
      case 2:
        pal = 1.75;
        break;
      case 3:
        pal = 2.00;
        break;
      default:
        break;
    }
  } else if (50 <= a && a <= 64) {
    switch (level) {
      case 1:
        pal = 1.50;
        break;
      case 2:
        pal = 1.75;
        break;
      case 3:
        pal = 2.00;
        break;
      default:
        break;
    }
  } else if (65 <= a && a <= 74) {
    switch (level) {
      case 1:
        pal = 1.45;
        break;
      case 2:
        pal = 1.70;
        break;
      case 3:
        pal = 1.95;
        break;
      default:
        break;
    }
  } else if (75 <= a) {
    switch (level) {
      case 1:
        pal = 1.40;
        break;
      case 2:
        pal = 1.65;
        break;
      case 3:
        pal = 1.65;
        break;
      default:
        break;
    }
  }

  response = bmr * pal - bmr;

  return response;
}

//METs　×　体重（kg）　×　時間　×　1.05　＝　消費カロリー（kcal）
double getCalorieBurnfromMETs(
    {required double w, required double h, required double m}) {
  double response = 0;
  response = (m - 1) * w * h * 1.05;
  return response;
}

double getReqPperDay(
    {required double bmr,
    required double energyPAL,
    required double exercise,
    required double stress}) {
  double response = 0;
  double totalIdealCal = bmr + (energyPAL + exercise - stress) / 2;

  response = 16.5 * totalIdealCal / 100 / 4;

  return response;
}

double getReqFperDay(
    {required double bmr,
    required double energyPAL,
    required double exercise,
    required double stress}) {
  double response = 0;
  double totalIdealCal = bmr + (energyPAL + exercise - stress) / 2;

  response = 25 * totalIdealCal / 100 / 9;
  return response;
}

double getReqCperDay(
    {required double bmr,
    required double energyPAL,
    required double exercise,
    required double stress}) {
  double response = 0;
  double totalIdealCal = bmr + (energyPAL + exercise - stress) / 2;

  response = 57.5 * totalIdealCal / 100 / 4;
  return response;
}

double transCalSymbrol2Num(String v) {
  String d = v.replaceAll(RegExp(r'\[|\]|\(|\)|\-|T|r'), "");
  if (d.isEmpty) {
    return 0.0;
  } else {
    return double.parse(d);
  }
}

List<String> stringToList(String listAsString) {
  List<String> response = [];
  List<String> src = listAsString.split(',').toList();
  src.removeWhere((item) => item == "");
  src.forEach((element) {
    response.add(element.trim());
  });
  return response;
}

String hiraganaToKatakana(val) {
  return val.replaceAllMapped(RegExp("[ぁ-ゔ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
}

String katakanaToHiragana(val) {
  return val.replaceAllMapped(RegExp("[ァ-ヴ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
}

DateTime int2Date(int value) {
  int _year = int.parse(value.toString().substring(0, 4));
  int _month = int.parse(value.toString().substring(4, 6));
  int _day = int.parse(value.toString().substring(6));

  return DateTime.utc(_year, _month, _day);
}

int getIntToday() {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyyMMdd');
  String date = outputFormat.format(now);
  return int.parse(date);
}

int transDate2Int(DateTime d) {
  String formattedDate = DateFormat('yyyy/MM/dd').format(d);
  return int.parse(formattedDate.replaceAll("/", ""));
}

DateTime transString2Date(String v) {
  return DateFormat('yyyy/MM/dd').parse(v);
}

int getAge(int value) {
  double response = 0;

  DateTime birth = int2Date(value);
  response = DateTime.now().difference(birth).inDays.toDouble();
  response = response / 365;

  return response.toInt();
}

Future<void> customSnackBar({required String content}) {
  return Fluttertoast.showToast(
    msg: content,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 3,
    backgroundColor: AppParts.char_sub_Color,
    textColor: AppParts.backColor,
  );
}

Future<List<List>> csvImport(url) async {
  List<List> importList = [];
  String rawStr = await rootBundle.loadString(url);
  Iterable<String> list = LineSplitter.split(rawStr);

  bool isFirst = true;
  list.forEach((line) {
    if (line.isNotEmpty) {
      if (isFirst) {
        isFirst = false;
      } else {
        importList.add(line.split(','));
      }
    }
  });

  return Future<List<List>>.value(importList);
}

Color getMainColor(BuildContext context) {
  Color response = AppParts.colorList.values.toList()[AppParts.mainColor];
  MainProvider mainProvider = context.read<MainProvider>();
  if (mainProvider.myself.length > 1) {
    response =
        AppParts.colorList.values.toList()[mainProvider.myself['mainColor']];
  }
  return response;
}

class AppParts {
  static const mainColor = 12;
  static const backColor = Colors.white;
  static const charColor = Colors.black;
  static const char_sub_Color = Color.fromARGB(255, 157, 157, 157);

  static getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    return version;
  }

  static Map<String, Color> colorList = {
    'pink': Colors.pink,
    'red': Colors.red,
    'orange': Colors.orange,
    'amber': Colors.amber,
    //'yellow': Colors.yellow,
    'lime': Colors.lime,
    'lightGreen': Colors.lightGreen,
    'green': Colors.green,
    'teal': Colors.teal,
    'cyan': Colors.cyan,
    'lightBlue': Colors.lightBlue,
    'blue': Colors.blue,
    'indigo': Colors.indigo,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'blueGrey': Colors.blueGrey,
    'brown': Colors.brown,
    'grey': Colors.grey,
  };

  static final List<String> emoji_list = [
    //Android
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😇',
    '😉',
    '😊',
    '🙂',
    '🙃',
    '☺',
    '😋',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '🥲',
    '🤪',
    '😜',
    '😝',
    '😛',
    '🤑',
    '😎',
    '🤓',
    '🥸',
    '🧐',
    '🤠',
    '🥳',
    '🤡',
    '😏',
    '😶',
    '🫥',
    '😐',
    '🫤',
    '😑',
    '😒',
    '🙄',
    '🤨',
    '🤔',
    '🤫',
    '🤭',
    '🫢',
    '🫡',
    '🤗',
    '🫣',
    '🤥',
    '😳',
    '😞',
    '😟',
    '😤',
    '😠',
    '😡',
    '🤬',
    '😔',
    '😕',
    '🙁',
    '☹',
    '😬',
    '🥺',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥱',
    '😪',
    '😮‍💨',
    '😮',
    '😱',
    '😨',
    '😰',
    '😥',
    '😓',
    '😯',
    '😦',
    '😧',
    '🥹',
    '😢',
    '😭',
    '🤤',
    '🤩',
    '😵',
    '😵‍💫',
    '🥴',
    '😲',
    '🤯',
    '🫠',
    '🤐',
    '😷',
    '🤕',
    '🤒',
    '🤮',
    '🤢',
    '🤧',
    '🥵',
    '🥶',
    '😶‍🌫️',
    '😴',
    '💤',
    '😈',
    '👿',
    '👹',
    '👺',
    '💩',
    '👻',
    '💀',
    '☠',
    '👽',
    '🤖',
    '🎃',
    '😺',
    '😸',
    '😹',
    '😻',
    '😼',
    '😽',
    '🙀',
    '😿',
    '😾',
    '🫶',
    '👐',
    '🤲',
    '🙌',
    '👏',
    '🙏',
    '🤝',
    '👍',
    '👎',
    '👊',
    '✊',
    '🤛',
    '🤜',
    '🤞',
    '✌',
    '🫰',
    '🤘',
    '🤟',
    '👌',
    '🤌',
    '🤏',
    '👈',
    '🫳',
    '🫴',
    '👉',
    '👆',
    '👇',
    '☝',
    '✋',
    '🤚',
    '🖐',
    '🖖',
    '👋',
    '🤙',
    '🫲',
    '🫱',
    '💪',
    '🦾',
    '🖕',
    '🫵',
    '✍',
    '🤳',
    '💅',
    '🦵',
    '🦿',
    '🦶',
    '👄',
    '🫦',
    '🦷',
    '👅',
    '👂',
    '🦻',
    '👃',
    '👁',
    '👀',
    '🧠',
    '🫀',
    '🫁',
    '🦴',
    '👤',
    '👥',
    '🗣',
    '🫂',
    '👶',
    '👧',
    '🧒',
    '👦',
    '👩',
    '🧑',
    '👨',
    '👩‍🦱',
    '🧑‍🦱',
    '👨‍🦱',
    '👩‍🦰',
    '🧑‍🦰',
    '👨‍🦰',
    '👱‍♀️',
    '👱',
    '👱‍♂️',
    '👩‍🦳',
    '🧑‍🦳',
    '👨‍🦳',
    '👩‍🦲',
    '🧑‍🦲',
    '👨‍🦲',
    '🧔‍♀️',
    '🧔',
    '🧔‍♂️',
    '👵',
    '🧓',
    '👴',
    '👲',
    '👳‍♀️',
    '👳',
    '👳‍♂️',
    '🧕',
    '👼',
    '👸',
    '🫅',
    '🤴',
    '👰',
    '👰‍♀️',
    '👰‍♂️',
    '🤵‍♀️',
    '🤵',
    '🤵‍♂️',
    '🙇‍♀️',
    '🙇',
    '🙇‍♂️',
    '💁‍♀️',
    '💁',
    '💁‍♂️',
    '🙅‍♀️',
    '🙅',
    '🙅‍♂️',
    '🙆‍♀️',
    '🙆',
    '🙆‍♂️',
    '🤷‍♀️',
    '🤷',
    '🤷‍♂️',
    '🙋‍♀️',
    '🙋',
    '🙋‍♂️',
    '🤦‍♀️',
    '🤦',
    '🤦‍♂️',
    '🧏‍♀️',
    '🧏',
    '🧏‍♂️',
    '🙎‍♀️',
    '🙎',
    '🙎‍♂️',
    '🙍‍♀️',
    '🙍',
    '🙍‍♂️',
    '💇‍♀️',
    '💇',
    '💇‍♂️',
    '💆‍♀️',
    '💆',
    '💆‍♂️',
    '🤰',
    '🫄',
    '🫃',
    '🤱',
    '👩‍🍼',
    '🧑‍🍼',
    '👨‍🍼',
    '🧎‍♀️',
    '🧎',
    '🧎‍♂️',
    '🧍‍♀️',
    '🧍',
    '🧍‍♂️',
    '💃',
    '🕺',
    '👫',
    '👭',
    '👬',
    '🧑‍🤝‍🧑',
    '👩‍❤️‍👨',
    '👩‍❤️‍👩',
    '💑',
    '👨‍❤️‍👨',
    '👩‍❤️‍💋‍👨',
    '👩‍❤️‍💋‍👩',
    '💏',
    '👨‍❤️‍💋‍👨',
    '❤',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🤎',
    '🖤',
    '🤍',
    '💔',
    '❣',
    '💕',
    '💞',
    '💓',
    '💗',
    '💖',
    '💘',
    '💝',
    '❤️‍🔥',
    '❤️‍🩹',
    '💟',
    //iphone
    '😄',
    '😃',
    '😀',
    '😊',
    '☺',
    '😉',
    '😍',
    '😘',
    '😚',
    '😗',
    '😙',
    '😜',
    '😝',
    '😛',
    '😳',
    '😁',
    '😔',
    '😌',
    '😒',
    '😞',
    '😣',
    '😢',
    '😂',
    '😭',
    '😪',
    '😥',
    '😰',
    '😅',
    '😓',
    '😩',
    '😫',
    '😨',
    '😱',
    '😠',
    '😡',
    '😤',
    '😖',
    '😆',
    '😋',
    '😷',
    '😎',
    '😴',
    '😵',
    '😲',
    '😟',
    '😦',
    '😧',
    '😈',
    '👿',
    '😮',
    '😬',
    '😐',
    '😕',
    '😯',
    '😶',
    '😇',
    '😏',
    '😑',
    '👲',
    '👳',
    '👮',
    '👷',
    '💂',
    '👶',
    '👦',
    '👧',
    '👨',
    '👩',
    '👴',
    '👵',
    '👱',
    '👼',
    '👸',
    '😺',
    '😸',
    '😻',
    '😽',
    '😼',
    '🙀',
    '😿',
    '😹',
    '😾',
    '👹',
    '👺',
    '🙈',
    '🙉',
    '🙊',
    '💀',
    '👽',
    '💩',
    '🔥',
    '✨',
    '🌟',
    '💫',
    '💥',
    '💢',
    '💦',
    '💧',
    '💤',
    '💨',
    '👂',
    '👀',
    '👃',
    '👅',
    '👄',
    '👍',
    '👎',
    '👌',
    '👊',
    '✊',
    '✌',
    '👋',
    '✋',
    '👐',
    '👆',
    '👇',
    '👉',
    '👈',
    '🙌',
    '🙏',
    '☝',
    '👏',
    '💪',
    '🚶',
    '🏃',
    '💃',
    '👫',
    '👪',
    '👬',
    '👭',
    '💏',
    '💑',
    '👯',
    '🙆',
    '🙅',
    '💁',
    '🙋',
    '💆',
    '💇',
    '💅',
    '👰',
    '🙎',
    '🙍',
    '🙇',
    '🎩',
    '👑',
    '👒',
    '👟',
    '👞',
    '👡',
    '👠',
    '👢',
    '👕',
    '👔',
    '👚',
    '👗',
    '🎽',
    '👖',
    '👘',
    '👙',
    '💼',
    '👜',
    '👝',
    '👛',
    '👓',
    '🎀',
    '🌂',
    '💄',
    '💛',
    '💙',
    '💜',
    '💚',
    '❤',
    '💔',
    '💗',
    '💓',
    '💕',
    '💖',
    '💞',
    '💘',
    '💌',
    '💋',
    '💍',
    '💎',
    '👤',
    '👥',
    '💬',
    '👣',
    '💭',
  ];

  static Map<String, String> option_list_jp = {
    'weight': '体重(kg)',
    'breakfast': '朝食',
    'lunch': '昼食',
    'dinner': '夕食',
    'exercise': '運動'
  };
  static const Map<String, String> listValues = {
    'num': '数値',
    'yn': '◯, x',
    "search_food": '食品検索',
    "search_exercise": '運動検索'
  };

//'1': '生活の大部分が座位で、静的な活動が中心の場合',
//'2': '座位中心の仕事だが、職場内での移動や立位での作業・接客等、通勤・買い物での歩行、家事、軽いスポーツ、のいずれかを含む場合',
//'3': '移動や立位の多い仕事への従事者、あるいは、スポーツ等余暇における活発な運動習慣を持っている場合',
  static Map<String, String> palList = {
    '1': 'ほとんど座って生活している',
    '2': '大半は座って過ごしますが、買い物や移動で出歩くことがある',
    '3': '立って過ごすことが多かったり、出歩くことが多い生活をしている',
  };

// 体重の標準的な内訳は、体脂肪が約75％、除脂肪体重が約25％(水分20％＋たんぱく質5％)となります。
// 脂肪1gを燃やすのに9.45kcalで、たんぱく質1gを燃やすのにが4.35kcal(利用可能値)
// 従って、体重1㎏を燃やすのに
// 9.45×1000×0.75＋4.35×1000×0.05＝7305
  static Map<String, String> stressList = {
    '244': '1ヶ月に1kg痩せる',
    '487': '1ヶ月に2kg痩せる',
    // '731': '1ヶ月に3kg痩せる',
    // '1000': '1ヶ月に4kg痩せる',
  };

  static const Map<String, String> iconList = {
    'blue':
        "https://firebasestorage.googleapis.com/v0/b/group-diet.appspot.com/o/icon%2Ficon_brue.PNG?alt=media&token=07217cff-ddb6-4685-9e76-5912808cc780",
    'pink':
        "https://firebasestorage.googleapis.com/v0/b/group-diet.appspot.com/o/icon%2Ficon_pink.PNG?alt=media&token=7a2fcc0f-6319-4bb5-80f5-04b49eb1f1a3",
    'yellow':
        "https://firebasestorage.googleapis.com/v0/b/group-diet.appspot.com/o/icon%2Ficon_yellow.PNG?alt=media&token=461a78e0-82f6-428a-bb12-3b71f30e391d"
  };

  static const Map<String, String> listSex = {
    'man': '男性',
    'woman': '女性',
  };

  static const Map<String, Widget> listValuesYN = {
    'yes': Icon(Icons.check, color: Colors.green),
    'no': Icon(
      Icons.clear,
      color: Colors.red,
    ),
  };

  static Container loadingImage = Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
        Colors.orange,
      )));
}
