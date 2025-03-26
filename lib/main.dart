import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/screens/home_screen.dart';
import 'package:todotools/providers/theme_provider.dart';

// 앱의 진입점
void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱 실행
  runApp(
    // Riverpod 프로바이더 설정
    const ProviderScope(
      child: TodoApp(),
    ),
  );
}

// 앱의 기본 설정 및 테마
class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 테마 모드 가져오기
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'TodoTools',
      // 라이트 테마 설정
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // 다크 테마 설정
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // 테마 모드 프로바이더에서 가져오기
      themeMode: themeMode,
      // 홈 화면 설정
      home: const HomeScreen(),
      // 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,
    );
  }
}
