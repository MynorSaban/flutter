import 'package:flutter/material.dart';

class CounterScreens extends StatefulWidget {
  const CounterScreens({super.key});

  @override
  State<CounterScreens> createState() => _CounterScreensState();
}

class _CounterScreensState extends State<CounterScreens> {
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const  Center( child: Text('Counter Text')),
      ),
        body: Center(child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // para centrar en toda la pantalla del dispositivo
            children:  [
              Text('$clickCounter', style: TextStyle( fontSize: 160, fontWeight: FontWeight.w100),),
              Text(
                clickCounter == 1 ? 'Click' : 'Clicks', 
                style: const TextStyle(fontSize: 25),
              )
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){
          clickCounter++;
          setState(() {
            
          });
        } ,
        child: const Icon( Icons.plus_one),   
        ),
      );
  }
}