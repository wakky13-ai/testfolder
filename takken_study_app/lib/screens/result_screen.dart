import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/user_progress.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = true;
  LearningSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      final session = LearningSession(
        sessionId: appState.currentSessionId,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)), // 仮の開始時間
        endTime: DateTime.now(),
        totalQuestions: appState.totalQuestions,
        correctAnswers: appState.correctAnswers,
        sessionType: 'normal',
      );
      
      await DatabaseService().insertLearningSession(session);
      
      setState(() {
        _currentSession = session;
        _isLoading = false;
      });
    } catch (e) {
      print('Error saving session: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習結果'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AppState>(
              builder: (context, appState, child) {
                final correctRate = appState.correctRate;
                final scoreColor = _getScoreColor(correctRate);
                
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[800]!, Colors.blue[50]!],
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 結果サマリー
                          Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    _getScoreIcon(correctRate),
                                    size: 80,
                                    color: scoreColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '学習完了！',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getScoreMessage(correctRate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // スコア詳細
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'スコア詳細',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // 正答率表示
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: scoreColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: scoreColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${(correctRate * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: scoreColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '正答率',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: scoreColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${appState.correctAnswers}/${appState.totalQuestions}問正解',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // 統計情報
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '総問題数',
                                          '${appState.totalQuestions}問',
                                          Icons.quiz,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '正解数',
                                          '${appState.correctAnswers}問',
                                          Icons.check_circle,
                                          Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '不正解数',
                                          '${appState.totalQuestions - appState.correctAnswers}問',
                                          Icons.cancel,
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 学習アドバイス
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '学習アドバイス',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb,
                                          color: Colors.amber[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getAdvice(correctRate),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
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
                          
                          const SizedBox(height: 24),
                          
                          // アクションボタン
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _restartLearning(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh),
                                    SizedBox(width: 8),
                                    Text(
                                      'もう一度学習する',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              OutlinedButton(
                                onPressed: () => _goHome(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home),
                                    SizedBox(width: 8),
                                    Text(
                                      'ホームに戻る',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double rate) {
    if (rate >= 0.8) return Icons.emoji_events;
    if (rate >= 0.6) return Icons.thumb_up;
    return Icons.refresh;
  }

  String _getScoreMessage(double rate) {
    if (rate >= 0.9) return '素晴らしい！完璧に理解できています';
    if (rate >= 0.8) return 'とても良い結果です！';
    if (rate >= 0.7) return 'まずまずの結果です';
    if (rate >= 0.6) return 'もう少し復習が必要です';
    return '基礎からしっかり学習しましょう';
  }

  String _getAdvice(double rate) {
    if (rate >= 0.9) {
      return '完璧な理解度です！引き続き他の分野の学習に進んで、宅建士試験合格を目指しましょう。';
    } else if (rate >= 0.8) {
      return '理解度は高いレベルです。間違えた問題を重点的に復習することで、さらに得点を伸ばせます。';
    } else if (rate >= 0.7) {
      return '基本は理解できています。間違えた分野をもう一度学習し、解説をしっかり読み返しましょう。';
    } else if (rate >= 0.6) {
      return '基礎知識の定着が不十分です。宅建業法の基本的な制度から順番に学習し直すことをお勧めします。';
    } else {
      return '宅建業法の基礎からじっくり学習する必要があります。解説を丁寧に読み、理解を深めることから始めましょう。';
    }
  }

  void _restartLearning() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.resetQuiz();
    
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // 少し待ってから学習画面に遷移
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pushNamed(context, '/question');
      }
    });
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}