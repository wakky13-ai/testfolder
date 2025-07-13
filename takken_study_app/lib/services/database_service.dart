import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_progress.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'takken_study.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        attempt_date TEXT NOT NULL,
        selected_option INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        response_time INTEGER,
        understanding_level INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_sessions (
        session_id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_questions INTEGER,
        correct_answers INTEGER,
        session_type TEXT NOT NULL DEFAULT 'normal'
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_question_id ON user_progress(question_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_session_id ON user_progress(session_id)
    ''');
  }

  Future<void> init() async {
    await database;
  }

  // 学習進捗を保存
  Future<int> insertUserProgress(UserProgress progress) async {
    final db = await database;
    return await db.insert('user_progress', progress.toMap());
  }

  // 学習セッションを保存
  Future<int> insertLearningSession(LearningSession session) async {
    final db = await database;
    return await db.insert('learning_sessions', session.toMap());
  }

  // 学習セッションを更新
  Future<int> updateLearningSession(LearningSession session) async {
    final db = await database;
    return await db.update(
      'learning_sessions',
      session.toMap(),
      where: 'session_id = ?',
      whereArgs: [session.sessionId],
    );
  }

  // 特定の問題の学習履歴を取得
  Future<List<UserProgress>> getProgressByQuestion(String questionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'attempt_date DESC',
    );
    return List.generate(maps.length, (i) => UserProgress.fromMap(maps[i]));
  }

  // 特定のセッションの学習履歴を取得
  Future<List<UserProgress>> getProgressBySession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'attempt_date ASC',
    );
    return List.generate(maps.length, (i) => UserProgress.fromMap(maps[i]));
  }

  // 全ての学習セッションを取得
  Future<List<LearningSession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'learning_sessions',
      orderBy: 'start_time DESC',
    );
    return List.generate(maps.length, (i) => LearningSession.fromMap(maps[i]));
  }

  // 統計情報を取得
  Future<Map<String, int>> getStatistics() async {
    final db = await database;
    
    final totalQuestions = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_progress'
    );
    
    final correctAnswers = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_progress WHERE is_correct = 1'
    );
    
    final uniqueQuestions = await db.rawQuery(
      'SELECT COUNT(DISTINCT question_id) as count FROM user_progress'
    );
    
    final totalSessions = await db.rawQuery(
      'SELECT COUNT(*) as count FROM learning_sessions'
    );

    return {
      'total_questions': totalQuestions.first['count'] as int,
      'correct_answers': correctAnswers.first['count'] as int,
      'unique_questions': uniqueQuestions.first['count'] as int,
      'total_sessions': totalSessions.first['count'] as int,
    };
  }

  // 最近の学習履歴を取得
  Future<List<UserProgress>> getRecentProgress(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      orderBy: 'attempt_date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => UserProgress.fromMap(maps[i]));
  }

  // 理解度を更新
  Future<void> updateUnderstandingLevel(int progressId, int level) async {
    final db = await database;
    await db.update(
      'user_progress',
      {'understanding_level': level},
      where: 'id = ?',
      whereArgs: [progressId],
    );
  }

  // データベースを閉じる
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}