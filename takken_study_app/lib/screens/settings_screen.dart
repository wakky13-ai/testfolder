import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/question_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _showDetailedExplanation = true;
  int _questionOrder = 0; // 0: 順番, 1: ランダム
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _showDetailedExplanation = prefs.getBool('show_detailed_explanation') ?? true;
      _questionOrder = prefs.getInt('question_order') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('show_detailed_explanation', _showDetailedExplanation);
    await prefs.setInt('question_order', _questionOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 学習設定
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '学習設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 問題の順序
                    ListTile(
                      leading: const Icon(Icons.shuffle),
                      title: const Text('問題の順序'),
                      subtitle: Text(_questionOrder == 0 ? '順番通り' : 'ランダム'),
                      trailing: DropdownButton<int>(
                        value: _questionOrder,
                        onChanged: (value) {
                          setState(() {
                            _questionOrder = value!;
                          });
                          _saveSettings();
                        },
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('順番通り')),
                          DropdownMenuItem(value: 1, child: Text('ランダム')),
                        ],
                      ),
                    ),
                    
                    const Divider(),
                    
                    // 詳細解説の表示
                    SwitchListTile(
                      secondary: const Icon(Icons.description),
                      title: const Text('詳細解説を表示'),
                      subtitle: const Text('解説画面で詳細な説明を表示します'),
                      value: _showDetailedExplanation,
                      onChanged: (value) {
                        setState(() {
                          _showDetailedExplanation = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // アプリ設定
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'アプリ設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 音声設定
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up),
                      title: const Text('音声'),
                      subtitle: const Text('正解・不正解時の音声を再生します'),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        _saveSettings();
                      },
                    ),
                    
                    const Divider(),
                    
                    // バイブレーション設定
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration),
                      title: const Text('バイブレーション'),
                      subtitle: const Text('正解・不正解時にバイブレーションします'),
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                        _saveSettings();
                      },
                    ),
                    
                    const Divider(),
                    
                    // ダークモード設定
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: const Text('ダークモード'),
                      subtitle: const Text('画面を暗いテーマに変更します'),
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                        _saveSettings();
                        // ダークモードの実装は今後の課題
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ダークモードは今後のアップデートで対応予定です')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // データ管理
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'データ管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 問題データ再読み込み
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.blue),
                      title: const Text('問題データを再読み込み'),
                      subtitle: const Text('最新の問題データを読み込み直します'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _reloadQuestions(),
                    ),
                    
                    const Divider(),
                    
                    // 学習履歴削除
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.orange),
                      title: const Text('学習履歴を削除'),
                      subtitle: const Text('すべての学習履歴を削除します'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _clearProgress(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // アプリ情報
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'アプリ情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // バージョン情報
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('バージョン'),
                      subtitle: const Text('1.0.0'),
                    ),
                    
                    const Divider(),
                    
                    // 開発者情報
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('開発者'),
                      subtitle: const Text('Claude Code'),
                    ),
                    
                    const Divider(),
                    
                    // ライセンス情報
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('ライセンス'),
                      subtitle: const Text('オープンソースライセンス'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showLicenses(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // フッター
            Center(
              child: Text(
                '宅建士試験対策アプリ v1.0.0\nClaude Code で作成',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reloadQuestions() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('問題データを読み込み中...'),
          ],
        ),
      ),
    );
    
    try {
      await QuestionService().reload();
      Navigator.of(context).pop(); // ダイアログを閉じる
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('問題データを再読み込みしました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('問題データの読み込みに失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学習履歴を削除'),
        content: const Text('すべての学習履歴を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // データベースの初期化（データ削除）
        await DatabaseService().close();
        await DatabaseService().init();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('学習履歴を削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLicenses() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ライセンス情報'),
        content: const SingleChildScrollView(
          child: Text(
            'このアプリは以下のオープンソースライブラリを使用しています：\n\n'
            '• Flutter SDK\n'
            '• Provider\n'
            '• SQLite\n'
            '• SharedPreferences\n\n'
            '詳細なライセンス情報については、各ライブラリの公式ドキュメントをご確認ください。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}