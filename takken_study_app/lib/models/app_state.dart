import 'package:flutter/material.dart';
import 'question.dart';
import 'user_progress.dart';

class AppState extends ChangeNotifier {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  int _currentSession = 0;
  String _currentSessionId = '';
  
  // Getters
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question? get currentQuestion => 
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  int? get selectedAnswer => _selectedAnswer;
  bool get showExplanation => _showExplanation;
  int get totalQuestions => _totalQuestions;
  int get correctAnswers => _correctAnswers;
  double get correctRate => _totalQuestions > 0 ? _correctAnswers / _totalQuestions : 0.0;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  String get currentSessionId => _currentSessionId;
  
  // 学習統計
  int get remainingQuestions => _questions.length - _currentQuestionIndex - 1;
  String get progressText => '${_currentQuestionIndex + 1}/${_questions.length}';
  
  void setQuestions(List<Question> questions) {
    _questions = questions;
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _showExplanation = false;
    _generateNewSessionId();
    notifyListeners();
  }
  
  void selectAnswer(int answerIndex) {
    _selectedAnswer = answerIndex;
    notifyListeners();
  }
  
  void showExplanation() {
    if (_selectedAnswer != null) {
      _showExplanation = true;
      
      // 正誤判定
      bool isCorrect = _selectedAnswer == currentQuestion!.correctAnswer;
      if (isCorrect) {
        _correctAnswers++;
      }
      _totalQuestions++;
      
      notifyListeners();
    }
  }
  
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _showExplanation = false;
      notifyListeners();
    }
  }
  
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _selectedAnswer = null;
      _showExplanation = false;
      notifyListeners();
    }
  }
  
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _showExplanation = false;
    _totalQuestions = 0;
    _correctAnswers = 0;
    _generateNewSessionId();
    notifyListeners();
  }
  
  void _generateNewSessionId() {
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  UserProgress createUserProgress() {
    if (currentQuestion == null || _selectedAnswer == null) {
      throw Exception('Current question or selected answer is null');
    }
    
    return UserProgress(
      questionId: currentQuestion!.id,
      sessionId: _currentSessionId,
      attemptDate: DateTime.now(),
      selectedOption: _selectedAnswer!,
      isCorrect: _selectedAnswer == currentQuestion!.correctAnswer,
      understandingLevel: 2, // デフォルト値、後で理解度評価機能で更新
    );
  }
}