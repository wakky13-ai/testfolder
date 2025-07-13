import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/database_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _statistics = {};
  List<LearningSession> _sessions = [];
  List<UserProgress> _recentProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final stats = await DatabaseService().getStatistics();
      final sessions = await DatabaseService().getAllSessions();
      final recent = await DatabaseService().getRecentProgress(20);
      
      setState(() {
        _statistics = stats;
        _sessions = sessions;
        _recentProgress = recent;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading progress data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習履歴'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: '統計'),
            Tab(icon: Icon(Icons.history), text: 'セッション'),
            Tab(icon: Icon(Icons.list), text: '履歴'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildSessionsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildStatisticsTab() {
    final totalQuestions = _statistics['total_questions'] ?? 0;
    final correctAnswers = _statistics['correct_answers'] ?? 0;
    final uniqueQuestions = _statistics['unique_questions'] ?? 0;
    final totalSessions = _statistics['total_sessions'] ?? 0;
    
    final correctRate = totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[800]!, Colors.blue[50]!],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 全体統計
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '全体統計',
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
                        color: _getScoreColor(correctRate).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getScoreColor(correctRate).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(correctRate * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(correctRate),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '全体正答率',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getScoreColor(correctRate),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$correctAnswers/$totalQuestions問正解',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 統計詳細
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            '解答数',
                            totalQuestions.toString(),
                            Icons.quiz,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            '学習問題数',
                            uniqueQuestions.toString(),
                            Icons.library_books,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            'セッション数',
                            totalSessions.toString(),
                            Icons.schedule,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 学習進捗
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '学習進捗',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 進捗バー
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('宅建業法'),
                            Text('$uniqueQuestions/25問'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: uniqueQuestions / 25,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            uniqueQuestions >= 25 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                              _getAdvice(correctRate, totalQuestions),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[800]!, Colors.blue[50]!],
        ),
      ),
      child: _sessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'まだ学習セッションがありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final rate = session.totalQuestions! > 0
                    ? session.correctAnswers! / session.totalQuestions!
                    : 0.0;
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getScoreColor(rate),
                      child: Text(
                        '${(rate * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${session.correctAnswers}/${session.totalQuestions}問正解',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _formatDateTime(session.startTime),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(
                      _getScoreIcon(rate),
                      color: _getScoreColor(rate),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHistoryTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[800]!, Colors.blue[50]!],
        ),
      ),
      child: _recentProgress.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'まだ解答履歴がありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentProgress.length,
              itemBuilder: (context, index) {
                final progress = _recentProgress[index];
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: progress.isCorrect ? Colors.green : Colors.red,
                      child: Icon(
                        progress.isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      progress.questionId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '解答: ${String.fromCharCode(65 + progress.selectedOption)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          _formatDateTime(progress.attemptDate),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getUnderstandingIcon(progress.understandingLevel),
                          color: _getUnderstandingColor(progress.understandingLevel),
                          size: 16,
                        ),
                        Text(
                          _getUnderstandingText(progress.understandingLevel),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getUnderstandingColor(progress.understandingLevel),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
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

  IconData _getUnderstandingIcon(int level) {
    switch (level) {
      case 1:
        return Icons.sentiment_dissatisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_satisfied;
      default:
        return Icons.help;
    }
  }

  Color _getUnderstandingColor(int level) {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUnderstandingText(int level) {
    switch (level) {
      case 1:
        return '理解不足';
      case 2:
        return 'なんとなく';
      case 3:
        return '完全理解';
      default:
        return '不明';
    }
  }

  String _getAdvice(double rate, int totalQuestions) {
    if (totalQuestions == 0) {
      return '学習を開始しましょう！まずは基本的な問題から始めて、宅建業法の基礎を身につけましょう。';
    } else if (rate >= 0.8) {
      return '素晴らしい成績です！この調子で継続的に学習を続けて、宅建士試験合格を目指しましょう。';
    } else if (rate >= 0.6) {
      return '順調に学習が進んでいます。間違えた問題を重点的に復習して、さらに理解を深めましょう。';
    } else {
      return '基礎知識の定着に重点を置きましょう。解説をしっかり読み、理解度を高めることが重要です。';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}