class AppConstants {
  static const String appName = '宅建士試験対策アプリ';
  static const String appVersion = '1.0.0';
  static const String developer = 'Claude Code';
  
  // データベース関連
  static const String databaseName = 'takken_study.db';
  static const int databaseVersion = 1;
  
  // 設定キー
  static const String soundEnabledKey = 'sound_enabled';
  static const String vibrationEnabledKey = 'vibration_enabled';
  static const String darkModeKey = 'dark_mode';
  static const String showDetailedExplanationKey = 'show_detailed_explanation';
  static const String questionOrderKey = 'question_order';
  
  // 理解度レベル
  static const int understandingPoor = 1;
  static const int understandingFair = 2;
  static const int understandingGood = 3;
  
  // 問題難易度
  static const int difficultyEasy = 1;
  static const int difficultyNormal = 2;
  static const int difficultyHard = 3;
  static const int difficultyVeryHard = 4;
  static const int difficultyExpert = 5;
  
  // 色設定
  static const int primaryBlue = 0xFF1976D2;
  static const int primaryOrange = 0xFFFF9800;
  static const int successGreen = 0xFF4CAF50;
  static const int errorRed = 0xFFF44336;
  static const int warningAmber = 0xFFFFC107;
  
  // アニメーション時間
  static const int shortAnimation = 200;
  static const int normalAnimation = 300;
  static const int longAnimation = 500;
}