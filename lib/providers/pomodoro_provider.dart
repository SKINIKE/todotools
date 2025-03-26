import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:todotools/providers/task_provider.dart';

// 뽀모도로 모드 (집중 / 휴식)
enum PomodoroMode {
  focus,
  rest,
  longRest,
}

// 뽀모도로 설정 Provider
final pomodoroSettingsProvider = FutureProvider<PomodoroSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getPomodoroSettings();
});

// 뽀모도로 타이머 상태
class PomodoroTimerState {
  final int totalSeconds;
  final bool isRunning;
  final PomodoroMode mode;
  final int completedFocusSessions;
  
  const PomodoroTimerState({
    required this.totalSeconds,
    required this.isRunning,
    required this.mode,
    required this.completedFocusSessions,
  });
  
  // 복사 메서드
  PomodoroTimerState copyWith({
    int? totalSeconds,
    bool? isRunning,
    PomodoroMode? mode,
    int? completedFocusSessions,
  }) {
    return PomodoroTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
      completedFocusSessions: completedFocusSessions ?? this.completedFocusSessions,
    );
  }
  
  // 시간 형식으로 변환 (MM:SS)
  String get timeString {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// 뽀모도로 타이머 상태 Provider
final pomodoroTimerProvider = StateNotifierProvider<PomodoroTimerNotifier, PomodoroTimerState>((ref) {
  final settingsAsync = ref.watch(pomodoroSettingsProvider);
  
  // 설정이 로드되기 전에 기본값 사용
  final settings = settingsAsync.value;
  
  return PomodoroTimerNotifier(settings);
});

// 뽀모도로 타이머 Notifier
class PomodoroTimerNotifier extends StateNotifier<PomodoroTimerState> {
  Timer? _timer;
  final PomodoroSetting? _settings;
  
  PomodoroTimerNotifier(this._settings) : super(
    PomodoroTimerState(
      totalSeconds: (_settings?.focusMinutes ?? 25) * 60,
      isRunning: false,
      mode: PomodoroMode.focus,
      completedFocusSessions: 0,
    ),
  );
  
  // 타이머 시작
  void start() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state.totalSeconds > 0) {
          state = state.copyWith(totalSeconds: state.totalSeconds - 1);
        } else {
          // 시간이 다 되면 다음 모드로 전환
          if (state.mode == PomodoroMode.focus) {
            final completedSessions = state.completedFocusSessions + 1;
            state = state.copyWith(completedFocusSessions: completedSessions);
            
            // 긴 휴식 간격에 도달했는지 확인
            if (completedSessions % (_settings?.longRestInterval ?? 4) == 0) {
              _switchToMode(PomodoroMode.longRest);
            } else {
              _switchToMode(PomodoroMode.rest);
            }
          } else {
            // 휴식 시간이 끝나면 다시 집중 모드로
            _switchToMode(PomodoroMode.focus);
          }
          
          // 자동 시작 설정이 켜져 있으면 다음 세션 자동 시작
          if (_settings?.autoStartNextSession ?? false) {
            start();
          }
        }
      },
    );
  }
  
  // 타이머 일시 정지
  void pause() {
    if (!state.isRunning) return;
    
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }
  
  // 타이머 리셋
  void reset() {
    _timer?.cancel();
    
    int seconds;
    switch (state.mode) {
      case PomodoroMode.focus:
        seconds = (_settings?.focusMinutes ?? 25) * 60;
        break;
      case PomodoroMode.rest:
        seconds = (_settings?.restMinutes ?? 5) * 60;
        break;
      case PomodoroMode.longRest:
        seconds = (_settings?.longRestMinutes ?? 15) * 60;
        break;
    }
    
    state = state.copyWith(
      totalSeconds: seconds,
      isRunning: false,
    );
  }
  
  // 모드 전환
  void _switchToMode(PomodoroMode mode) {
    _timer?.cancel();
    
    int seconds;
    switch (mode) {
      case PomodoroMode.focus:
        seconds = (_settings?.focusMinutes ?? 25) * 60;
        break;
      case PomodoroMode.rest:
        seconds = (_settings?.restMinutes ?? 5) * 60;
        break;
      case PomodoroMode.longRest:
        seconds = (_settings?.longRestMinutes ?? 15) * 60;
        break;
    }
    
    state = PomodoroTimerState(
      totalSeconds: seconds,
      isRunning: false,
      mode: mode,
      completedFocusSessions: state.completedFocusSessions,
    );
  }
  
  // 수동으로 모드 전환 (설정 화면에서 사용)
  void toggleMode() {
    if (state.mode == PomodoroMode.focus) {
      _switchToMode(PomodoroMode.rest);
    } else {
      _switchToMode(PomodoroMode.focus);
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// 뽀모도로 설정 변경 액션 클래스
class PomodoroSettingsActions {
  final AppDatabase _db;
  final Ref _ref;
  
  PomodoroSettingsActions(this._db, this._ref);
  
  // 색상 변환 헬퍼 (HEX -> Color)
  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  // 집중 모드 색상
  Color getFocusColor(PomodoroSetting? settings) => 
    hexToColor(settings?.focusColorHex ?? 'FFC8C8');
  
  // 휴식 모드 색상
  Color getRestColor(PomodoroSetting? settings) => 
    hexToColor(settings?.restColorHex ?? 'D1EAC8');
  
  // 설정 업데이트
  Future<void> updateSettings({
    int? focusMinutes,
    int? restMinutes,
    int? longRestMinutes,
    int? longRestInterval,
    bool? autoStartNextSession,
    bool? playSound,
    String? focusColorHex,
    String? restColorHex,
  }) async {
    final settings = (await _db.getPomodoroSettings()) ?? PomodoroSetting(
      id: 1,
      focusMinutes: 25,
      restMinutes: 5,
      longRestMinutes: 15,
      longRestInterval: 4,
      autoStartNextSession: false,
      playSound: true,
      focusColorHex: 'FFC8C8',
      restColorHex: 'D1EAC8',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final updatedSettings = PomodoroSettingsCompanion(
      id: Value(settings.id),
      focusMinutes: focusMinutes != null ? Value(focusMinutes) : Value(settings.focusMinutes),
      restMinutes: restMinutes != null ? Value(restMinutes) : Value(settings.restMinutes),
      longRestMinutes: longRestMinutes != null ? Value(longRestMinutes) : Value(settings.longRestMinutes),
      longRestInterval: longRestInterval != null ? Value(longRestInterval) : Value(settings.longRestInterval),
      autoStartNextSession: autoStartNextSession != null ? Value(autoStartNextSession) : Value(settings.autoStartNextSession),
      playSound: playSound != null ? Value(playSound) : Value(settings.playSound),
      focusColorHex: focusColorHex != null ? Value(focusColorHex) : Value(settings.focusColorHex),
      restColorHex: restColorHex != null ? Value(restColorHex) : Value(settings.restColorHex),
      updatedAt: Value(DateTime.now()),
    );
    
    await _db.updatePomodoroSettings(updatedSettings);
    
    // 프로바이더 갱신
    _ref.refresh(pomodoroSettingsProvider);
  }
  
  // 기본 설정으로 초기화
  Future<void> resetToDefaults() async {
    await _db.resetPomodoroSettings();
    
    // 프로바이더 갱신
    _ref.refresh(pomodoroSettingsProvider);
  }
}

// 뽀모도로 설정 액션 프로바이더
final pomodoroSettingsActionsProvider = Provider<PomodoroSettingsActions>((ref) {
  final db = ref.watch(databaseProvider);
  return PomodoroSettingsActions(db, ref);
}); 