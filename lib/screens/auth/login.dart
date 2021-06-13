import '../../services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loader = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(
                flex: 4,
                fit: FlexFit.tight,
                // child: Lottie.asset('assets/lottie/auth.json'),
                child: Padding(
                  padding: EdgeInsets.only(left: 84.0, top: 96, right: 84),
                  child: Image(image: AssetImage('assets/images/swaasthy.png')),
                )),
            const Text(
              'Swaasthy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'The health assistant you deserve',
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.height * 0.065,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    loader = true;
                  });
                  Authentication.signInWithGoogle();
                  // .then((value) {
                  //   if (value != null)
                  //     Navigator.pushNamedAndRemoveUntil(
                  //         context, CodeRedRoutes.home, (route) => false);
                  // }).onError((error, stackTrace) {
                  //   setState(() {
                  //     loader = false;
                  //   });
                  // });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => CodeRedColors.primary,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (loader) ...[
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    ] else ...[
                      Image.network(
                        'https://img.icons8.com/ios-filled/50/000000/google-logo.png',
                        // color: Colors.red,
                        color: Colors.white,
                        height: 30,
                        width: 30,
                      ),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              '© Swaasthy solutions 2021.',
            ),
            const Text(
              'Powered by ❤ from community',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
