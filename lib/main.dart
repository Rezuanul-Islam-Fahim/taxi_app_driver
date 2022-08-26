import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/map_provider.dart';
import 'screens/login_signup_screen.dart';
import 'screens/map_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TaxiAppDriver());
}

class TaxiAppDriver extends StatelessWidget {
  const TaxiAppDriver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: MapProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Taxi App Driver',
        initialRoute: OnboardingScreen.route,
        theme: theme,
        routes: {
          OnboardingScreen.route: (_) => const OnboardingScreen(),
          LoginSignupScreen.route: (_) => const LoginSignupScreen(),
          MapScreen.route: (_) => const MapScreen(),
        },
      ),
    );
  }
}
