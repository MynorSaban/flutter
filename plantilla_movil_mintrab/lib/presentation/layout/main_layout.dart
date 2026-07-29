import 'package:flutter/material.dart';
import '../widgets/ui/header_component.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget body;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.subTitle,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderComponent(title: title, subTitle: subTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
