import 'package:flutter/material.dart';

class UnknownRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('400'),
          SizedBox(height: 15),
          Text('Endereço Inválido'),
        ],
      ),
    );
  }
}
