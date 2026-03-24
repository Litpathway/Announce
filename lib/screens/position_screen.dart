import 'dart:io';

import 'package:flutter/material.dart';

import '../models/container_slot.dart';
import '../models/template_model.dart';
import '../services/template_storage.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/text_overlay_widget.dart';

class PositionScreen extends StatefulWidget {
  final TemplateModel template;
  final bool isNew;

  const PositionScreen({
    super.key,
    required this.template,
    required this.isNew,
  });

  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
  late double _x; // fractional
  late double _y;
  late double _width; // fractional

  static const double _previewHeight = 235.0;
  static const double _minWidth = 80.0;

  // Sample preview slots
  static final List<ContainerSlot> _previewSlots = const [
    ContainerSlot(containerNumber: 'GZ000229', originCity: 'Guangzhou'),
    ContainerSlot(containerNumber: 'SL000410', originCity: 'Shanghai'),
    ContainerSlot(containerNumber: 'YW000118', originCity: 'Yiwu'),
  ];

  @override
  void initState() {
    super.initState();
    _x = widget.template.textX;
    _y = widget.template.textY;
    _width = widget.template.textWidth;
  }

  Future<void> _save(double imageDisplayW, double imageDisplayH) async {
    final saved = widget.template.copyWith(
      textX: _x.clamp(0.0, 1.0),
      textY: _y.clamp(0.0, 1.0),
      textWidth: _width.clamp(0.0, 1.0),
    );

    if (widget.isNew) {
      await TemplateStorage.save(saved);
    } else {
      await TemplateStorage.update(saved);
    }

    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(
        backgroundColor: navyBg,
        elevation: 0,
        leading: const BackButton(color: textPrimary),
        title: Text(
          widget.isNew ? 'Position Text Box' : 'Edit Position',
          style: syne700(16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Image preview with draggable overlay
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final displayW = constraints.maxWidth;
                  return _ImagePreview(
                    template: widget.template,
                    displayW: displayW,
                    displayH: _previewHeight,
                    fracX: _x,
                    fracY: _y,
                    fracW: _width,
                    previewSlots: _previewSlots,
                    onMove: (dx, dy) {
                      setState(() {
                        _x = (_x + dx / displayW).clamp(0.0, 1.0);
                        _y = (_y + dy / _previewHeight).clamp(0.0, 1.0);
                      });
                    },
                    onResize: (dw) {
                      final newPx = (_width * displayW + dw)
                          .clamp(_minWidth, displayW.toDouble());
                      setState(() => _width = newPx / displayW);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Coordinate readout
              _CoordCard(x: _x, y: _y, w: _width),
              const SizedBox(height: 20),
              // Save button
              LayoutBuilder(builder: (ctx, constraints) {
                final displayW = constraints.maxWidth;
                return _SaveButton(
                  onTap: () => _save(displayW, _previewHeight),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final TemplateModel template;
  final double displayW;
  final double displayH;
  final double fracX;
  final double fracY;
  final double fracW;
  final List<ContainerSlot> previewSlots;
  final void Function(double dx, double dy) onMove;
  final void Function(double dw) onResize;

  const _ImagePreview({
    required this.template,
    required this.displayW,
    required this.displayH,
    required this.fracX,
    required this.fracY,
    required this.fracW,
    required this.previewSlots,
    required this.onMove,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    final boxX = fracX * displayW;
    final boxY = fracY * displayH;
    final boxW = (fracW * displayW).clamp(80.0, displayW);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: displayW,
        height: displayH,
        child: Stack(
          children: [
            // Template image
            Positioned.fill(
              child: Image.file(
                File(template.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: navyCard),
              ),
            ),
            // Draggable text box
            Positioned(
              left: boxX,
              top: boxY,
              child: GestureDetector(
                onPanUpdate: (d) => onMove(d.delta.dx, d.delta.dy),
                child: SizedBox(
                  width: boxW,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Text box container
                      Container(
                        width: boxW,
                        decoration: BoxDecoration(
                          color: const Color(0x124F9CF9),
                          border: Border.all(
                            color: accentBlue.withOpacity(0.7),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pill label
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 6, top: -8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DRAG TO POSITION',
                                  style: syne700(7),
                                ),
                              ),
                            ),
                            // Preview content
                            TextOverlayWidget(
                              slots: previewSlots,
                              width: boxW,
                            ),
                          ],
                        ),
                      ),
                      // Corner handles (decorative)
                      _cornerHandle(top: 0, left: 0),
                      _cornerHandle(top: 0, right: 0),
                      _cornerHandle(bottom: 0, left: 0),
                      // Resize handle (bottom-right)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onPanUpdate: (d) => onResize(d.delta.dx),
                          child: Container(
                            width: 9,
                            height: 9,
                            color: accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerHandle({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(width: 5, height: 5, color: accentBlue),
    );
  }
}

class _CoordCard extends StatelessWidget {
  final double x;
  final double y;
  final double w;

  const _CoordCard({required this.x, required this.y, required this.w});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x17FFFFFF)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _coord('X', x.toStringAsFixed(2)),
          _vDivider(),
          _coord('Y', y.toStringAsFixed(2)),
          _vDivider(),
          _coord('W', w.toStringAsFixed(2)),
          _vDivider(),
          _coord('H', 'auto'),
        ],
      ),
    );
  }

  Widget _coord(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              color: textMuted,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: syne700(11, color: accentBlue)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 28,
        color: const Color(0x17FFFFFF),
      );
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7DD4BB), Color(0xFF2AAA88)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text('✓ Save Position & Add Template', style: syne700(12)),
      ),
    );
  }
}
