# 宅建士試験対策アプリ

宅地建物取引士試験の学習をサポートする、過去問分析に基づいたオリジナル問題集アプリです。

## 特徴

- **宅建業法に特化**: 宅建士試験の中でも重要な宅建業法分野の問題を25問収録
- **過去問分析ベース**: 過去問の傾向を分析してオリジナル問題を作成
- **詳細な解説**: 各問題に基本解説・詳細解説・関連条文を掲載
- **学習進捗管理**: SQLiteによる学習履歴の保存と統計表示
- **理解度評価**: 3段階の理解度自己評価機能

## 機能

### 基本機能
- **ホーム画面**: 学習統計の表示と学習開始
- **問題演習**: 四肢択一形式の問題解答
- **解説表示**: 詳細な解説と理解度評価
- **学習履歴**: 解答履歴と統計情報の確認
- **設定画面**: アプリの各種設定

### 学習フロー
1. 問題を読む
2. 四肢択一から解答を選択
3. 解答を確定
4. 即座に解説を表示
5. 理解度を自己評価
6. 次の問題へ進む

## 技術仕様

- **フレームワーク**: Flutter 3.10.0+
- **言語**: Dart
- **状態管理**: Provider
- **データベース**: SQLite (sqflite)
- **設定保存**: SharedPreferences
- **UI設計**: Material Design 3

## プロジェクト構造

```
lib/
├── main.dart                 # アプリのエントリーポイント
├── models/                   # データモデル
│   ├── app_state.dart       # アプリ全体の状態管理
│   ├── question.dart        # 問題データモデル
│   ├── question_model.dart  # 問題管理モデル
│   └── user_progress.dart   # 学習進捗モデル
├── services/                # サービスクラス
│   ├── database_service.dart # SQLiteデータベース管理
│   └── question_service.dart # 問題データ管理
└── screens/                 # 画面コンポーネント
    ├── home_screen.dart     # ホーム画面
    ├── question_screen.dart # 問題演習画面
    ├── explanation_screen.dart # 解説画面
    ├── result_screen.dart   # 結果画面
    ├── progress_screen.dart # 学習履歴画面
    └── settings_screen.dart # 設定画面

assets/
└── questions/
    └── takken_questions.json # 問題データ（25問）
```

## セットアップ

### 前提条件
- Flutter SDK 3.10.0以上
- Dart SDK 3.0.0以上

### インストール

1. リポジトリをクローン
```bash
git clone <repository-url>
cd takken_study_app
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリを実行
```bash
flutter run
```

## 問題データ構造

問題データは`assets/questions/takken_questions.json`に保存されています。

```json
{
  "questions": [
    {
      "id": "takken_business_001",
      "category": "宅建業法",
      "subcategory": "免許制度",
      "difficulty": 2,
      "importance": 4,
      "question_text": "問題文...",
      "options": ["選択肢A", "選択肢B", "選択肢C", "選択肢D"],
      "correct_answer": 2,
      "basic_explanation": "基本解説...",
      "detailed_explanation": "詳細解説...",
      "related_articles": ["宅建業法第○条"],
      "source_analysis": "分析情報",
      "created_date": "2025-01-01",
      "updated_date": "2025-01-01"
    }
  ]
}
```

## データベーススキーマ

### user_progress テーブル
学習進捗を記録するテーブル

| カラム名 | 型 | 説明 |
|---------|---|------|
| id | INTEGER | 主キー |
| question_id | TEXT | 問題ID |
| session_id | TEXT | セッションID |
| attempt_date | TEXT | 解答日時 |
| selected_option | INTEGER | 選択した選択肢 |
| is_correct | INTEGER | 正解フラグ |
| response_time | INTEGER | 解答時間（秒） |
| understanding_level | INTEGER | 理解度（1-3） |

### learning_sessions テーブル
学習セッションを記録するテーブル

| カラム名 | 型 | 説明 |
|---------|---|------|
| session_id | TEXT | セッションID（主キー） |
| start_time | TEXT | 開始時間 |
| end_time | TEXT | 終了時間 |
| total_questions | INTEGER | 総問題数 |
| correct_answers | INTEGER | 正答数 |
| session_type | TEXT | セッション種別 |

## 開発情報

### 第1段階の目標
- 基本的な学習ループの実装
- 宅建業法25問の問題作成
- 学習履歴の保存・表示
- MVP（最小実行可能製品）として動作検証

### 今後の拡張計画
- 他分野（権利関係、法令制限等）への対応
- 復習システムの実装
- AI支援による解説生成
- クラウド同期機能
- 模擬試験モード

## ライセンス

このプロジェクトはオープンソースで開発されています。

## 開発者

Claude Code を使用して開発されました。

## 注意事項

- このアプリは学習支援ツールです
- 実際の試験問題ではありません
- 最新の法改正情報は公式情報をご確認ください