import 'package:flutter/material.dart';

class CounterFunctionsScreens extends StatefulWidget {
  const CounterFunctionsScreens({super.key});

  @override
  State<CounterFunctionsScreens> createState() =>
      _CounterFunctionsScreensState();
}

class _CounterFunctionsScreensState extends State<CounterFunctionsScreens> {
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Counter Functions')),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                clickCounter = 0;
              });
            },
            icon: Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // para centrar en toda la pantalla del dispositivo
          children: [
            Text(
              '$clickCounter',
              style: TextStyle(fontSize: 160, fontWeight: FontWeight.w100),
            ),
            Text(
              clickCounter == 1 ? 'Click' : 'Clicks',
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          CustomButton(
            icon: Icons.refresh_outlined,
            onPressed: () {
              clickCounter = 0;
              setState(() {});
            },
          ),
          CustomButton(
            icon: Icons.plus_one,
            onPressed: () {
              clickCounter++;
              setState(() {});
            },
          ),
          CustomButton(
            icon: Icons.exposure_minus_1,
            onPressed: () {
              if (clickCounter == 0) return;
              clickCounter--;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CustomButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      enableFeedback: true,
      elevation: 10,      
      shape: const StadiumBorder(),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
