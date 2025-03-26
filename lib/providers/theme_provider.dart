import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 테마 모드 저장용 키
const String themePreferenceKey = 'theme_mode';

// 현재 테마 모드를 관리하는 프로바이더
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

// 테마 모드 변경 및 저장을 담당하는 Notifier 클래스
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // 기본값은 시스템 테마 사용
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemePreference();
  }

  // 저장된 테마 설정 불러오기
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(themePreferenceKey);
    
    if (savedTheme != null) {
      state = _getThemeModeFromString(savedTheme);
    }
  }

  // 문자열을 ThemeMode로 변환
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // 테마 모드 변경 및 저장
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await prefs.setString(themePreferenceKey, themeString);
  }
} 