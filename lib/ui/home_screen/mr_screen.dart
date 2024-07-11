import 'package:flutter/material.dart';

class MrScreen extends StatefulWidget {
  const MrScreen({super.key});

  @override
  State<MrScreen> createState() => MrScreenState();
}

class MrScreenState extends State<MrScreen> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return const Scaffold(
      body: Center(
        child: Text("MrScreen"),
      ),
    );
  }
}
