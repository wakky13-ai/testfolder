import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/app_state.dart';
import 'models/question_model.dart';
import 'services/database_service.dart';
import 'services/question_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // データベースの初期化
    await DatabaseService().init();
    
    // 問題データの読み込み
    await QuestionService().loadQuestions();
    
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => QuestionModel()),
      ],
      child: MaterialApp(
        title: '宅建士試験対策アプリ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'エラー',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('エラー'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'アプリの初期化に失敗しました',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'アプリを再起動してください',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}