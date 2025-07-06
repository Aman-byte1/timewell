import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_model.dart';
import '../providers/timer_provider.dart';

class AddTimerDialog extends ConsumerStatefulWidget {
  final TimerModel? editingTimer;

  const AddTimerDialog({super.key, this.editingTimer});

  @override
  _AddTimerDialogState createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends ConsumerState<AddTimerDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _targetDate;
  late DateTime _startDate;
  RepeatType _repeatType = RepeatType.none;
  bool _isLocked = false;
  Color? _themeColor;
  String? _notes;
  String? _motivationalMessage;

  @override
  void initState() {
    super.initState();
    if (widget.editingTimer != null) {
      _title = widget.editingTimer!.title;
      _targetDate = widget.editingTimer!.targetDate;
      _startDate = widget.editingTimer!.startDate;
      _repeatType = widget.editingTimer!.repeatType;
      _isLocked = widget.editingTimer!.isLocked;
      _themeColor = widget.editingTimer!.themeColor;
      _notes = widget.editingTimer!.notes;
      _motivationalMessage = widget.editingTimer!.motivationalMessage;
    } else {
      _title = '';
      _targetDate = DateTime.now().add(const Duration(days: 7));
      _startDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editingTimer != null ? 'Edit Timer' : 'Create New Timer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date'),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _startDate = date);
                            }
                          },
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Date'),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _targetDate = date);
                            }
                          },
                          child: Text(
                            '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                items: RepeatType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _repeatType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _motivationalMessage,
                decoration: const InputDecoration(
                  labelText: 'Motivational Message (optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _motivationalMessage = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Theme Color:'),
                  const SizedBox(width: 10),
                  ...[
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                    null,
                  ].map((color) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: InkWell(
                        onTap: () => setState(() => _themeColor = color),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color ?? Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _themeColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              if (widget.editingTimer != null) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Lock Timer'),
                  value: _isLocked,
                  onChanged: (value) => setState(() => _isLocked = value),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newTimer = TimerModel(
                id: widget.editingTimer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: _title,
                notes: _notes,
                targetDate: _targetDate,
                startDate: _startDate,
                repeatType: _repeatType,
                isLocked: _isLocked,
                themeColor: _themeColor,
                motivationalMessage: _motivationalMessage,
              );
              
              if (widget.editingTimer != null) {
                ref.read(timerProvider.notifier).updateTimer(newTimer.id, newTimer);
              } else {
                ref.read(timerProvider.notifier).addTimer(newTimer);
              }
              
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}