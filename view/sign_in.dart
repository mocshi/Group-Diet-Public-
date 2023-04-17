import 'package:flutter/material.dart';
import 'package:group_diet/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/google_auth.dart';
import '../utils/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppParts.backColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: FutureBuilder(
            future: Authentication.initializeFirebase(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error initializing Authentication');
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == null) {
                return Column(mainAxisSize: MainAxisSize.max, children: [
                  Row(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Image.asset(
                            'lib/assets/appicon.png',
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Group',
                          style: TextStyle(
                            color: AppParts.charColor,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Diet',
                          style: TextStyle(
                            color: AppParts.charColor,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // const Expanded(child: SizedBox()),
                  GoogleSignInButton(),
                  SizedBox(
                    height: 45,
                    child: Image.asset(
                      'lib/assets/branding.png',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FutureBuilder(
                        future: AppParts.getAppVersion(),
                        builder: (context, snapshot) {
                          return Text(
                            "Version: ${snapshot.data.toString()}",
                            style: const TextStyle(
                                color: AppParts.charColor, fontSize: 15),
                          );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 70,
                          child: IconButton(
                              onPressed: () {
                                final url = Uri.parse(
                                    'https://nice713.notion.site/2eb67663bb064533bd426ed989f20c9e');
                                launchUrl(url);
                              },
                              icon: const Text(
                                "利用規約",
                                style: TextStyle(fontSize: 13),
                              ))),
                      SizedBox(
                          width: 150,
                          child: IconButton(
                              onPressed: () {
                                final url = Uri.parse(
                                    'https://nice713.notion.site/9c96dcbb34394c30991e3036408eae80');
                                launchUrl(url);
                              },
                              icon: const Text("プライバシーポリシー",
                                  style: TextStyle(fontSize: 13)))),
                    ],
                  ),
                  const SizedBox(height: 20),
                ]);
              } else {
                return AppParts.loadingImage;
              }
            },
          ),
        ),
      ),
    );
  }
}
