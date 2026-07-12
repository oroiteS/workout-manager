// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_manager/screens/today_training_screen.dart';
import 'package:workout_manager/screens/template_screen.dart';
import 'package:workout_manager/screens/chart_screen.dart';
import 'package:workout_manager/screens/history_screen.dart';
import 'package:workout_manager/screens/catalog_screen.dart';
import 'package:workout_manager/providers/workout_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');
  runApp(const ProviderScope(child: WorkoutApp()));
}

class WorkoutApp extends ConsumerWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: '训练记录',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/chart') {
          return MaterialPageRoute(
            builder: (_) => const ChartScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    TodayTrainingScreen(),
    TemplateScreen(),
    HistoryScreen(),
    CatalogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(catalogBootstrapProvider);

    return Column(
      children: [
        Expanded(child: _screens[_currentIndex]),
        NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: '今日训练',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: '周模板',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: '记录',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: '示意图',
            ),
          ],
        ),
      ],
    );
  }
}
