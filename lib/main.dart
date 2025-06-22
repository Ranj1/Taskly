import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'data/database/task_database.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final taskDatabase = TaskDatabase();

  runApp(MyApp(taskDatabase: taskDatabase));
}

class MyApp extends StatelessWidget {
  final TaskDatabase taskDatabase;

  const MyApp({Key? key, required this.taskDatabase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(db: taskDatabase)..add(LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Taskly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:  HomePage(),
      ),
    );
  }
}
