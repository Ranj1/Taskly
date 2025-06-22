import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'data/database/task_database.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskDatabase = TaskDatabase();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MyApp(taskDatabase: taskDatabase),
    ),
  );
}

class MyApp extends StatelessWidget {
  final TaskDatabase taskDatabase;

  MyApp({Key? key, required this.taskDatabase}) : super(key: key);

  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return BlocProvider(
          create: (_) => TaskBloc(db: taskDatabase)..add(LoadTasks()),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Taskly',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
                background: Color(0xFFF5F6FA),
                surface: Colors.white,
                onBackground: Colors.black87,
                onPrimary: Colors.white,
                primary: Colors.blue,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                titleTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.blue,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              scaffoldBackgroundColor: const Color(0xFFF5F6FA),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.dark,
                background: Color(0xFF121212),
                surface: Color(0xFF1E1E1E),
                onBackground: Colors.white70,
                onPrimary: Colors.black,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                foregroundColor: Colors.white70,

                elevation: 0,
              ),
              scaffoldBackgroundColor: Color(0xFF121212),
              useMaterial3: true,
            ),
            themeMode: themeMode,
            home: HomePage(
              onToggleTheme: () {
                themeNotifier.value = themeNotifier.value == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
          ),
        );
      },
    );
  }
}
