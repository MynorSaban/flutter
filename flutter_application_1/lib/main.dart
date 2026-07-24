
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/counter/counter_functions_screens.dart';
import 'package:flutter_application_1/presentation/screens/counter/counter_screens.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Siempre se debe de colocar un key como identificador
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        tooltipTheme: TooltipThemeData(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold, // Hace la letra más llamativa
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12), // Bordes redondeados modernos estilo iOS/Material3
          ),
        ),
      ),
      home: const CounterFunctionsScreens(),
    );
  }
}
