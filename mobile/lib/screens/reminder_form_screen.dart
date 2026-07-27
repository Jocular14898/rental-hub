import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';

class ReminderFormScreen extends StatefulWidget {
  final Reminder? reminder;
  const ReminderFormScreen({super.key, this.reminder});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _dueDate;
  bool _loading = false;
  bool get _isEdit => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    if (r != null) {
      _nameCtrl.text = r.tenantName;
      _phoneCtrl.text = r.tenantPhone ?? '';
      _unitCtrl.text = r.unitNumber ?? '';
      _amountCtrl.text = r.rentAmount?.toStringAsFixed(0) ?? '';
      _notesCtrl.text = r.notes ?? '';
      _dueDate = DateTime.tryParse(r.dueDate) ?? DateTime.now().add(const Duration(days: 30));
    } else {
      _dueDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final api = context.read<ApiService>();
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await api.updateReminder(
          widget.reminder!.id,
          status: widget.reminder!.status,
          tenantName: _nameCtrl.text,
          tenantPhone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
          unitNumber: _unitCtrl.text.isNotEmpty ? _unitCtrl.text : null,
          rentAmount: _amountCtrl.text.isNotEmpty ? double.parse(_amountCtrl.text) : null,
          dueDate: _dueDate.toIso8601String().split('T')[0],
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        );
      } else {
        await api.createReminder(
          tenantName: _nameCtrl.text,
          tenantPhone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
          unitNumber: _unitCtrl.text.isNotEmpty ? _unitCtrl.text : null,
          rentAmount: _amountCtrl.text.isNotEmpty ? double.parse(_amountCtrl.text) : null,
          dueDate: _dueDate.toIso8601String().split('T')[0],
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Reminder updated' : 'Reminder created')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _unitCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Reminder' : 'Add Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tenant Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tenant Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unit Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.door_front_door),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount (KSh)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dueDate.toIso8601String().split('T')[0],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEdit ? 'Update Reminder' : 'Create Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
