import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen2 extends StatelessWidget {
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
          title: "アカウント作成完了！",
          body: '''アカウントの作成が完了しました！
最後に使い方を簡単にレクチャします''',
          image: Image.asset(
            'lib/assets/appicon_white.png',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.topLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "メンバーを追加",
          body: '''「Home」タブの左上のアイコンをクリックすると個人IDが表示されます、クリックして他の人へ共有しよう。
共有された人は「Member」タブの追加アイコンをクリックし、メンバーの個人IDからメンバーを追加しよう！''',
          image: Image.asset(
            'lib/assets/help/add_user_AdobeExpress.gif',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.topLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "日々の記録",
          body:
              "「Home」タブの編集アイコンをクリックすることで記録ページに移動します。グラフの下にあなたの入力項目が表示されていますので、クリックして記録を入力しましょう。",
          image: Image.asset(
            'lib/assets/help/add_record_AdobeExpress.gif',
          ),
        ),
        PageViewModel(
          decoration: const PageDecoration(
              bodyAlignment: Alignment.centerLeft,
              titlePadding: EdgeInsets.all(10),
              imagePadding: EdgeInsets.all(10),
              bodyPadding: EdgeInsets.all(10)),
          title: "さあ、ダイエット開始です",
          body:
              "ここまでご確認頂きありがとうございます！わからないことがあれば「Home」タブの左上のアイコンからヘルプを確認できます。それではLet's ダイエット！",
          image: Image.asset(
            'lib/assets/appicon_white.png',
          ),
        ),
      ],
      skip: const Text("キャンセル", style: TextStyle(fontWeight: FontWeight.bold)),
      next: const Text("次へ", style: TextStyle(fontWeight: FontWeight.bold)),
      done: const Text("完了", style: TextStyle(fontWeight: FontWeight.bold)),
      onSkip: () {
        navigateFNC(context);
      },
      showSkipButton: true,
      onDone: () {
        navigateFNC(context);
      },
    );
  }
}
