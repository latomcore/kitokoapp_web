import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:kitokopay/src/screens/auth/login.dart';
import 'package:kitokopay/src/screens/auth/otp.dart';
import 'package:kitokopay/src/screens/ui/home.dart';
import 'package:kitokopay/src/screens/ui/loans.dart';
import 'package:kitokopay/src/screens/ui/payments.dart';
import 'package:kitokopay/src/screens/ui/remittance.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized

  // try {
  //   await dotenv.load(fileName: ".env"); // Load environment variables
  // } catch (e) {
  //   debugPrint("Error loading .env file: $e"); // Handle error gracefully
  // }

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
            '/': (context) => const LoginScreen(), // Initial screen
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
