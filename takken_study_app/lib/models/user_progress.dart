class UserProgress {
  final int? id;
  final String questionId;
  final String sessionId;
  final DateTime attemptDate;
  final int selectedOption;
  final bool isCorrect;
  final int? responseTime;
  final int understandingLevel;

  UserProgress({
    this.id,
    required this.questionId,
    required this.sessionId,
    required this.attemptDate,
    required this.selectedOption,
    required this.isCorrect,
    this.responseTime,
    required this.understandingLevel,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      questionId: map['question_id'],
      sessionId: map['session_id'],
      attemptDate: DateTime.parse(map['attempt_date']),
      selectedOption: map['selected_option'],
      isCorrect: map['is_correct'] == 1,
      responseTime: map['response_time'],
      understandingLevel: map['understanding_level'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'session_id': sessionId,
      'attempt_date': attemptDate.toIso8601String(),
      'selected_option': selectedOption,
      'is_correct': isCorrect ? 1 : 0,
      'response_time': responseTime,
      'understanding_level': understandingLevel,
    };
  }
}

class LearningSession {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? totalQuestions;
  final int? correctAnswers;
  final String sessionType;

  LearningSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.totalQuestions,
    this.correctAnswers,
    required this.sessionType,
  });

  factory LearningSession.fromMap(Map<String, dynamic> map) {
    return LearningSession(
      sessionId: map['session_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      sessionType: map['session_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'session_type': sessionType,
    };
  }
}