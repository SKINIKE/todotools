import 'package:flutter/material.dart';

// 우선순위 값에 대한 상수 (0: 선택안함, 1: 낮음, 2: 중간, 3: 높음)
class PriorityLevel {
  static const none = 0;
  static const low = 1;
  static const medium = 2;
  static const high = 3;
}

// 우선순위 값에 대한 레이블 매핑
const Map<int, String> priorityLabels = {
  PriorityLevel.none: '선택안함',
  PriorityLevel.low: '낮음',
  PriorityLevel.medium: '중간',
  PriorityLevel.high: '높음',
};

// 우선순위 값에 대한 색상 매핑
const Map<int, Color> priorityColors = {
  PriorityLevel.none: Colors.grey,
  PriorityLevel.low: Colors.blue,
  PriorityLevel.medium: Colors.orange,
  PriorityLevel.high: Colors.red,
}; 