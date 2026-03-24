import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../models/container_slot.dart';
import '../models/template_model.dart';
import '../services/image_composer.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PreviewScreen extends StatefulWidget {
  final TemplateModel template;
  final List<ContainerSlot> slots;
  final List<TemplateModel> pool;

  const PreviewScreen({
    super.key,
    required this.template,
    required this.slots,
    required this.pool,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Uint8List? _imageBytes;
  bool _generating = false;
  String? _error;
  late TemplateModel _currentTemplate;
  int? _usedIndex;

  @override
  void initState() {
    super.initState();
    _currentTemplate = widget.template;
    _usedIndex = widget.pool.indexOf(widget.template);
    _generate(_currentTemplate);
  }

  Future<void> _generate(TemplateModel template) async {
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final bytes = await ImageComposer.compose(
        template: template,
        slots: widget.slots,
      );
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _generating = false;
          _currentTemplate = template;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _generating = false;
        });
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_imageBytes == null) return;
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gallery permission denied.')),
            );
          }
          return;
        }
      }
      await Gal.putImageBytes(
        _imageBytes!,
        name: 'announce_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to gallery ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _tryAnother() async {
    if (widget.pool.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only one template available.')),
      );
      return;
    }
    final rng = Random();
    int newIndex;
    do {
      newIndex = rng.nextInt(widget.pool.length);
    } while (newIndex == _usedIndex);
    _usedIndex = newIndex;
    await _generate(widget.pool[newIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(
        backgroundColor: navyBg,
        elevation: 0,
        leading: const BackButton(color: textPrimary),
        title: Text('Preview', style: syne700(16)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Generated image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 255,
                  child: _generating
                      ? const Center(
                          child: CircularProgressIndicator(color: accentBlue),
                        )
                      : _error != null
                          ? Center(
                              child: Text(
                                'Error: $_error',
                                style: dmSans400(12, color: textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(color: navyCard),
                ),
              ),
              const SizedBox(height: 20),
              // Template name
              Center(
                child: Text(
                  _currentTemplate.name,
                  style: dmSans400(12, color: textSecondary),
                ),
              ),
              const Spacer(),
              // Action buttons
              _ActionButton(
                label: '↓ Save to Gallery',
                gradient: const [Color(0xFF7DD4BB), Color(0xFF2AAA88)],
                onTap: _saveToGallery,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '↻ Try Another Template',
                gradient: [
                  accentBlue.withOpacity(0.8),
                  const Color(0xFF2D7FE8).withOpacity(0.8),
                ],
                onTap: _tryAnother,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(label, style: syne700(13)),
      ),
    );
  }
}
