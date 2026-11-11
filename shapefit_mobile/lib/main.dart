import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/active_workout_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ShapeFitApp());
}

class ShapeFitApp extends StatelessWidget {
  const ShapeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActiveWorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'ShapeFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            secondary: Colors.amberAccent,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
