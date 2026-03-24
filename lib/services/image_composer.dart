import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/container_slot.dart';
import '../models/template_model.dart';

class ImageComposer {
  /// Renders the template image with the text overlay composited on top.
  /// Returns PNG bytes of the final image.
  static Future<Uint8List> compose({
    required TemplateModel template,
    required List<ContainerSlot> slots,
  }) async {
    // 1. Load the template image from disk
    final File imageFile = File(template.imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image bgImage = frame.image;

    final double imgW = bgImage.width.toDouble();
    final double imgH = bgImage.height.toDouble();

    // 2. Determine overlay pixel position from fractional coordinates
    final double overlayX = template.textX * imgW;
    final double overlayY = template.textY * imgH;
    final double overlayW = template.textWidth * imgW;

    // 3. Composite: draw background then text overlay using Canvas
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, imgW, imgH),
    );

    // Draw background image
    canvas.drawImage(bgImage, Offset.zero, Paint());

    // Draw text overlay box
    _drawTextOverlay(
      canvas: canvas,
      slots: slots,
      x: overlayX,
      y: overlayY,
      width: overlayW,
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image composited =
        await picture.toImage(imgW.toInt(), imgH.toInt());

    // 4. Encode to PNG
    final ByteData? byteData =
        await composited.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('Failed to encode image');
    return byteData.buffer.asUint8List();
  }

  static void _drawTextOverlay({
    required Canvas canvas,
    required List<ContainerSlot> slots,
    required double x,
    required double y,
    required double width,
  }) {
    const double paddingH = 14;
    const double paddingV = 11;
    const double lineSpacing = 4;
    const double headerFontSize = 8;
    const double slotFontSize = 12;
    const double cityFontSize = 9;
    const double footerFontSize = 10;
    const double dividerH = 1;

    // Measure heights
    final double headerH = headerFontSize + lineSpacing;
    final double slotH = slotFontSize + lineSpacing;
    final double footerH = footerFontSize + lineSpacing;
    final double totalH = paddingV * 2 +
        headerH +
        dividerH +
        (slotH * slots.length) +
        dividerH +
        footerH;

    // Draw background box
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, width, totalH),
      topLeft: const Radius.circular(13),
      topRight: const Radius.circular(13),
      bottomRight: const Radius.circular(13),
      bottomLeft: Radius.zero,
    );

    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xE108121A),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x0FFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    double cy = y + paddingV;

    // Header text
    _drawText(
      canvas: canvas,
      text: 'CONTAINERS — OFFLOADING TODAY',
      x: x + paddingH,
      y: cy,
      fontSize: headerFontSize,
      color: const Color(0x4DFFFFFF),
      fontWeight: FontWeight.w700,
    );
    cy += headerH;

    // Divider
    canvas.drawLine(
      Offset(x + paddingH, cy),
      Offset(x + width - paddingH, cy),
      Paint()
        ..color = const Color(0x0DFFFFFF)
        ..strokeWidth = dividerH,
    );
    cy += dividerH + 3;

    // Slot rows
    for (final slot in slots) {
      _drawText(
        canvas: canvas,
        text: slot.containerNumber,
        x: x + paddingH,
        y: cy,
        fontSize: slotFontSize,
        color: const Color(0xFFF0F4FF),
        fontWeight: FontWeight.w800,
      );

      // City label (right of container number)
      final numWidth = _measureText(
        slot.containerNumber,
        slotFontSize,
        FontWeight.w800,
      );
      _drawText(
        canvas: canvas,
        text: slot.originCity.toUpperCase(),
        x: x + paddingH + numWidth + 8,
        y: cy + (slotFontSize - cityFontSize) / 2,
        fontSize: cityFontSize,
        color: const Color(0xFF4F9CF9),
        fontWeight: FontWeight.w600,
      );

      cy += slotH;
    }

    // Divider
    canvas.drawLine(
      Offset(x + paddingH, cy),
      Offset(x + width - paddingH, cy),
      Paint()
        ..color = const Color(0x0DFFFFFF)
        ..strokeWidth = dividerH,
    );
    cy += dividerH + 5;

    // Footer text
    _drawText(
      canvas: canvas,
      text: 'Is out and offloading today',
      x: x + paddingH,
      y: cy,
      fontSize: footerFontSize,
      color: const Color(0x8CFFFFFF),
      fontWeight: FontWeight.w400,
    );
  }

  static void _drawText({
    required Canvas canvas,
    required String text,
    required double x,
    required double y,
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);

    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 4096));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  static double _measureText(
      String text, double fontSize, FontWeight fontWeight) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    )
      ..addText(text);
    final para = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 4096));
    return para.maxIntrinsicWidth;
  }
}
