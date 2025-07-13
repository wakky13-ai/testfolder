import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/database_service.dart';

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({Key? key}) : super(key: key);

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  int _understandingLevel = 2; // 1:理解不足, 2:なんとなく理解, 3:完全理解

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final question = appState.currentQuestion;
        final selectedAnswer = appState.selectedAnswer;
        
        if (question == null || selectedAnswer == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isCorrect = selectedAnswer == question.correctAnswer;

        return Scaffold(
          appBar: AppBar(
            title: Text('解説 ${appState.progressText}'),
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
                  // 結果表示
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              size: 64,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isCorrect ? '正解！' : '不正解',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '正解: ${String.fromCharCode(65 + question.correctAnswer)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'あなたの解答: ${String.fromCharCode(65 + selectedAnswer)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 解説内容
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 問題文の再表示
                          Card(
                            elevation: 2,
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
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 選択肢の表示（正解をハイライト）
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '選択肢',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...question.options.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final option = entry.value;
                                    final isCorrectOption = index == question.correctAnswer;
                                    final isSelectedOption = index == selectedAnswer;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isCorrectOption 
                                            ? Colors.green[50] 
                                            : isSelectedOption && !isCorrectOption
                                                ? Colors.red[50]
                                                : Colors.grey[50],
                                        border: Border.all(
                                          color: isCorrectOption 
                                              ? Colors.green 
                                              : isSelectedOption && !isCorrectOption
                                                  ? Colors.red
                                                  : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCorrectOption 
                                                  ? Colors.green 
                                                  : isSelectedOption && !isCorrectOption
                                                      ? Colors.red
                                                      : Colors.grey[400],
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(65 + index),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          if (isCorrectOption)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                          if (isSelectedOption && !isCorrectOption)
                                            const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 基本解説
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '解説',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    question.basicExplanation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 詳細解説
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '詳細解説',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    question.detailedExplanation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 関連条文
                          if (question.relatedArticles.isNotEmpty)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '関連条文',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...question.relatedArticles.map((article) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.article,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              article,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 理解度評価
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '理解度を評価してください',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: [
                                      RadioListTile<int>(
                                        title: const Text('完全理解'),
                                        subtitle: const Text('問題の内容を完全に理解できた'),
                                        value: 3,
                                        groupValue: _understandingLevel,
                                        onChanged: (value) {
                                          setState(() {
                                            _understandingLevel = value!;
                                          });
                                        },
                                      ),
                                      RadioListTile<int>(
                                        title: const Text('なんとなく理解'),
                                        subtitle: const Text('だいたいの内容は理解できた'),
                                        value: 2,
                                        groupValue: _understandingLevel,
                                        onChanged: (value) {
                                          setState(() {
                                            _understandingLevel = value!;
                                          });
                                        },
                                      ),
                                      RadioListTile<int>(
                                        title: const Text('理解不足'),
                                        subtitle: const Text('内容がよく分からなかった'),
                                        value: 1,
                                        groupValue: _understandingLevel,
                                        onChanged: (value) {
                                          setState(() {
                                            _understandingLevel = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // 次へボタン
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => _proceedToNext(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appState.isLastQuestion ? '結果を見る' : '次の問題へ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            appState.isLastQuestion ? Icons.assessment : Icons.arrow_forward,
                          ),
                        ],
                      ),
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

  void _proceedToNext() {
    // 理解度をデータベースに保存
    _saveUnderstandingLevel();
    
    // 画面を閉じる（QuestionScreenに戻る）
    Navigator.of(context).pop();
  }

  void _saveUnderstandingLevel() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final recentProgress = await DatabaseService().getRecentProgress(1);
      
      if (recentProgress.isNotEmpty) {
        final progressId = recentProgress.first.id;
        if (progressId != null) {
          await DatabaseService().updateUnderstandingLevel(progressId, _understandingLevel);
        }
      }
    } catch (e) {
      print('Error saving understanding level: $e');
    }
  }
}