import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:todotools/widgets/task_list.dart';
import 'package:todotools/widgets/add_task_dialog.dart';
import 'package:todotools/screens/pomodoro_screen.dart';
import 'package:todotools/screens/matrix_content.dart';
import 'package:todotools/screens/calculator_screen.dart';
import 'package:todotools/screens/calendar_screen.dart';
import 'package:todotools/screens/app_settings_screen.dart';
import 'package:todotools/screens/sticky_notes_screen.dart';

// 메뉴 확장 상태를 위한 프로바이더
final todoMenuExpandedProvider = StateProvider<bool>((ref) => true);
final productivityMenuExpandedProvider = StateProvider<bool>((ref) => false);

// 현재 선택된 메뉴 항목을 위한 프로바이더
final selectedMenuProvider = StateProvider<MenuType>((ref) => MenuType.tasks);

// 메뉴 타입 enum
enum MenuType {
  tasks,
  matrix,
  calendar,
  pomodoro,
  calculator,
  stickyNotes,
}

// 앱의 메인 화면
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 필터 상태 가져오기
    final showTodayOnly = ref.watch(showTodayOnlyProvider);
    final showPinned = ref.watch(showPinnedOnlyProvider);
    final isTodoMenuExpanded = ref.watch(todoMenuExpandedProvider);
    final selectedMenu = ref.watch(selectedMenuProvider);

    return Scaffold(
      body: Row(
        children: [
          // 사이드바 메뉴
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // 앱 제목
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'TodoTools',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                
                // TO-DO 상위 메뉴 (토글 가능)
                ListTile(
                  leading: const Icon(Icons.checklist),
                  title: const Text('TO-DO', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Icon(
                    isTodoMenuExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    ref.read(todoMenuExpandedProvider.notifier).state = !isTodoMenuExpanded;
                  },
                ),
                
                // 하위 메뉴들 (토글에 따라 보이거나 숨김)
                if (isTodoMenuExpanded) ...[
                  // 모든 할 일 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.task_alt,
                        size: 20,
                      ),
                      title: const Text(
                        '모든 할 일',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: !showTodayOnly && !showPinned && selectedMenu == MenuType.tasks,
                      onTap: () {
                        ref.read(showTodayOnlyProvider.notifier).state = false;
                        ref.read(showPinnedOnlyProvider.notifier).state = false;
                        ref.read(selectedMenuProvider.notifier).state = MenuType.tasks;
                      },
                    ),
                  ),
                  // 오늘 할 일 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        size: 20,
                      ),
                      title: const Text(
                        '오늘',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: showTodayOnly && selectedMenu == MenuType.tasks,
                      onTap: () {
                        ref.read(showTodayOnlyProvider.notifier).state = true;
                        ref.read(showPinnedOnlyProvider.notifier).state = false;
                        ref.read(selectedMenuProvider.notifier).state = MenuType.tasks;
                      },
                    ),
                  ),
                  // 고정된 할 일 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.push_pin,
                        size: 20,
                      ),
                      title: const Text(
                        '고정됨',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: showPinned && selectedMenu == MenuType.tasks,
                      onTap: () {
                        ref.read(showTodayOnlyProvider.notifier).state = false;
                        ref.read(showPinnedOnlyProvider.notifier).state = true;
                        ref.read(selectedMenuProvider.notifier).state = MenuType.tasks;
                      },
                    ),
                  ),
                ],
                
                // 매트릭스 메뉴
                ListTile(
                  leading: const Icon(Icons.grid_4x4),
                  title: const Text('매트릭스', style: TextStyle(fontWeight: FontWeight.bold)),
                  selected: selectedMenu == MenuType.matrix,
                  onTap: () {
                    ref.read(selectedMenuProvider.notifier).state = MenuType.matrix;
                    // 필터링 상태 초기화
                    ref.read(showTodayOnlyProvider.notifier).state = false;
                    ref.read(showPinnedOnlyProvider.notifier).state = false;
                  },
                ),
                
                // 캘린더 메뉴
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('캘린더', style: TextStyle(fontWeight: FontWeight.bold)),
                  selected: selectedMenu == MenuType.calendar,
                  onTap: () {
                    ref.read(selectedMenuProvider.notifier).state = MenuType.calendar;
                    // 필터링 상태 초기화
                    ref.read(showTodayOnlyProvider.notifier).state = false;
                    ref.read(showPinnedOnlyProvider.notifier).state = false;
                  },
                ),
                
                // 생산성도구 상위 메뉴 (토글 가능)
                ListTile(
                  leading: const Icon(Icons.build_circle_outlined),
                  title: const Text('생산성 도구', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Icon(
                    ref.watch(productivityMenuExpandedProvider) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    ref.read(productivityMenuExpandedProvider.notifier).state = 
                      !ref.read(productivityMenuExpandedProvider);
                  },
                ),
                
                // 생산성도구 하위 메뉴들
                if (ref.watch(productivityMenuExpandedProvider)) ...[
                  // 뽀모도로 타이머 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.timer_outlined,
                        size: 20,
                      ),
                      title: const Text(
                        '뽀모도로 타이머',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: selectedMenu == MenuType.pomodoro,
                      onTap: () {
                        ref.read(selectedMenuProvider.notifier).state = MenuType.pomodoro;
                        // 필터링 상태 초기화
                        ref.read(showTodayOnlyProvider.notifier).state = false;
                        ref.read(showPinnedOnlyProvider.notifier).state = false;
                      },
                    ),
                  ),
                  
                  // 계산기 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.calculate_outlined,
                        size: 20,
                      ),
                      title: const Text(
                        '계산기',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: selectedMenu == MenuType.calculator,
                      onTap: () {
                        ref.read(selectedMenuProvider.notifier).state = MenuType.calculator;
                        // 필터링 상태 초기화
                        ref.read(showTodayOnlyProvider.notifier).state = false;
                        ref.read(showPinnedOnlyProvider.notifier).state = false;
                      },
                    ),
                  ),
                  
                  // 스티커 메모 메뉴
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 2.0, bottom: 2.0),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 20,
                      ),
                      title: const Text(
                        '스티커 메모',
                        style: TextStyle(fontSize: 14),
                      ),
                      selected: selectedMenu == MenuType.stickyNotes,
                      onTap: () {
                        ref.read(selectedMenuProvider.notifier).state = MenuType.stickyNotes;
                        // 필터링 상태 초기화
                        ref.read(showTodayOnlyProvider.notifier).state = false;
                        ref.read(showPinnedOnlyProvider.notifier).state = false;
                      },
                    ),
                  ),
                ],
                const Spacer(),
                // 설정 메뉴
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('설정'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 메인 영역
          Expanded(
            child: Column(
              children: [
                // 검색 및 추가 버튼 영역 (할 일 화면에서만 표시)
                if (selectedMenu == MenuType.tasks)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        // 검색창
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              ref.read(searchQueryProvider.notifier).state = value;
                            },
                            decoration: InputDecoration(
                              hintText: '할 일 검색...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 할 일 추가 버튼
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AddTaskDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                // 선택된 메뉴에 따라 컨텐츠 표시
                Expanded(
                  child: selectedMenu == MenuType.tasks
                      ? const TaskList() // 할 일 목록 화면
                      : selectedMenu == MenuType.matrix
                          ? const MatrixContent() // 아이젠하워 매트릭스 화면
                          : selectedMenu == MenuType.calendar
                              ? const CalendarScreen() // 캘린더 화면
                              : selectedMenu == MenuType.calculator
                                  ? const CalculatorScreen() // 계산기 화면
                                  : selectedMenu == MenuType.stickyNotes
                                      ? const StickyNotesScreen() // 스티커 메모 화면
                                      : const PomodoroContent(), // 뽀모도로 타이머 화면
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 