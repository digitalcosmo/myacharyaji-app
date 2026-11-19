import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Date of Birth'), readOnly: true, onTap: () { /* TODO: date picker */ }),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Time of Birth'), readOnly: true, onTap: () { /* TODO: time picker */ }),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Place of Birth')),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () { /* TODO: save profile */ }, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
