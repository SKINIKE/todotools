import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/pomodoro_provider.dart';
import 'package:todotools/screens/pomodoro_settings_screen.dart';
import 'package:todotools/database/database.dart';

// 홈 화면의 메인 컨텐츠 영역에 표시될 뽀모도로 위젯
class PomodoroContent extends ConsumerWidget {
  const PomodoroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroTimerProvider);
    final settingsAsync = ref.watch(pomodoroSettingsProvider);
    final settingsActions = ref.read(pomodoroSettingsActionsProvider);
    
    return settingsAsync.when(
      data: (settings) {
        // 색상 가져오기
        final focusColor = settingsActions.getFocusColor(settings);
        final restColor = settingsActions.getRestColor(settings);
        
        // 현재 모드에 따른 색상 설정
        final currentColor = pomodoroState.mode == PomodoroMode.focus 
            ? focusColor 
            : restColor;
        
        return Container(
          decoration: BoxDecoration(
            // 선택된 모드에 따라 배경색 변경
            color: currentColor.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 뽀모도로 모드 선택 라디오 버튼
                _buildModeSelector(ref, pomodoroState, focusColor, restColor),
                const SizedBox(height: 30),
                
                // 타이머 표시
                _buildTimerDisplay(ref, pomodoroState, currentColor),
                const SizedBox(height: 10),
                
                // 현재 모드 텍스트 표시
                Text(
                  pomodoroState.mode == PomodoroMode.focus
                      ? '집중 시간'
                      : pomodoroState.mode == PomodoroMode.rest
                          ? '휴식 시간'
                          : '긴 휴식 시간',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                // 완료한 뽀모도로 세션 수
                Text(
                  '완료한 집중 세션: ${pomodoroState.completedFocusSessions}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                
                // 다음 세션 안내
                Text(
                  _getNextSessionText(pomodoroState.mode, settings),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                
                // 타이머 제어 버튼
                _buildTimerControls(ref, pomodoroState, currentColor),
                const SizedBox(height: 30),
                
                // 설정 버튼
                _buildSettingsButton(context),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }
  
  // 모드 선택 라디오 버튼 위젯
  Widget _buildModeSelector(
    WidgetRef ref,
    PomodoroTimerState pomodoroState,
    Color focusColor,
    Color restColor
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 집중 모드 선택 버튼
        Expanded(
          child: RadioListTile<PomodoroMode>(
            title: const Text('집중', textAlign: TextAlign.center),
            value: PomodoroMode.focus,
            groupValue: pomodoroState.mode,
            activeColor: focusColor,
            onChanged: (value) {
              final notifier = ref.read(pomodoroTimerProvider.notifier);
              notifier.toggleMode();
            },
          ),
        ),
        // 휴식 모드 선택 버튼
        Expanded(
          child: RadioListTile<PomodoroMode>(
            title: const Text('휴식', textAlign: TextAlign.center),
            value: PomodoroMode.rest,
            groupValue: pomodoroState.mode,
            activeColor: restColor,
            onChanged: (value) {
              final notifier = ref.read(pomodoroTimerProvider.notifier);
              notifier.toggleMode();
            },
          ),
        ),
      ],
    );
  }
  
  // 타이머 표시 위젯
  Widget _buildTimerDisplay(
    WidgetRef ref,
    PomodoroTimerState pomodoroState,
    Color currentColor
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: currentColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          pomodoroState.timeString,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: currentColor,
          ),
        ),
      ),
    );
  }
  
  // 타이머 제어 버튼 위젯
  Widget _buildTimerControls(
    WidgetRef ref,
    PomodoroTimerState pomodoroState,
    Color currentColor
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 시작/일시정지 버튼
        ElevatedButton.icon(
          onPressed: () {
            final notifier = ref.read(pomodoroTimerProvider.notifier);
            if (pomodoroState.isRunning) {
              notifier.pause();
            } else {
              notifier.start();
            }
          },
          icon: Icon(pomodoroState.isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(pomodoroState.isRunning ? '일시정지' : '시작'),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 리셋 버튼
        ElevatedButton.icon(
          onPressed: () {
            final notifier = ref.read(pomodoroTimerProvider.notifier);
            notifier.reset();
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('리셋'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
  
  // 설정 버튼 위젯
  Widget _buildSettingsButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PomodoroSettingsScreen()),
        );
      },
      icon: const Icon(Icons.settings),
      label: const Text('설정'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
  
  // 다음 세션 안내 텍스트
  String _getNextSessionText(PomodoroMode mode, PomodoroSetting? settings) {
    if (settings == null) return '';
    
    if (mode == PomodoroMode.focus) {
      // 다음 세션이 긴 휴식인지 확인
      if (mode == PomodoroMode.focus) {
        return '다음: ${settings.restMinutes}분 휴식';
      }
      return '다음: ${settings.restMinutes}분 휴식';
    } else {
      return '다음: ${settings.focusMinutes}분 집중';
    }
  }
}

// 전체 화면 뽀모도로 페이지 (현재는 사용하지 않지만 필요할 경우 사용)
class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('뽀모도로 타이머'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PomodoroSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const PomodoroContent(),
    );
  }
} 