import 'package:flutter/material.dart';
// Import màn hình chào (Splash Screen)
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech-Events Hub', // Tên hiển thị của App
      debugShowCheckedModeBanner: false, // Tắt dải băng DEBUG
      theme: ThemeData(
        // Thiết lập tông màu chủ đạo là màu tím
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Cấu hình App Bar mặc định cho đẹp
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      // Màn hình khởi động là SplashScreen
      // (Logic chuyển trang nằm trong file screens/splash_screen.dart)
      home: const SplashScreen(),
    );
  }
}