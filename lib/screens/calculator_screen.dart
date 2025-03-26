import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:drift/drift.dart' as drift;
import 'package:todotools/database/database.dart';

// 계산기 데이터베이스 프로바이더
final calculatorDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// 계산기 히스토리 프로바이더
final calculatorHistoryProvider = StreamProvider<List<CalculatorHistoryData>>((ref) {
  final db = ref.watch(calculatorDatabaseProvider);
  final query = db.select(db.calculatorHistory)
    ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]);
  return query.watch();
});

// 계산기 화면
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  String _input = '';
  String _output = '0';
  bool _isError = false;
  final FocusNode _keyboardFocusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = _input;
    
    // 키보드 포커스 요청
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_keyboardFocusNode);
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  // 계산 수행
  void _calculate() {
    if (_input.isEmpty) {
      setState(() {
        _output = '0';
      });
      return;
    }

    String finalInput = _input;
    
    // % 연산 처리
    if (finalInput.contains('%')) {
      try {
        // % 기호를 /100으로 변환
        finalInput = _processPercentage(finalInput);
      } catch (e) {
        setState(() {
          _output = '에러';
          _isError = true;
        });
        return;
      }
    }
    
    // 괄호 균형 맞추기
    int openParens = '('.allMatches(finalInput).length;
    int closeParens = ')'.allMatches(finalInput).length;
    if (openParens > closeParens) {
      finalInput += ')' * (openParens - closeParens);
    }

    try {
      // math_expressions 라이브러리를 사용한 계산
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      // 결과를 문자열로 변환 (소수점이 .0으로 끝나면 정수로 표시)
      String resultStr = result.toString();
      if (resultStr.endsWith('.0')) {
        resultStr = resultStr.substring(0, resultStr.length - 2);
      }

      setState(() {
        _output = resultStr;
        _isError = false;
      });

      // 계산 결과를 데이터베이스에 저장 (원래 입력을 저장)
      _saveCalculation(_input, resultStr);
    } catch (e) {
      setState(() {
        _output = '에러';
        _isError = true;
      });
    }
  }

  // % 연산 처리를 위한 메소드
  String _processPercentage(String input) {
    // 숫자% 형태를 처리 (예: 50% -> 50/100)
    RegExp simplePercentage = RegExp(r'(\d+\.?\d*)%');
    input = input.replaceAllMapped(simplePercentage, (match) {
      double number = double.parse(match.group(1)!);
      return '(${number}/100)';
    });
    
    // 숫자 연산자 숫자% 형태를 처리 (예: 100+50% -> 100+(100*50/100))
    RegExp operationPercentage = RegExp(r'(\d+\.?\d*)([+\-*/])(\d+\.?\d*)%');
    input = input.replaceAllMapped(operationPercentage, (match) {
      double base = double.parse(match.group(1)!);
      String operator = match.group(2)!;
      double percentage = double.parse(match.group(3)!);
      
      if (operator == '+' || operator == '-') {
        // 더하기/빼기의 경우 기준값의 비율을 계산
        return '$base$operator($base*$percentage/100)';
      } else {
        // 곱하기/나누기의 경우 단순 비율 계산
        return '$base$operator($percentage/100)';
      }
    });
    
    return input;
  }

  // 계산 결과를 DB에 저장
  void _saveCalculation(String expression, String result) async {
    try {
      final db = ref.read(calculatorDatabaseProvider);
      await db.into(db.calculatorHistory).insert(
        CalculatorHistoryCompanion.insert(
          expression: expression,
          result: result,
        ),
      );
    } catch (e) {
      // 오류 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계산 결과 저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 입력 처리
  void _onInput(String key) {
    if (_isError) {
      setState(() {
        _input = '';
        _output = '0';
        _isError = false;
      });
    }

    setState(() {
      switch (key) {
        case 'C':
          _input = '';
          _output = '0';
          break;
        case '⌫':
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
          }
          break;
        case '=':
          _calculate();
          break;
        case '.':
          // 마지막 숫자에 이미 소수점이 있는지 확인
          bool hasDecimal = false;
          String reversedInput = _input.split('').reversed.join('');
          for (int i = 0; i < reversedInput.length; i++) {
            if ('+-*/('.contains(reversedInput[i])) {
              break;
            }
            if (reversedInput[i] == '.') {
              hasDecimal = true;
              break;
            }
          }
          
          if (!hasDecimal) {
            // 마지막 문자가 연산자이거나 빈 문자열이면 0을 추가
            if (_input.isEmpty || '+-*/('.contains(_input[_input.length - 1])) {
              _input += '0';
            }
            _input += key;
          }
          break;
        default:
          _input += key;
          break;
      }
      
      _textController.text = _input;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
  }

  // 키보드 입력 처리
  void _handleKeyboard(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // 키가 눌려진 상태에서의 문자 처리
      if (event.character != null) {
        final char = event.character!;
        if ('0123456789.+-*/%()'.contains(char)) {
          _onInput(char);
          return;
        } else if (char == '=' || char == '\n') {
          _onInput('=');
          return;
        }
      }
      
      // 숫자패드 및 특수 키 처리
      if (event.logicalKey == LogicalKeyboardKey.numpad0) {
        _onInput('0');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad1) {
        _onInput('1');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad2) {
        _onInput('2');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad3) {
        _onInput('3');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad4) {
        _onInput('4');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad5) {
        _onInput('5');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad6) {
        _onInput('6');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad7) {
        _onInput('7');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad8) {
        _onInput('8');
      } else if (event.logicalKey == LogicalKeyboardKey.numpad9) {
        _onInput('9');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        _onInput('.');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        _onInput('+');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        _onInput('-');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadMultiply) {
        _onInput('*');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDivide) {
        _onInput('/');
      } else if (event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        _onInput('=');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onInput('⌫');
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _onInput('C');
      } else if (event.logicalKey == LogicalKeyboardKey.enter || 
                 event.logicalKey == LogicalKeyboardKey.equal) {
        _onInput('=');
      }
      // 쉬프트 키 조합 처리 (다른 입력이 없는 경우에만)
      else if (event.isShiftPressed) {
        if (event.logicalKey == LogicalKeyboardKey.digit8) {
          _onInput('*'); // Shift+8 -> *
        } else if (event.logicalKey == LogicalKeyboardKey.equal) {
          _onInput('+'); // Shift+= -> +
        } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
          _onInput('('); // Shift+9 -> (
        } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
          _onInput(')'); // Shift+0 -> )
        } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
          _onInput('%'); // Shift+5 -> %
        }
      }
    }
  }

  // 히스토리 아이템 클릭 처리
  void _onHistoryItemClick(String expression, String result) {
    setState(() {
      _input = result;
      _output = result;
      _textController.text = _input;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
  }
  
  // 히스토리 항목 삭제
  Future<void> _deleteHistoryItem(int id) async {
    try {
      final db = ref.read(calculatorDatabaseProvider);
      await db.deleteCalculatorHistory(id);
      
      // 히스토리 갱신
      ref.refresh(calculatorHistoryProvider);
    } catch (e) {
      // 오류 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계산 기록 삭제 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
  
  // 모든 히스토리 초기화
  Future<void> _clearAllHistory() async {
    try {
      final db = ref.read(calculatorDatabaseProvider);
      await db.clearAllCalculatorHistory();
      
      // 히스토리 갱신
      ref.refresh(calculatorHistoryProvider);
    } catch (e) {
      // 오류 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계산 기록 초기화 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
  
  // 히스토리 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(int id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계산 기록 삭제'),
          content: const Text('이 계산 기록을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHistoryItem(id);
              },
            ),
          ],
        );
      },
    );
  }
  
  // 모든 히스토리 초기화 확인 다이얼로그
  Future<void> _showClearAllConfirmDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계산 기록 초기화'),
          content: const Text('모든 계산 기록을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllHistory();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: _handleKeyboard,
      child: Scaffold(
        body: Row(
          children: [
            // 계산기 부분
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // 계산 결과 표시 부분
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomRight,
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 식 입력 필드
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '식을 입력하세요',
                            ),
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.none, // 시스템 키보드 비활성화
                            onChanged: (value) {
                              setState(() {
                                _input = value;
                              });
                            },
                          ),
                        ),
                        // 결과 표시
                        Text(
                          _output,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _isError ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 계산기 버튼 부분
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 4,
                                childAspectRatio: 1.5,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  _buildCalcButton('C', Colors.red),
                                  _buildCalcButton('(', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton(')', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton('⌫', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton('7'),
                                  _buildCalcButton('8'),
                                  _buildCalcButton('9'),
                                  _buildCalcButton('/', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton('4'),
                                  _buildCalcButton('5'),
                                  _buildCalcButton('6'),
                                  _buildCalcButton('*', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton('1'),
                                  _buildCalcButton('2'),
                                  _buildCalcButton('3'),
                                  _buildCalcButton('-', Theme.of(context).colorScheme.tertiary),
                                  _buildCalcButton('0'),
                                  _buildCalcButton('.'),
                                  _buildCalcButton('=', Theme.of(context).colorScheme.primary),
                                  _buildCalcButton('+', Theme.of(context).colorScheme.tertiary),
                                ],
                              ),
                            ),
                            // 안내 문구 추가
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "중요한 계산은 타 프로그램을 사용해주세요",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 계산 히스토리 부분
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // 히스토리 제목과 초기화 버튼
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '계산 기록',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 전체 초기화 버튼
                          IconButton(
                            icon: const Icon(Icons.delete_sweep),
                            tooltip: '모든 기록 삭제',
                            onPressed: () => _showClearAllConfirmDialog(),
                          ),
                        ],
                      ),
                    ),
                    // 히스토리 목록
                    Expanded(
                      child: _buildHistoryList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 계산기 버튼 위젯
  Widget _buildCalcButton(String text, [Color? color]) {
    return ElevatedButton(
      onPressed: () => _onInput(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  // 히스토리 목록 위젯
  Widget _buildHistoryList() {
    final calculatorHistory = ref.watch(calculatorHistoryProvider);
    
    return calculatorHistory.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('계산 기록이 없습니다.'),
          );
        }
        
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  item.expression,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '= ${item.result}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 계산 결과 재사용 버튼
                    IconButton(
                      icon: const Icon(Icons.replay),
                      onPressed: () => _onHistoryItemClick(item.expression, item.result),
                      tooltip: '계산 결과 사용하기',
                    ),
                    // 항목 삭제 버튼
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmDialog(item.id),
                      tooltip: '기록 삭제',
                    ),
                  ],
                ),
                onTap: () => _onHistoryItemClick(item.expression, item.result),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('에러가 발생했습니다: $err'),
      ),
    );
  }
} 