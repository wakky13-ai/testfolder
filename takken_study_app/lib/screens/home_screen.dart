import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../services/database_service.dart';
import 'question_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await DatabaseService().getStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宅建士試験対策アプリ'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ウェルカムメッセージ
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          size: 48,
                          color: Colors.blue[800],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '宅建業法を学習しよう',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '過去問分析に基づいた厳選問題で\n効率的に学習できます',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 学習統計
                if (!_isLoading)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '学習統計',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                '解答数',
                                _statistics['total_questions']?.toString() ?? '0',
                                Icons.quiz,
                              ),
                              _buildStatItem(
                                '正答数',
                                _statistics['correct_answers']?.toString() ?? '0',
                                Icons.check_circle,
                              ),
                              _buildStatItem(
                                '正答率',
                                _getCorrectRate(),
                                Icons.trending_up,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // メインボタン
                ElevatedButton(
                  onPressed: () => _startLearning(context),
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
                      Icon(Icons.play_arrow, size: 28),
                      SizedBox(width: 8),
                      Text(
                        '宅建業法を学習する',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // サブメニュー
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showProgress(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.analytics),
                            SizedBox(height: 4),
                            Text('学習履歴'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showSettings(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.settings),
                            SizedBox(height: 4),
                            Text('設定'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // 今日の推奨学習
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '今日の推奨学習',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTodayRecommendation(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getCorrectRate() {
    final total = _statistics['total_questions'] ?? 0;
    final correct = _statistics['correct_answers'] ?? 0;
    
    if (total == 0) return '0%';
    
    final rate = (correct / total * 100).round();
    return '$rate%';
  }

  String _getTodayRecommendation() {
    final total = _statistics['total_questions'] ?? 0;
    
    if (total == 0) {
      return '新しい問題から始めて、宅建業法の基礎を学習しましょう！';
    } else if (total < 10) {
      return '基本的な問題を継続して学習しましょう。';
    } else {
      return '復習を重視して、理解度を深めましょう。';
    }
  }

  void _startLearning(BuildContext context) async {
    final questionService = QuestionService();
    final questions = questionService.questions;
    
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('問題データを読み込み中です。少々お待ちください。')),
      );
      return;
    }
    
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setQuestions(questions);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionScreen(),
      ),
    ).then((_) {
      // 学習画面から戻ったら統計を更新
      _loadStatistics();
    });
  }

  void _showProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProgressScreen(),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}