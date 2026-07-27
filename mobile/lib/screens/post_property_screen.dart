import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';
import '../services/api_service.dart';

class PostPropertyScreen extends StatefulWidget {
  final Property? property;
  const PostPropertyScreen({super.key, this.property});

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _securityCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  String _houseType = 'apartment';
  bool _parking = false;
  bool _waterAvailable = false;
  List<File> _photos = [];
  bool _loading = false;
  bool get _isEdit => widget.property != null;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    if (p != null) {
      _titleCtrl.text = p.title;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _locationCtrl.text = p.location;
      _bedroomsCtrl.text = p.bedrooms.toString();
      _phoneCtrl.text = p.contactPhone;
      _descCtrl.text = p.description ?? '';
      _securityCtrl.text = p.securityDetails ?? '';
      _latCtrl.text = p.latitude?.toString() ?? '';
      _lngCtrl.text = p.longitude?.toString() ?? '';
      _houseType = p.houseType ?? 'apartment';
      _parking = p.parking;
      _waterAvailable = p.waterAvailable;
    }
  }

  Future<void> _pickPhoto() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;
    final x = await _picker.pickImage(source: src);
    if (x != null) setState(() => _photos.add(File(x.path)));
  }

  void _removePhoto(int i) => setState(() => _photos.removeAt(i));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final api = context.read<ApiService>();
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await api.updateProperty(
          widget.property!.id,
          title: _titleCtrl.text,
          price: double.parse(_priceCtrl.text),
          location: _locationCtrl.text,
          bedrooms: int.parse(_bedroomsCtrl.text),
          contactPhone: _phoneCtrl.text,
          houseType: _houseType,
          description: _descCtrl.text,
          securityDetails: _securityCtrl.text,
          parking: _parking,
          waterAvailable: _waterAvailable,
          latitude: _latCtrl.text.isNotEmpty ? double.parse(_latCtrl.text) : null,
          longitude: _lngCtrl.text.isNotEmpty ? double.parse(_lngCtrl.text) : null,
        );
      } else {
        await api.createProperty(
          title: _titleCtrl.text,
          price: double.parse(_priceCtrl.text),
          location: _locationCtrl.text,
          bedrooms: int.parse(_bedroomsCtrl.text),
          contactPhone: _phoneCtrl.text,
          houseType: _houseType,
          description: _descCtrl.text,
          securityDetails: _securityCtrl.text,
          parking: _parking,
          waterAvailable: _waterAvailable,
          latitude: _latCtrl.text.isNotEmpty ? double.parse(_latCtrl.text) : null,
          longitude: _lngCtrl.text.isNotEmpty ? double.parse(_lngCtrl.text) : null,
          photos: _photos.isNotEmpty ? _photos : null,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Property updated!' : 'Property posted successfully!')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _bedroomsCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _securityCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Property' : 'Post Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'House Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Rent (KSh) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bedroomsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bedrooms *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bed),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+254 ',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _houseType,
                decoration: const InputDecoration(
                  labelText: 'House Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                items: const [
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'maisonette', child: Text('Maisonette')),
                  DropdownMenuItem(value: 'bungalow', child: Text('Bungalow')),
                  DropdownMenuItem(value: 'townhouse', child: Text('Townhouse')),
                ],
                onChanged: (v) => setState(() => _houseType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _securityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Security Details',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      const Text('Parking'),
                      Switch(value: _parking, onChanged: (v) => setState(() => _parking = v)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      const Text('Water'),
                      Switch(value: _waterAvailable, onChanged: (v) => setState(() => _waterAvailable = v)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        hintText: '-1.392',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        hintText: '36.755',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Photos', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._photos.asMap().entries.map(
                        (e) => Stack(
                          children: [
                            Image.file(e.value, width: 80, height: 80, fit: BoxFit.cover),
                            Positioned(
                              top: 0, right: 0,
                              child: GestureDetector(
                                onTap: () => _removePhoto(e.key),
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.add_photo_alternate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEdit ? 'Update Property' : 'Post Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
