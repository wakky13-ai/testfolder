import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/question.dart';
import '../services/database_service.dart';
import 'explanation_screen.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final PageController _pageController = PageController();
  int? _selectedOption;
  bool _isAnswerConfirmed = false;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final question = appState.currentQuestion;
        
        if (question == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('問題 ${appState.progressText}'),
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[800]!, Colors.blue[50]!],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 進捗バー
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '進捗: ${appState.progressText}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '正答率: ${(appState.correctRate * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (appState.currentQuestionIndex + 1) / appState.questions.length,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  
                  // 問題内容
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 問題分野
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: Colors.blue[800],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${question.category} > ${question.subcategory}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(question.difficulty),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '難易度 ${question.difficulty}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 問題文
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '問題',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    question.questionText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 選択肢
                          ...question.options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: _isAnswerConfirmed ? null : () => _selectOption(index),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _getOptionBorderColor(index),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: _getOptionBackgroundColor(index),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _getOptionNumberColor(index),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index), // A, B, C, D
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // ボタン
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (appState.currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isAnswerConfirmed ? null : _previousQuestion,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('前の問題'),
                            ),
                          ),
                        
                        if (appState.currentQuestionIndex > 0)
                          const SizedBox(width: 16),
                        
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedOption != null ? _confirmAnswer : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '解答する',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getOptionBorderColor(int index) {
    if (_selectedOption == index) {
      return Colors.blue[600]!;
    }
    return Colors.grey[300]!;
  }

  Color _getOptionBackgroundColor(int index) {
    if (_selectedOption == index) {
      return Colors.blue[50]!;
    }
    return Colors.white;
  }

  Color _getOptionNumberColor(int index) {
    if (_selectedOption == index) {
      return Colors.blue[600]!;
    }
    return Colors.grey[400]!;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
    });
  }

  void _confirmAnswer() {
    if (_selectedOption == null) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // 解答時間を計算
    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inSeconds
        : null;
    
    // 状態を更新
    appState.selectAnswer(_selectedOption!);
    appState.showExplanation();
    
    // 学習記録を保存
    _saveUserProgress(responseTime);
    
    setState(() {
      _isAnswerConfirmed = true;
    });
    
    // 解説画面に遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExplanationScreen(),
      ),
    ).then((_) {
      // 解説画面から戻ったら次の問題へ
      _nextQuestion();
    });
  }

  void _saveUserProgress(int? responseTime) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final progress = appState.createUserProgress();
      
      await DatabaseService().insertUserProgress(progress);
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  void _nextQuestion() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.isLastQuestion) {
      // 最後の問題の場合、結果画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultScreen(),
        ),
      );
    } else {
      appState.nextQuestion();
      setState(() {
        _selectedOption = null;
        _isAnswerConfirmed = false;
        _questionStartTime = DateTime.now();
      });
    }
  }

  void _previousQuestion() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.previousQuestion();
    setState(() {
      _selectedOption = null;
      _isAnswerConfirmed = false;
      _questionStartTime = DateTime.now();
    });
  }
}