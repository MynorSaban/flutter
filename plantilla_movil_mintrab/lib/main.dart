import 'package:flutter/material.dart';
import 'package:plantilla_movil_mintrab/config/app_theme.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/button.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/customInputText.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/header_component.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColorIndex: 0).theme(),

      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: HeaderComponent(
              title: 'Notificacion de campo',
              subTitle: 'Esta es una prueb',
            ),
            body: Center(
              child: Column(
                children: [
                  Button(icon: Icons.expand),
                  CustomInputText(value: textController, label: 'texto nomral'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
