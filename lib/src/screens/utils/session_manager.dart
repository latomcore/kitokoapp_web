import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kitokopay/src/screens/auth/login.dart';

class GlobalSessionManager with WidgetsBindingObserver {
  static final GlobalSessionManager _instance =
      GlobalSessionManager._internal();
  factory GlobalSessionManager() => _instance;
  GlobalSessionManager._internal();

  Timer? _inactivityTimer;
  final Duration _timeoutDuration = const Duration(minutes: 5);
  DateTime? _lastActivityTime;
  BuildContext? _appContext; // Store BuildContext for use in lifecycle methods

  void startMonitoring(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    _appContext = context; // Save context
    _resetTimer(context);
  }

  void stopMonitoring() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  void updateActivity(BuildContext context) {
    _lastActivityTime = DateTime.now();
    _resetTimer(context);
  }

  void _resetTimer(BuildContext context) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeoutDuration, () {
      _handleSessionTimeout(context);
    });
  }

  void _handleSessionTimeout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _inactivityTimer?.cancel(); // Stop timer when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      if (_appContext != null) {
        _resetTimer(_appContext!); // Use stored context when app resumes
      }
    }
  }
}
