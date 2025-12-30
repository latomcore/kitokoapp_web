import 'package:flutter/material.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:kitokopay/service/secure_storage_service.dart';
import 'package:kitokopay/service/public_key_service.dart';
import 'package:kitokopay/service/api_client_helper_utils.dart';
import 'package:kitokopay/src/screens/auth/login.dart';
import 'package:flutter/foundation.dart';

/// Splash Screen
/// 
/// Displays during app initialization and fetches PUBLIC_KEY from server.
/// Also initializes secure storage with API credentials.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final SecureStorageService _secureStorage = SecureStorageService();
  final PublicKeyService _publicKeyService = PublicKeyService();
  String _statusMessage = 'Initializing...';
  bool _hasError = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for loading dots
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Track start time to ensure minimum display duration
    final startTime = DateTime.now();
    const minimumDisplayDuration = Duration(seconds: 2); // Minimum 2 seconds display

    try {
      // Step 1: Initialize API credentials in secure storage
      setState(() {
        _statusMessage = 'Loading credentials...';
      });

      await _initializeCredentials();

      // Step 2: Fetch PUBLIC_KEY from server
      setState(() {
        _statusMessage = 'Fetching security keys...';
      });

      final publicKey = await _publicKeyService.getPublicKey(forceRefresh: false);

      if (publicKey == null || publicKey.isEmpty) {
        setState(() {
          _hasError = true;
          _statusMessage = 'Failed to load security keys. Please check your connection.';
        });
        
        // Wait a bit before navigating to login (user can retry)
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _navigateToLogin();
        }
        return;
      }

      // Step 3: Initialize PUBLIC_KEY cache in ElmsSSL
      await ElmsSSL.initializePublicKey();

      // Step 4: Success - show ready message
      setState(() {
        _statusMessage = 'Ready!';
      });

      // Calculate remaining time to meet minimum display duration
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime < minimumDisplayDuration) {
        final remainingTime = minimumDisplayDuration - elapsedTime;
        await Future.delayed(remainingTime);
      } else {
        // If already exceeded minimum, add a small transition delay
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during initialization: $e');
      }
      
      setState(() {
        _hasError = true;
        _statusMessage = 'Initialization error. Please try again.';
      });

      // Calculate remaining time to meet minimum display duration
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime < minimumDisplayDuration) {
        final remainingTime = minimumDisplayDuration - elapsedTime;
        await Future.delayed(remainingTime);
      } else {
        // If already exceeded minimum, wait a bit more for error visibility
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// Initialize API credentials in secure storage
  /// 
  /// Stores the confirmed Basic Auth credentials for /load endpoint:
  /// - API_USERNAME: KL0Qw0Vdd
  /// - API_PASSWORD: Db0wU8eRzU3Yz0P3zJ
  Future<void> _initializeCredentials() async {
    try {
      // Use confirmed credentials for Basic Auth on /load endpoint
      const String username = 'KL0Qw0Vdd';
      const String password = 'Db0wU8eRzU3Yz0P3zJ';

      // Always store the confirmed credentials
      await _secureStorage.setApiUsername(username);
      await _secureStorage.setApiPassword(password);

      if (kDebugMode) {
        debugPrint('✅ API credentials initialized in secure storage');
        debugPrint('   Username: $username');
        debugPrint('   Password: ***');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize credentials: $e');
        debugPrint('   Error details: ${e.toString()}');
      }
      rethrow;
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,  // Deep blue (lighter)
              Colors.blue.shade900,  // Navy blue (darker)
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Icon(
                Icons.account_balance,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              
              // App Name
              Text(
                'KitokoPay',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading Indicator with animated dots
              if (!_hasError)
                Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 24),
                    // Animated loading dots
                    _AnimatedLoadingDots(),
                  ],
                ),
              
              if (_hasError)
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 48,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              // Status Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Loading Dots Widget
/// 
/// Displays three dots that animate in sequence to show loading progress
class _AnimatedLoadingDots extends StatefulWidget {
  const _AnimatedLoadingDots();

  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate delay for each dot (0ms, 200ms, 400ms)
            final delay = index * 0.2;
            // Calculate animation value with delay
            final animationValue = (_controller.value + delay) % 1.0;
            // Create bounce effect using sine wave
            final opacity = (0.3 + (0.7 * (0.5 + 0.5 * (1 - (animationValue * 2 - 1).abs()))));
            final scale = 0.8 + (0.4 * (0.5 + 0.5 * (1 - (animationValue * 2 - 1).abs())));
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

