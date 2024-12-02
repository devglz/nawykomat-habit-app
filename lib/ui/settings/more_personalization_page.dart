import 'package:flutter/material.dart';

class MorePersonalizationPage extends StatelessWidget {
  const MorePersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Więcej personalizacji', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text('Więcej opcji personalizacji wkrótce!'),
      ),
    );
  }
}
