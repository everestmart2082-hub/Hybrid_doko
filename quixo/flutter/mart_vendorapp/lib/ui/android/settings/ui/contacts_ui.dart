import 'package:flutter/material.dart';
import 'package:quickmartvender/drawer.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      drawer: buildAppDrawer(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Theme.of(context).primaryColorLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We’re here to help',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  iconColor: Theme.of(context).primaryColorDark,
                  title: const Text('Email Support'),
                  tileColor: Theme.of(context).primaryColorLight,
                  textColor: Theme.of(context).primaryColorDark,
                  subtitle: const Text('support@eversetmart.com'),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Phone Support'),
                  tileColor: Theme.of(context).primaryColorLight,
                  textColor: Theme.of(context).primaryColorDark,
                  iconColor: Theme.of(context).primaryColorDark,
                  subtitle: const Text('+977 977..'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
