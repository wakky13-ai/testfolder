import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  List<Question> _questions = [];
  bool _isLoaded = false;

  List<Question> get questions => _questions;
  bool get isLoaded => _isLoaded;

  Future<void> loadQuestions() async {
    if (_isLoaded) return;

    try {
      // JSONファイルからデータを読み込み
      final String response = await rootBundle.loadString('assets/questions/takken_questions.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> questionsJson = data['questions'];

      _questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading questions: $e');
      // エラーの場合は空のリストを返す
      _questions = [];
      _isLoaded = true;
    }
  }

  // カテゴリ別の問題を取得
  List<Question> getQuestionsByCategory(String category) {
    return _questions.where((q) => q.category == category).toList();
  }

  // サブカテゴリ別の問題を取得
  List<Question> getQuestionsBySubcategory(String subcategory) {
    return _questions.where((q) => q.subcategory == subcategory).toList();
  }

  // 難易度別の問題を取得
  List<Question> getQuestionsByDifficulty(int difficulty) {
    return _questions.where((q) => q.difficulty == difficulty).toList();
  }

  // 重要度別の問題を取得
  List<Question> getQuestionsByImportance(int importance) {
    return _questions.where((q) => q.importance == importance).toList();
  }

  // ランダムな問題を取得
  List<Question> getRandomQuestions(int count) {
    if (_questions.isEmpty) return [];
    
    List<Question> shuffled = List.from(_questions);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  // 特定の条件でフィルタリング
  List<Question> getFilteredQuestions({
    String? category,
    String? subcategory,
    int? difficulty,
    int? importance,
  }) {
    return _questions.where((q) {
      bool categoryMatch = category == null || q.category == category;
      bool subcategoryMatch = subcategory == null || q.subcategory == subcategory;
      bool difficultyMatch = difficulty == null || q.difficulty == difficulty;
      bool importanceMatch = importance == null || q.importance == importance;
      
      return categoryMatch && subcategoryMatch && difficultyMatch && importanceMatch;
    }).toList();
  }

  // IDで問題を取得
  Question? getQuestionById(String id) {
    try {
      return _questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  // 統計情報を取得
  Map<String, dynamic> getStatistics() {
    if (_questions.isEmpty) return {};

    Map<String, int> categoryCount = {};
    Map<String, int> subcategoryCount = {};
    Map<int, int> difficultyCount = {};
    Map<int, int> importanceCount = {};

    for (var question in _questions) {
      categoryCount[question.category] = (categoryCount[question.category] ?? 0) + 1;
      subcategoryCount[question.subcategory] = (subcategoryCount[question.subcategory] ?? 0) + 1;
      difficultyCount[question.difficulty] = (difficultyCount[question.difficulty] ?? 0) + 1;
      importanceCount[question.importance] = (importanceCount[question.importance] ?? 0) + 1;
    }

    return {
      'total_questions': _questions.length,
      'category_count': categoryCount,
      'subcategory_count': subcategoryCount,
      'difficulty_count': difficultyCount,
      'importance_count': importanceCount,
    };
  }

  // データを再読み込み
  Future<void> reload() async {
    _isLoaded = false;
    _questions.clear();
    await loadQuestions();
  }
}