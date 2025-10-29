import 'package:flutter/material.dart';

class CreateRequestScreen extends StatefulWidget {
  final String? preselectedCategory;

  const CreateRequestScreen({
    super.key,
    this.preselectedCategory,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Help Request'),
      ),
      body: const Center(
        child: Text('Create Request Screen - To be implemented'),
      ),
    );
  }
}
