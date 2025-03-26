import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/theme_provider.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 테마 모드
    final currentThemeMode = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // 테마 설정 섹션
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '화면 테마',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 시스템 테마 사용
          RadioListTile<ThemeMode>(
            title: const Text('시스템 설정 사용'),
            subtitle: const Text('시스템의 다크모드 설정을 따릅니다'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
            },
          ),
          
          // 라이트 모드
          RadioListTile<ThemeMode>(
            title: const Text('라이트 모드'),
            subtitle: const Text('항상 밝은 테마를 사용합니다'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
            },
          ),
          
          // 다크 모드
          RadioListTile<ThemeMode>(
            title: const Text('다크 모드'),
            subtitle: const Text('항상 어두운 테마를 사용합니다'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
            },
          ),
          
          const Divider(),
          
          // 추후 다른 설정들을 위한 공간
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '버전 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 앱 버전 정보
          ListTile(
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
} 