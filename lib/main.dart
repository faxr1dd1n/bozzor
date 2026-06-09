import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bozzor.uz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade900),
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _showSplash = true;
  bool _isHidingSplash = false;
  late final DateTime _splashMinVisibleUntil;
  late final AnimationController _splashController;
  late final Animation<double> _splashScaleAnimation;
  late final Animation<double> _splashFadeAnimation;

  @override
  void initState() {
    super.initState();
    _splashMinVisibleUntil = DateTime.now().add(const Duration(seconds: 2));
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _splashScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutBack),
    );
    _splashFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeIn),
    );
    _splashController.forward();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _hideSplashAfterMinimumDuration();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://bozzor.uz'));
  }

  Future<void> _hideSplashAfterMinimumDuration() async {
    if (!_showSplash || _isHidingSplash) return;
    _isHidingSplash = true;

    final remaining = _splashMinVisibleUntil.difference(DateTime.now());
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    setState(() {
      _showSplash = false;
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            minimum: const EdgeInsets.only(bottom: 10),
            child: WebViewWidget(controller: _controller),
          ),
          if (_showSplash)
            Container(
              color: Colors.white,
              child: Center(
                child: AnimatedBuilder(
                  animation: _splashController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _splashScaleAnimation.value,
                      child: Opacity(
                        opacity: _splashFadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/bozzor.jpg',
                    width: 240,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
