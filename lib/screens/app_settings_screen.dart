import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todotools/database/database.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  // DB 파일 경로 가져오기 (database.dart의 함수 사용)
  Future<String> _getDbPath() async {
    return getDatabasePath(); // 기존 로직 대신 database.dart의 함수 사용
  }

  // 데이터 내보내기
  Future<void> _exportData(BuildContext context) async {
    try {
      final String dbPath = await _getDbPath();
      if (dbPath.isEmpty) {
        _showSnackBar(context, '데이터베이스 경로를 찾을 수 없습니다.');
        return;
      }

      // 사용자에게 저장할 파일 경로/이름 선택 받기
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '데이터베이스 파일 내보내기',
        fileName: 'todotools_backup_${DateTime.now().toIso8601String().split('T')[0]}.db',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (outputFile != null) {
        // DB 파일 복사
        final dbFile = File(dbPath);
        if (await dbFile.exists()) {
          await dbFile.copy(outputFile);
          _showSnackBar(context, '데이터를 성공적으로 내보냈습니다.');
        } else {
          _showSnackBar(context, '데이터베이스 파일을 찾을 수 없습니다.');
        }
      }
    } catch (e) {
      developer.log('데이터 내보내기 오류: $e', name: 'AppSettingsScreen');
      _showSnackBar(context, '데이터 내보내기 중 오류가 발생했습니다: $e');
    }
  }

  // 데이터 가져오기
  Future<void> _importData(BuildContext context) async {
    try {
      // 경고 다이얼로그 표시
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              const Text('데이터 가져오기'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ 이 작업은 되돌릴 수 없습니다!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('다음 데이터가 영구적으로 삭제됩니다:'),
              const SizedBox(height: 8),
              const Text('• 모든 뽀모도로 타이머 설정'),
              const Text('• 모든 작업 목록'),
              const Text('• 모든 계산기 기록'),
              const Text('• 모든 스티커 메모'),
              const SizedBox(height: 16),
              const Text(
                '정말로 백업 파일로 데이터를 가져오시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('가져오기'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      // 사용자에게 가져올 DB 파일 선택 받기
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result != null && result.files.single.path != null) {
        final String importFilePath = result.files.single.path!;
        final String targetDbPath = await _getDbPath();

        if (targetDbPath.isEmpty) {
          _showSnackBar(context, '데이터베이스 저장 경로를 설정할 수 없습니다.');
          return;
        }

        // 기존 DB 파일 닫기 (중요: AppDatabase를 싱글톤으로 사용하므로 인스턴스 종료 필요)
        await AppDatabase.instance.close();

        // 선택한 파일로 기존 DB 파일 덮어쓰기
        final importFile = File(importFilePath);
        await importFile.copy(targetDbPath);

        _showSnackBar(context, '데이터를 성공적으로 가져왔습니다. 앱을 다시 시작해주세요.(필수)');
      }
    } catch (e) {
      developer.log('데이터 가져오기 오류: $e', name: 'AppSettingsScreen');
      _showSnackBar(context, '데이터 가져오기 중 오류가 발생했습니다: $e');
    }
  }

  // DB 저장 위치 변경 다이얼로그
  Future<void> _showChangeDbLocationDialog(BuildContext context) async {
    final currentPath = await _getDbPath();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터베이스 저장 위치 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('현재 저장 위치:'),
            const SizedBox(height: 8),
            Text(
              currentPath,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ 경고: 저장 위치를 변경하면 앱을 다시 시작해야 적용됩니다. ' 
              '기존 데이터 백업 후 가져오기 기능을 통해 데이터를 복원할 수 있습니다. ' 
              '잘못된 경로를 설정하면 데이터가 유실될 수 있습니다.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // 먼저 다이얼로그 닫기
              await _changeDbLocation(context);
            },
            child: const Text('위치 변경'),
          ),
        ],
      ),
    );
  }

  // DB 저장 위치 변경 로직
  Future<void> _changeDbLocation(BuildContext context) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '데이터베이스를 저장할 폴더 선택',
      );

      if (selectedDirectory != null) {
        final newDbPath = p.join(selectedDirectory, 'todotools.db');
        
        // 확인 다이얼로그 추가
        final bool? confirmChange = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('저장 위치 확인'),
            content: Text('다음 위치에 데이터베이스를 저장하시겠습니까?\n$newDbPath\n\n앱을 재시작해야 변경사항이 적용됩니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
            ],
          ),
        );

        if (confirmChange == true) {
          await setDatabasePath(newDbPath); // database.dart의 함수 사용
          _showSnackBar(context, '데이터베이스 저장 위치가 변경되었습니다. 앱을 다시 시작하세요.');
        }
      }
    } catch (e) {
      developer.log('DB 위치 변경 오류: $e', name: 'AppSettingsScreen');
      _showSnackBar(context, 'DB 저장 위치 변경 중 오류가 발생했습니다.');
    }
  }

  // 스낵바 표시 헬퍼
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 자동 시작 안내 다이얼로그 표시
  void _showAutoStartHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Windows 시작 시 자동 실행 방법'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('이 앱을 Windows 시작 시 자동으로 실행하려면 다음 단계를 따르세요:'),
              const SizedBox(height: 16),
              const Text('1. 실행 창 열기:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("   키보드에서 'Win' 키 + 'R' 키를 동시에 누릅니다."),
              const SizedBox(height: 8),
              const Text('2. 시작프로그램 폴더 열기:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("   실행 창에 'shell:startup'을 입력하고 Enter 키를 누릅니다."),
              const SizedBox(height: 8),
              const Text('3. 바로 가기 만들기:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('   바탕 화면이나 설치된 폴더에서 TodoTools 실행 파일(.exe)을 찾습니다.'),
              const Text('   실행 파일을 마우스 오른쪽 버튼으로 클릭하고 "바로 가기 만들기"를 선택합니다.'),
              const SizedBox(height: 8),
              const Text('4. 바로 가기 이동:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('   만들어진 바로 가기 파일을 2단계에서 열었던 시작프로그램 폴더로 복사하거나 이동합니다.'),
              const SizedBox(height: 16),
              const Text('이제 다음에 Windows를 시작할 때 앱이 자동으로 실행됩니다.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('닫기'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

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
          
          // 시스템 설정 섹션
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '시스템',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Windows 시작 시 자동 실행 안내 타일
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Windows 시작 시 자동 실행'),
            subtitle: const Text('자동 실행 설정 방법 안내'),
            trailing: IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: '자동 실행 방법 보기',
              onPressed: () => _showAutoStartHelpDialog(context),
            ),
          ),
          
          const Divider(),
          
          // 데이터 관리 섹션
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '데이터 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('데이터베이스 저장 위치'),
            subtitle: FutureBuilder<String>(
              future: _getDbPath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('현재 위치 로딩 중...');
                } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('현재 위치를 가져올 수 없습니다.');
                } else {
                  return Text(snapshot.data!); // 전체 경로 표시
                }
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '저장 위치 변경',
              onPressed: () => _showChangeDbLocationDialog(context),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('데이터 내보내기 (.db)'),
            subtitle: const Text('현재 데이터를 파일로 백업합니다.'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('데이터 가져오기 (.db)'),
            subtitle: const Text('백업 파일에서 데이터를 복원합니다.'),
            onTap: () => _importData(context),
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