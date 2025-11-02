import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/gym_list_screen.dart';
import 'screens/profile_screen.dart';

import 'screens/password_gate_screen.dart';
import 'providers/gym_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/install_prompt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化（エラー時はスキップしてデモモード）
  bool firebaseInitialized = false;
  try {
    // リリースビルドでもログを出力（デバッグ用）
    print('🔥 Firebase初期化開始...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    firebaseInitialized = true;
    print('✅ Firebase初期化成功');
    print('   App name: ${Firebase.app().name}');
    
    // 匿名認証を自動実行
    try {
      print('👤 匿名認証を開始...');
      final auth = firebase_auth.FirebaseAuth.instance;
      
      // 既存ユーザーがいるか確認
      if (auth.currentUser == null) {
        print('   新規ユーザーとして匿名ログイン中...');
        final userCredential = await auth.signInAnonymously();
        print('✅ 匿名認証成功: ${userCredential.user?.uid}');
      } else {
        print('✅ 既存ユーザー: ${auth.currentUser?.uid}');
      }
    } catch (authError) {
      print('❌ 匿名認証エラー: $authError');
    }
    
  } catch (e, stackTrace) {
    // Firebase設定エラー時はデモモードで起動
    print('❌ Firebase初期化エラー（デモモードで起動）: $e');
    print('   StackTrace: $stackTrace');
  }
  
  print('🚀 アプリ起動開始 (Firebase: ${firebaseInitialized ? "有効" : "無効"})');
  
  runApp(const GymMatchApp());
}

class GymMatchApp extends StatelessWidget {
  const GymMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GymProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GYM MATCH - ジム検索アプリ',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            // β版テスト運用: パスワードゲート追加
            home: const PasswordGateScreen(
              child: MainScreen(),
            ),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showInstallPrompt = true;

  final List<Widget> _screens = [
    const MapScreen(),
    const GymListScreen(),
    const HomeScreen(),  // トレーニング記録画面（筋トレMEMO風）
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // インストールプロンプトを3秒後に表示
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showInstallPrompt = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _screens[_selectedIndex],
            // PWAインストールプロンプト
            if (_showInstallPrompt && kIsWeb)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80, // BottomNavigationBarの上に表示
                child: const InstallPrompt(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'マップ',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'ジム一覧',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: '記録',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}

/// ローディング画面
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('FitSync 起動中...'),
          ],
        ),
      ),
    );
  }
}
