import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../models/template_model.dart';
import '../services/template_storage.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'position_screen.dart';

class TemplatePoolScreen extends StatefulWidget {
  const TemplatePoolScreen({super.key});

  @override
  State<TemplatePoolScreen> createState() => _TemplatePoolScreenState();
}

class _TemplatePoolScreenState extends State<TemplatePoolScreen> {
  List<TemplateModel> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final templates = await TemplateStorage.loadAll();
    if (mounted) setState(() { _templates = templates; _loading = false; });
  }

  Future<void> _addTemplate() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Copy the image to app documents for persistence
    final appDir = await getApplicationDocumentsDirectory();
    final templatesDir = Directory(p.join(appDir.path, 'templates'));
    await templatesDir.create(recursive: true);
    final fileName = '${const Uuid().v4()}${p.extension(picked.path)}';
    final destPath = p.join(templatesDir.path, fileName);
    await File(picked.path).copy(destPath);

    final rawName = p.basenameWithoutExtension(picked.path);
    final template = TemplateModel(
      id: const Uuid().v4(),
      imagePath: destPath,
      name: rawName.length > 20 ? rawName.substring(0, 20) : rawName,
      textX: 0.05,
      textY: 0.60,
      textWidth: 0.55,
      addedAt: DateTime.now(),
    );

    if (!mounted) return;
    final result = await Navigator.of(context).push<TemplateModel>(
      MaterialPageRoute(
        builder: (_) => PositionScreen(template: template, isNew: true),
      ),
    );
    if (result != null) await _load();
  }

  Future<void> _editTemplate(TemplateModel template) async {
    final result = await Navigator.of(context).push<TemplateModel>(
      MaterialPageRoute(
        builder: (_) => PositionScreen(template: template, isNew: false),
      ),
    );
    if (result != null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      body: SafeArea(
        child: Padding(
          padding: screenPadding.copyWith(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Templates', style: syne800(19)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_templates.length}',
                      style: syne700(12, color: accentBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: accentBlue))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _templates.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == _templates.length) {
                            return _AddTemplateTile(onTap: _addTemplate);
                          }
                          return _TemplateTile(
                            template: _templates[i],
                            onTap: () => _editTemplate(_templates[i]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback onTap;

  const _TemplateTile({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = template.addedAt;
    final dateStr =
        '${months[d.month - 1]} ${d.day}, ${d.year}';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image background
            Image.file(
              File(template.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: navyCard,
                child: const Icon(Icons.image_not_supported,
                    color: textMuted, size: 32),
              ),
            ),
            // Dark gradient at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 55,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD0B0F1E)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      template.name,
                      style: syne700(9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(dateStr,
                        style: dmSans400(8, color: textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTemplateTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTemplateTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentBlue.withOpacity(0.22),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: accentBlue, size: 20),
            ),
            const SizedBox(height: 8),
            Text('Add Template', style: syne600(11, color: accentBlue)),
          ],
        ),
      ),
    );
  }
}
