import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Added this import
import '../models/challenge_model.dart';
import '../providers/challenge_provider.dart';

class AddChallengeScreen extends ConsumerStatefulWidget {
  const AddChallengeScreen({super.key});

  @override
  ConsumerState<AddChallengeScreen> createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends ConsumerState<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  int _durationInDays = 7; // Default duration
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Challenge'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Challenge Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Duration in Days',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.number,
                initialValue: _durationInDays.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of days (e.g., 30)';
                  }
                  return null;
                },
                onSaved: (value) {
                  _durationInDays = int.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Start Date: ${DateFormat.yMMMd().format(_startDate)}'),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _startDate) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newChallenge = ChallengeModel(
                      title: _title,
                      startDate: _startDate,
                      durationInDays: _durationInDays,
                    );
                    ref.read(challengeProvider.notifier).addChallenge(newChallenge);
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Create Challenge'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}