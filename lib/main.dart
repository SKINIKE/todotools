import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/screens/home_screen.dart';
import 'package:todotools/providers/theme_provider.dart';
import 'package:todotools/database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:developer' as developer;

// 앱의 진입점
void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 배포용: 기존 데이터베이스 및 설정 초기화
  await cleanDataForDistribution();
  
  // 앱 실행
  runApp(
    // Riverpod 프로바이더 설정
    const ProviderScope(
      child: TodoApp(),
    ),
  );
}

// 배포용 데이터 초기화 함수
Future<void> cleanDataForDistribution() async {
  try {
    // 1. 데이터베이스 파일 삭제
    final dbPath = await getDatabasePath();
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
      developer.log('기존 데이터베이스 파일 삭제 완료', name: 'distribution');
    }
    
    // 2. SharedPreferences 초기화
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    developer.log('SharedPreferences 초기화 완료', name: 'distribution');
    
    // 3. 임시 파일 삭제
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      developer.log('임시 파일 삭제 완료', name: 'distribution');
    }
    
    developer.log('배포용 데이터 초기화 완료', name: 'distribution');
  } catch (e) {
    developer.log('데이터 초기화 중 오류 발생: $e', name: 'distribution', error: e);
  }
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
