import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/pomodoro_provider.dart';
import 'package:todotools/database/database.dart';

class PomodoroSettingsScreen extends ConsumerWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pomodoroSettingsProvider);
    final settingsActions = ref.read(pomodoroSettingsActionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('뽀모도로 설정'),
        actions: [
          // 기본값으로 초기화 버튼
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('기본 설정으로 초기화'),
                  content: const Text('모든 설정을 기본값으로 초기화하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed: () {
                        settingsActions.resetToDefaults();
                        Navigator.pop(context);
                      },
                      child: const Text('초기화'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('기본값으로 초기화'),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return const Center(child: Text('설정을 불러오는 중 오류가 발생했습니다.'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 집중 시간 설정
                _buildSectionTitle('집중 시간 (분)'),
                const SizedBox(height: 8),
                _buildSlider(
                  value: settings.focusMinutes.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  activeColor: Colors.red.shade300,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      focusMinutes: value.round(),
                    );
                  },
                ),
                _buildValueDisplay(settings.focusMinutes),
                const SizedBox(height: 24),
                
                // 휴식 시간 설정
                _buildSectionTitle('짧은 휴식 시간 (분)'),
                const SizedBox(height: 8),
                _buildSlider(
                  value: settings.restMinutes.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: Colors.green.shade300,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      restMinutes: value.round(),
                    );
                  },
                ),
                _buildValueDisplay(settings.restMinutes),
                const SizedBox(height: 24),
                
                // 긴 휴식 시간 설정
                _buildSectionTitle('긴 휴식 시간 (분)'),
                const SizedBox(height: 8),
                _buildSlider(
                  value: settings.longRestMinutes.toDouble(),
                  min: 5,
                  max: 45,
                  divisions: 8,
                  activeColor: Colors.green.shade500,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      longRestMinutes: value.round(),
                    );
                  },
                ),
                _buildValueDisplay(settings.longRestMinutes),
                const SizedBox(height: 24),
                
                // 긴 휴식 간격 설정
                _buildSectionTitle('긴 휴식 간격 (집중 세션 횟수)'),
                const SizedBox(height: 8),
                _buildSlider(
                  value: settings.longRestInterval.toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  activeColor: Colors.blue.shade300,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      longRestInterval: value.round(),
                    );
                  },
                ),
                _buildValueDisplay(settings.longRestInterval),
                const SizedBox(height: 24),
                
                const Divider(),
                const SizedBox(height: 16),
                
                // 자동 시작 설정
                SwitchListTile(
                  title: const Text('자동 시작', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('세션이 끝나면 다음 세션을 자동으로 시작합니다.'),
                  value: settings.autoStartNextSession,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      autoStartNextSession: value,
                    );
                  },
                  activeColor: Colors.blue.shade300,
                ),
                const SizedBox(height: 16),
                
                // 소리 설정
                SwitchListTile(
                  title: const Text('소리 알림', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('세션이 끝나면 소리로 알립니다.'),
                  value: settings.playSound,
                  onChanged: (value) {
                    settingsActions.updateSettings(
                      playSound: value,
                    );
                  },
                  activeColor: Colors.blue.shade300,
                ),
                const SizedBox(height: 24),
                
                const Divider(),
                const SizedBox(height: 16),
                
                // 색상 설정
                _buildSectionTitle('집중 모드 색상'),
                const SizedBox(height: 16),
                _buildColorPicker(
                  context: context,
                  currentColor: settingsActions.getFocusColor(settings),
                  onColorSelected: (colorHex) {
                    settingsActions.updateSettings(
                      focusColorHex: colorHex,
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('휴식 모드 색상'),
                const SizedBox(height: 16),
                _buildColorPicker(
                  context: context,
                  currentColor: settingsActions.getRestColor(settings),
                  onColorSelected: (colorHex) {
                    settingsActions.updateSettings(
                      restColorHex: colorHex,
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // 설명 섹션
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '뽀모도로 기법이란?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '뽀모도로 기법은 25분 집중, 5분 휴식을 반복하는 시간 관리 방법입니다. '
                        '4회의 집중 세션 후에는 15-30분 정도의 긴 휴식을 취합니다. '
                        '이 방법은 작업 효율성을 높이고 집중력을 향상시키는 데 도움이 됩니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
      ),
    );
  }
  
  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  // 슬라이더 위젯
  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: activeColor,
        thumbColor: activeColor,
        overlayColor: activeColor.withOpacity(0.3),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
  
  // 값 표시 위젯
  Widget _buildValueDisplay(int value) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
  
  // 색상 선택 위젯
  Widget _buildColorPicker({
    required BuildContext context,
    required Color currentColor,
    required Function(String) onColorSelected,
  }) {
    final colors = [
      Colors.red.shade200,
      Colors.pink.shade200,
      Colors.purple.shade200,
      Colors.deepPurple.shade200,
      Colors.indigo.shade200,
      Colors.blue.shade200,
      Colors.lightBlue.shade200,
      Colors.cyan.shade200,
      Colors.teal.shade200,
      Colors.green.shade200,
      Colors.lightGreen.shade200,
      Colors.lime.shade200,
      Colors.yellow.shade200,
      Colors.amber.shade200,
      Colors.orange.shade200,
      Colors.deepOrange.shade200,
      Colors.brown.shade200,
      Colors.grey.shade200,
      Colors.blueGrey.shade200,
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color.value == currentColor.value;
        
        return GestureDetector(
          onTap: () {
            final hexColor = color.value.toRadixString(16).substring(2, 8);
            onColorSelected(hexColor);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.black54)
                : null,
          ),
        );
      }).toList(),
    );
  }
} 