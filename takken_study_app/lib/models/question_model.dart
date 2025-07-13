import 'package:flutter/material.dart';
import 'question.dart';

class QuestionModel extends ChangeNotifier {
  List<Question> _allQuestions = [];
  List<Question> _filteredQuestions = [];
  String _selectedCategory = '全て';
  String _selectedSubcategory = '全て';
  int _selectedDifficulty = 0; // 0 = 全て

  List<Question> get allQuestions => _allQuestions;
  List<Question> get filteredQuestions => _filteredQuestions;
  String get selectedCategory => _selectedCategory;
  String get selectedSubcategory => _selectedSubcategory;
  int get selectedDifficulty => _selectedDifficulty;

  // カテゴリ一覧を取得
  List<String> get categories {
    Set<String> categorySet = _allQuestions.map((q) => q.category).toSet();
    return ['全て', ...categorySet.toList()];
  }

  // サブカテゴリ一覧を取得
  List<String> get subcategories {
    Set<String> subcategorySet = _allQuestions
        .where((q) => _selectedCategory == '全て' || q.category == _selectedCategory)
        .map((q) => q.subcategory)
        .toSet();
    return ['全て', ...subcategorySet.toList()];
  }

  // 難易度一覧を取得
  List<int> get difficulties {
    Set<int> difficultySet = _allQuestions.map((q) => q.difficulty).toSet();
    return [0, ...difficultySet.toList()]; // 0 = 全て
  }

  void setQuestions(List<Question> questions) {
    _allQuestions = questions;
    _filteredQuestions = questions;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _selectedSubcategory = '全て'; // カテゴリ変更時はサブカテゴリをリセット
    _applyFilters();
    notifyListeners();
  }

  void setSubcategory(String subcategory) {
    _selectedSubcategory = subcategory;
    _applyFilters();
    notifyListeners();
  }

  void setDifficulty(int difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredQuestions = _allQuestions.where((question) {
      bool categoryMatch = _selectedCategory == '全て' || question.category == _selectedCategory;
      bool subcategoryMatch = _selectedSubcategory == '全て' || question.subcategory == _selectedSubcategory;
      bool difficultyMatch = _selectedDifficulty == 0 || question.difficulty == _selectedDifficulty;
      
      return categoryMatch && subcategoryMatch && difficultyMatch;
    }).toList();
  }

  void clearFilters() {
    _selectedCategory = '全て';
    _selectedSubcategory = '全て';
    _selectedDifficulty = 0;
    _filteredQuestions = _allQuestions;
    notifyListeners();
  }

  // 統計情報
  int get totalQuestions => _allQuestions.length;
  int get filteredQuestionCount => _filteredQuestions.length;
  
  Map<String, int> get categoryCount {
    Map<String, int> count = {};
    for (var question in _allQuestions) {
      count[question.category] = (count[question.category] ?? 0) + 1;
    }
    return count;
  }
  
  Map<String, int> get subcategoryCount {
    Map<String, int> count = {};
    for (var question in _allQuestions) {
      count[question.subcategory] = (count[question.subcategory] ?? 0) + 1;
    }
    return count;
  }
}