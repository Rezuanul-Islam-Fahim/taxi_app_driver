import 'package:flutter/material.dart';

class CashEarnedScreen extends StatelessWidget {
  const CashEarnedScreen({Key? key}) : super(key: key);

  static const String route = '/cash-earned';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Earned'),
        backgroundColor: Colors.black,
      ),
    );
  }
}
