import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import 'package:group_diet/view/edit_user.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../utils/google_auth.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({required Map<dynamic, dynamic> user}) : _user = user;

  final Map<dynamic, dynamic> _user;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      isTopSafeArea: true,
      pages: [
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.topLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "はじめまして",
          body:
              "本アプリケーションをダウンロードいただきありがとうございます！ダイエット辛いよね、けどみんなでやれば頑張れる！一緒にダイエット成功させよう！",
          image: Image.asset(
            'lib/assets/appicon_white.png',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.centerLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "みんなでダイエット",
          body: "ダイエットの状況を記録し、メンバー間で共有します。お互いに切磋琢磨しよう！\n\n※体重の具体的な値は共有されません",
          image: Image.asset(
            'lib/assets/help/intro1.png',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.centerLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "健康的に痩せよう",
          body:
              "自動で理想の摂取カロリー、PFCバランスが計算されます。健康的に痩せよう！\n\n※PFCバランス：タンパク質、脂質、炭水化物のバランス",
          image: Image.asset(
            'lib/assets/help/intro2.png',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.centerLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "まずはアカウントを作成しよう",
          body: "ダイエットを開始する前にあなたの事を教えてください。取得した情報から摂取カロリー等の計算を行います。",
          image: Image.asset(
            'lib/assets/help/intro3.png',
          ),
        ),
      ],
      skip: const Text("キャンセル", style: TextStyle(fontWeight: FontWeight.bold)),
      next: const Text("次へ", style: TextStyle(fontWeight: FontWeight.bold)),
      done: const Text("完了", style: TextStyle(fontWeight: FontWeight.bold)),
      onSkip: () {
        Authentication.signOut(context: context).then((value) {
          navigateFNC(context);
        });
      },
      showSkipButton: true,
      onDone: () {
        customNavigation(true, context, EditUserPage(user: _user));
      },
    );
  }
}
