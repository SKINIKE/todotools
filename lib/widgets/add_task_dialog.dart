import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todotools/providers/task_provider.dart';
import 'package:todotools/database/tables.dart';
import 'package:drift/drift.dart' show Value;

// 새로운 할 일을 추가하는 다이얼로그
class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  // 입력 필드 컨트롤러
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // 상태 변수
  DateTime? _dueDate;
  bool _isPinned = false;
  String _priority = TaskPriority.defaultValue;

  @override
  void dispose() {
    // 컨트롤러 해제
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새로운 할 일'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '할 일의 제목을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            // 설명 입력 필드
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '할 일에 대한 설명을 입력하세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // 마감일 선택 필드
            ListTile(
              title: const Text('마감일'),
              subtitle: Text(
                _dueDate != null
                    ? '${_dueDate!.year}년 ${_dueDate!.month}월 ${_dueDate!.day}일'
                    : '선택하지 않음',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            // 중요도 선택 드롭다운
            ListTile(
              title: const Text('중요도'),
              trailing: DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
                items: TaskPriority.values.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // 고정된 할 일 체크박스
            CheckboxListTile(
              title: const Text('고정됨'),
              value: _isPinned,
              onChanged: (value) {
                setState(() {
                  _isPinned = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        // 추가 버튼
        FilledButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final actions = ref.read(taskActionsProvider);
              actions.addTask(
                title: _titleController.text,
                description: _descriptionController.text.isNotEmpty 
                    ? _descriptionController.text 
                    : null,
                dueDate: _dueDate,
                isPinned: _isPinned,
                priority: _priority,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
} 