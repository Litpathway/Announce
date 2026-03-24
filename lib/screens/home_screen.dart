import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/container_slot.dart';
import '../models/template_model.dart';
import '../services/template_storage.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../widgets/container_slot_card.dart';
import '../widgets/hero_illustration.dart';
import 'preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ContainerSlot?> slots = [null, null, null, null];

  bool get hasAnySlot => slots.any((s) => s != null);

  List<ContainerSlot> get filledSlots =>
      slots.whereType<ContainerSlot>().toList();

  bool _isSlotActive(int index) =>
      index == 0 || slots[index - 1] != null;

  void _openSlotSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SlotInputSheet(
        index: index,
        initial: slots[index],
        onSave: (slot) {
          setState(() => slots[index] = slot);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _generate() async {
    final pool = await TemplateStorage.loadAll();
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No templates found. Please add a template first.'),
        ),
      );
      return;
    }
    final template = pool[Random().nextInt(pool.length)];
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          template: template,
          slots: filledSlots,
          pool: pool,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      body: Column(
        children: [
          const HeroIllustration(),
          Expanded(
            child: SingleChildScrollView(
              padding: screenPadding.copyWith(top: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S CONTAINERS",
                    style: syne700(11, color: textSecondary).copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 4 slot cards
                  for (int i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(height: slotGap),
                    ContainerSlotCard(
                      index: i,
                      slot: slots[i],
                      isActive: _isSlotActive(i),
                      isLocked: !_isSlotActive(i),
                      onTap: () => _openSlotSheet(i),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Slots unlock as you fill each one',
                      style: dmSans400(9, color: textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Generate button
                  _GenerateButton(
                    enabled: hasAnySlot,
                    onTap: _generate,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _GenerateButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF4F9CF9), Color(0xFF2D7FE8)],
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF4F9CF9).withOpacity(0.6),
                      const Color(0xFF2D7FE8).withOpacity(0.6)
                    ],
                  ),
            borderRadius: btnRadius,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F9CF9).withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '✦ Generate Announcement',
            style: syne700(13),
          ),
        ),
      ),
    );
  }
}

class _SlotInputSheet extends StatefulWidget {
  final int index;
  final ContainerSlot? initial;
  final void Function(ContainerSlot) onSave;

  const _SlotInputSheet({
    required this.index,
    this.initial,
    required this.onSave,
  });

  @override
  State<_SlotInputSheet> createState() => _SlotInputSheetState();
}

class _SlotInputSheetState extends State<_SlotInputSheet> {
  late final TextEditingController _containerCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _containerCtrl = TextEditingController(
        text: widget.initial?.containerNumber ?? '');
    _cityCtrl = TextEditingController(
        text: widget.initial?.originCity ?? '');
  }

  @override
  void dispose() {
    _containerCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final containerNo = _containerCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    if (containerNo.isEmpty || city.isEmpty) return;
    widget.onSave(ContainerSlot(
      containerNumber: containerNo.toUpperCase(),
      originCity: city,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Slot ${widget.index + 1}',
                  style: syne700(16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _inputField(
              label: 'CONTAINER NO.',
              controller: _containerCtrl,
              hint: 'e.g. GZ000229',
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                _UpperCaseFormatter(),
              ],
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),
            _inputField(
              label: 'ORIGIN CITY',
              controller: _cityCtrl,
              hint: 'e.g. Guangzhou',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: btnRadius,
                  ),
                ),
                child: Text('Save Slot', style: syne700(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    List<TextInputFormatter>? formatters,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          inputFormatters: formatters,
          textCapitalization: textCapitalization,
          style: syne600(14),
          cursorColor: accentBlue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: syne600(14, color: textMuted.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0x0AFFFFFF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x17FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x17FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: accentBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
