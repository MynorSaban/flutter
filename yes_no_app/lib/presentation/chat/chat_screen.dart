import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/174751586?s=400&u=fb8c49982359a2e78406be49717ea775d52d9afe&v=4',
            ),
          ),
        ),
        title: const Text('bebe ♥'),
        centerTitle: false,
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // para que no se superponga con la barra de estado
      left: false, // para no guardar el especio en la camara
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ), // para que no quede pegado a los bordes lado derecho
        child: Column(
          spacing: 3,

          children: [
            Expanded(
              child: ListView.builder(
              
                itemBuilder: (context, index) {
                  return Text('Hola mundo : $index');
                },
              ),
            ),
            Text('Hola mundo'),
          ],
        ),
      ),
    );
  }
}
