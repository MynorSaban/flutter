import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
   final colors = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7Q1MCXVsrVBfwT8lZ-DhbsnqLg-DdVRuvEaA6EGZ7JKNGTVu9CrONUKs&s=10',
            ),
          ),
        ),
        title: Text(
          'bebe ♥',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colors.primaryColor  , // Cambia el color según el tema
          ),
        ),
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
                  return ( index % 2 == 0) ? HerMessageBubble() : MyMessageBubble();
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
