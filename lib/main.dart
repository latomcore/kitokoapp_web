import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kitokopay/src/screens/auth/login.dart';
import 'package:kitokopay/src/screens/auth/otp.dart';
import 'package:kitokopay/src/screens/ui/home.dart';
import 'package:kitokopay/src/screens/ui/loans.dart';
import 'package:kitokopay/src/screens/ui/payments.dart';
import 'package:kitokopay/src/screens/ui/remittance.dart';
import 'package:kitokopay/src/screens/splash/splash_screen.dart';
import 'package:kitokopay/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress widget inspector errors in Flutter web debug mode
  // This is a known issue with Flutter web's debug inspector
  if (kDebugMode) {
    debugPrint('⚠️ Running in debug mode. Widget inspector errors may appear but are harmless.');
  }

  // Validate and print configuration (async)
  await AppConfig.validate();
  await AppConfig.printConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set your base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(), // Splash screen (fetches PUBLIC_KEY)
            '/otp': (context) => const OtpPage(), // OTP
            '/home': (context) => const HomeScreen(), // Home screen
            '/payments': (context) => const PaymentPage(), // Payments screen
            '/loans': (context) => const LoansPage(), // Loans screen
            '/remittance': (context) =>
                const RemittancePage(), // Remittance screen
          },
        );
      },
    );
  }
}
