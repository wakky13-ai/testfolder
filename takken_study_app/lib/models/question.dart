class Question {
  final String id;
  final String category;
  final String subcategory;
  final int difficulty;
  final int importance;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String basicExplanation;
  final String detailedExplanation;
  final List<String> relatedArticles;
  final String sourceAnalysis;
  final String createdDate;
  final String updatedDate;

  Question({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.difficulty,
    required this.importance,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.basicExplanation,
    required this.detailedExplanation,
    required this.relatedArticles,
    required this.sourceAnalysis,
    required this.createdDate,
    required this.updatedDate,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      category: json['category'],
      subcategory: json['subcategory'],
      difficulty: json['difficulty'],
      importance: json['importance'],
      questionText: json['question_text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      basicExplanation: json['basic_explanation'],
      detailedExplanation: json['detailed_explanation'],
      relatedArticles: List<String>.from(json['related_articles']),
      sourceAnalysis: json['source_analysis'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'difficulty': difficulty,
      'importance': importance,
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'basic_explanation': basicExplanation,
      'detailed_explanation': detailedExplanation,
      'related_articles': relatedArticles,
      'source_analysis': sourceAnalysis,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}