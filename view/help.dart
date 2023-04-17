import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HelpPageState();
  }
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: getMainColor(context),
          title: const Text('ヘルプ'),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("メンバーの追加"),
              subtitle: const Text("Member"),
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'lib/assets/help/add_user_AdobeExpress.gif',
                    )),
                const Text("1. [Member]タブにアクセスします。"),
                const Text("2. 画面右下のアイコンをクリックします。"),
                const Text(
                    "3. 「Add Member」ダイアログが表示されます。メンバーになりたいユーザーの個人IDを入力し、メンバーリクエストを送信します。"),
                const Text(
                    "4. メンバーリクエストを受け取ったユーザーは[Member]タブからリクエストの応答を行います。リクエストが承認された場合、メンバーとなります。"),
                const Text(""),
                const Text("※個人IDは次の箇所で確認できます。"),
                const Text("<1>. [Home]タブにアクセスします。"),
                const Text("<2>. 画面左上のアイコンをタップします。"),
                const Text("<3>. アカウント名の下に個人IDが表示されています。クリックすることでコピーできます。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("メンバーの削除"),
              subtitle: const Text("Member"),
              children: const [
                Text("1. [Member]タブにアクセスします。"),
                Text("2. メンバー解除したいユーザーを長押しします。"),
                Text("3. ダイアログが表示されます。<Delete>をクリックします。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("チャット機能"),
              subtitle: const Text("Member"),
              children: const [
                Text("1. [Member]タブにアクセスします。"),
                Text("2. チャットしたいユーザーをタップします。"),
                Text("3. チャットページが表示されます。"),
                Text(""),
                Text(
                    "※チャットページでは一部の絵文字のみ送信できます。対象文字はチャットページの右上のヘルプアイコンからご確認ください。"),
                Text("※チャットは1日に10通まで送ることができます。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("アカウントの設定"),
              subtitle: const Text("Home"),
              children: const [
                Text("1. [Home]タブにアクセスします。"),
                Text("2. 画面左上のアイコンをタップします。"),
                Text("3. ドロワーメニューが表示されます。「アカウント設定」をクリックします。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("記録をつける"),
              subtitle: const Text("Home"),
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'lib/assets/help/add_record_AdobeExpress.gif',
                    )),
                const Text("1. [Home]タブにアクセスします。"),
                const Text("2. 画面右下のアイコンをクリックします。"),
                const Text(
                    "3. 入力ページが表示されます。「体重」、「朝食」、「昼食」、「夕食」、「運動」（＋追加したオプション項目）が表示されます。"),
                const Text("4. 入力したい項目をタップすると入力ダイアログが表示されますので、データを記録します。"),
                const Text(""),
                const Text("※データを記録する日付は入力ページ右下のカレンダーアイコンから変更できます。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("検索"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "食事と運動の入力ダイアログでは、検索バーから登録する対象を検索することができます。登録したい対象をタップし、食事と運動でそれぞれ「食事量(g)」「運動時間(h)」を入力しましょう。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("食事を手動登録"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "検索バーで食事が見つからない場合、手動で食事を設定できます。一度登録することで、以降から検索できるようになります。"),
                Text(""),
                Text("1. 入力ページの「朝食」、「昼食」、「夕食」のいずれかをタップします。"),
                Text("2. 入力ダイアログが表示されます、検索バーの右隣のアイコンをタップします。"),
                Text("3. 手動登録用の入力欄が表示されます。"),
                Text("4. 値を入力し、<ADD>をクリックします。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("基礎代謝について"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "基礎代謝は生命活動を維持するために必要な最低限のエネルギーを指しています。本アプリでは国立健康・栄養研究所の式（Ganpule の式）から算出しています。計算式は以下となります。"),
                Text(""),
                Text(
                    "男性：（0.0481×W＋0.0234×H－0.0138×A－0.4235）×1,000/4.186\n女性：（0.0481×W＋0.0234×H－0.0138×A－0.9708）×1,000/4.186"),
                Text(""),
                Text("w: 体重, H: 身長, A: 年齢"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("運動消費について"),
              subtitle: const Text("Home"),
              children: const [
                Text("運動によって消費されたカロリーは該当の運動のメッツ値から算出しています。計算式は以下となります。"),
                Text(""),
                Text("METs　×　体重（kg）　×　時間　×　1.05　＝　消費カロリー（kcal）"),
                Text(""),
                Text("METs: 運動強度の単位で、安静時を1とした時と比較して何倍のエネルギーを消費するかで活動の強度を示したもの"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("活動消費について"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "活動消費は普段の生活で消費されるカロリーを指しています。本アプリは年齢を考慮した身体活動レベル（PAL）から算出しています。"),
                Text(""),
                Text("METs　×　体重（kg）　×　時間　×　1.05　＝　消費カロリー（kcal）"),
                Text(""),
                Text("METs: 運動強度の単位で、安静時を1とした時と比較して何倍のエネルギーを消費するかで活動の強度を示したもの"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("理想カロリーについて"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "体脂肪率を「体脂肪＝75％」「除脂肪体重＝25％(水分20％＋たんぱく質5％)」と仮定して制限すべきカロリーを算出しています。計算式は以下となります。"),
                Text(""),
                Text(
                    "9.45×1000×0.75＋4.35×1000×0.05（＝7305: 1kg痩せるために必要な消費カロリー）/ D × N　＝　制限カロリー（kcal）"),
                Text(""),
                Text(
                    "9.45: 脂肪1gのカロリー, 4.35: たんぱく質1gのカロリー, D: 1kg痩せる期間, N: 期間Dの間に痩せたい体重"),
                Text(""),
                Text(
                    "基礎代謝以下までカロリーを制限するとリバウントや体に悪影響が起こる可能性があるので本アプリでは基礎代謝から制限カロリーの間を理想摂取カロリーとして表示しています。"),
                Text(""),
                Text("例）基礎代謝：1800, 制限カロリー：500, 活動消費：800, 運動消費：200 の場合"),
                Text("理想摂取カロリー（kcal） ＝ 1800 〜 2300（内訳：1800 + 800 + 200 - 500）"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("PFCバランスについて"),
              subtitle: const Text("Home"),
              children: const [
                Text(
                    "PFCはたんぱく質（P）、脂質（F）、炭水化物（C）を指しており、これらは1日の摂取カロリーのうち、たんぱく質＝16.5%, 脂質＝25%, 炭水化物＝57.5%の配分が理想とされています。"),
                Text("本アプリでは以下計算式から理想の摂取すべきグラムを算出しています。"),
                Text(""),
                Text("P(g) ＝ 16.5 * (理想カロリーの平均) / 100 / （たんぱく質1gあたりのカロリー＝４）"),
                Text("F(g) ＝ 25 * (理想カロリーの平均) / 100 / （脂質1gあたりのカロリー＝9）"),
                Text("C(g) ＝ 57.5 * (理想カロリーの平均) / 100 / （炭水化物1gあたりのカロリー＝４）"),
                Text(""),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("日々の記録の確認(カレンダー)"),
              subtitle: const Text("Calendar"),
              children: const [
                Text("1. [Calendar]タブにアクセスします。"),
                Text("2. 画面上部の[カレンダーアイコン]タブにアクセスします。"),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.all(5),
              childrenPadding: const EdgeInsets.all(10),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: const Text("日々の記録の確認(チャート)"),
              subtitle: const Text("Calendar"),
              children: const [
                Text("1. [Calendar]タブにアクセスします。"),
                Text("2. 画面上部の[チャートアイコン]タブにアクセスします。"),
                Text(""),
                Text("※画面下部のカレンダーアイコンから表示するデータの期間を指定できます。"),
              ],
            ),
          ],
        ))));
  }
}
