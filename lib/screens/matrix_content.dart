import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/database/database.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:todotools/database/tables.dart';
import 'package:drift/drift.dart' show Value;

// 드래그 데이터 모델
class MatrixDragData {
  final Task task;
  final String sourceQuadrant;
  
  MatrixDragData(this.task, this.sourceQuadrant);
}

// 아이젠하워 매트릭스 화면
class MatrixContent extends ConsumerWidget {
  const MatrixContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 모든 할 일 목록 가져오기
    final tasksAsync = ref.watch(taskProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        print('매트릭스에서 오류 발생: $error');
        print('스택 트레이스: $stackTrace');
        return Center(
          child: Text('할 일을 불러오는 중 오류가 발생했습니다: $error'),
        );
      },
      data: (tasks) {
        // 중요도 및 마감일 기준으로 할 일 분류
        final Map<String, List<Task>> matrix = _classifyTasks(tasks);
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 매트릭스 제목 및 설명
              const Text(
                '아이젠하워 매트릭스',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '중요도와 긴급도에 따라 할 일을 관리하세요. 항목을 드래그하여 분류를 변경할 수 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // 매트릭스 그리드 (2x2 행렬)
              Expanded(
                child: Column(
                  children: [
                    // 상단 행
                    Expanded(
                      child: Row(
                        children: [
                          // 2사분면: 중요 & 긴급 (왼쪽 상단)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              ref,
                              '중요하고 긴급한 일',
                              matrix['important_urgent'] ?? [],
                              Colors.red.shade300, // 연한 빨강색
                              '지금 바로 처리하세요',
                              'important_urgent',
                              TaskPriority.high,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 1사분면: 중요 & 긴급하지 않음 (오른쪽 상단)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              ref,
                              '중요하지만 긴급하지 않은 일',
                              matrix['important_not_urgent'] ?? [],
                              Colors.orange.shade300, // 연한 주황색
                              '계획을 세워 처리하세요',
                              'important_not_urgent',
                              TaskPriority.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 하단 행
                    Expanded(
                      child: Row(
                        children: [
                          // 3사분면: 중요하지 않음 & 긴급 (왼쪽 하단)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              ref,
                              '중요하지 않지만 긴급한 일',
                              matrix['not_important_urgent'] ?? [],
                              Colors.blue.shade300, // 연한 파랑색
                              '위임하세요',
                              'not_important_urgent',
                              TaskPriority.low,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 4사분면: 중요하지 않음 & 긴급하지 않음 (오른쪽 하단)
                          Expanded(
                            child: _buildQuadrant(
                              context,
                              ref,
                              '중요하지 않고 긴급하지도 않은 일',
                              matrix['not_important_not_urgent'] ?? [],
                              Colors.green.shade300, // 연한 초록색
                              '제거하세요',
                              'not_important_not_urgent',
                              TaskPriority.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 사분면 위젯 빌드
  Widget _buildQuadrant(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Task> tasks,
    Color borderColor,
    String description,
    String quadrantKey,
    String importance,
  ) {
    return DragTarget<MatrixDragData>(
      onAccept: (data) {
        // 드래그된 항목 처리
        if (data.sourceQuadrant != quadrantKey) {
          // 중요도 변경 작업 수행
          
          // 직접 업데이트 로직 구현
          final actions = ref.read(taskActionsProvider);
          final newPriority = importance; // 현재 사분면의 중요도 값 사용
          
          // 작업 업데이트
          final updatedTask = TasksCompanion(
            id: Value(data.task.id),
            title: Value(data.task.title),
            description: Value(data.task.description),
            isCompleted: Value(data.task.isCompleted),
            isPinned: Value(data.task.isPinned),
            createdAt: Value(data.task.createdAt),
            priority: Value(newPriority),
            category: Value(data.task.category),
            dueDate: Value(data.task.dueDate),
          );
          
          // 데이터베이스 업데이트
          actions.updateTask(updatedTask);
          
          // 사분면 별 중요도 매핑 표시
          String priorityInfo = '';
          if (newPriority == TaskPriority.high) {
            priorityInfo = '높음';
          } else if (newPriority == TaskPriority.medium) {
            priorityInfo = '중간';
          } else if (newPriority == TaskPriority.low) {
            priorityInfo = '낮음';
          } else {
            priorityInfo = '선택안함';
          }
          
          // 변경 내용 알림
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('\'${data.task.title}\' 항목의 중요도가 \'$priorityInfo\'으로 변경되었습니다'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      // 드롭 타겟 상태에 따른 UI
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : borderColor,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // 할 일 목록
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          '이 영역에 할 일이 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildDraggableTaskItem(context, task, quadrantKey);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 드래그 가능한 할 일 항목 위젯
  Widget _buildDraggableTaskItem(BuildContext context, Task task, String quadrantKey) {
    return Draggable<MatrixDragData>(
      // 드래그할 데이터
      data: MatrixDragData(task, quadrantKey),
      // 드래그 시 보이는 피드백 위젯
      feedback: Material(
        elevation: 4,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: ListTile(
            title: Text(
              task.title,
              style: const TextStyle(fontSize: 14),
            ),
            dense: true,
          ),
        ),
      ),
      // 드래그 중 원래 위치에 표시되는 위젯
      childWhenDragging: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Card(
          color: Colors.grey.shade200,
          child: ListTile(
            title: Text(
              task.title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
            dense: true,
          ),
        ),
      ),
      // 일반 상태의 위젯
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(
            task.title,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  '마감일: ${task.dueDate!.year}년 ${task.dueDate!.month}월 ${task.dueDate!.day}일',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          dense: true,
          leading: task.isPinned
              ? const Icon(Icons.push_pin, size: 16)
              : null,
          trailing: _getPriorityIcon(task.priority),
        ),
      ),
    );
  }
  
  // 중요도에 따른 아이콘 표시
  Widget? _getPriorityIcon(String? priority) {
    if (priority == null || priority == TaskPriority.none) return null;
    
    switch (priority) {
      case TaskPriority.high:
        return const Icon(Icons.priority_high, color: Colors.red, size: 16);
      case TaskPriority.medium:
        return const Icon(Icons.trending_up, color: Colors.orange, size: 16);
      case TaskPriority.low:
        return const Icon(Icons.trending_down, color: Colors.blue, size: 16);
      default:
        return null;
    }
  }
  
  // 중요도와 긴급도에 따라 할 일 분류
  Map<String, List<Task>> _classifyTasks(List<Task> tasks) {
    // 각 사분면별 태스크 목록
    final Map<String, List<Task>> result = {
      'important_urgent': [],         // 2사분면: 중요 & 긴급 (높음)
      'important_not_urgent': [],     // 1사분면: 중요 & 긴급하지 않음 (중간)
      'not_important_urgent': [],     // 3사분면: 중요하지 않음 & 긴급 (낮음)
      'not_important_not_urgent': [], // 4사분면: 중요하지 않음 & 긴급하지 않음 (없음)
    };
    
    for (final task in tasks) {
      // 이미 완료된 작업은 건너뜀
      if (task.isCompleted) continue;
      
      // 중요도에 따라 분류
      if (task.priority == TaskPriority.high) {
        // 2사분면: 중요 & 긴급 (높음)
        result['important_urgent']!.add(task);
      } else if (task.priority == TaskPriority.medium) {
        // 1사분면: 중요 & 긴급하지 않음 (중간)
        result['important_not_urgent']!.add(task);
      } else if (task.priority == TaskPriority.low) {
        // 3사분면: 중요하지 않음 & 긴급 (낮음)
        result['not_important_urgent']!.add(task);
      } else {
        // 4사분면: 중요하지 않음 & 긴급하지 않음 (없음)
        result['not_important_not_urgent']!.add(task);
      }
    }
    
    return result;
  }
} 