import 'package:flutter/material.dart';
import '../models/container_slot.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ContainerSlotCard extends StatelessWidget {
  final int index;
  final ContainerSlot? slot;
  final bool isActive;
  final bool isLocked;
  final VoidCallback? onTap;

  const ContainerSlotCard({
    super.key,
    required this.index,
    this.slot,
    required this.isActive,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLocked,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? cardBg : inactiveBg,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: isActive ? cardBorder : inactiveBorder,
              width: 1,
              style: isActive ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Slot number badge
              _SlotBadge(number: index + 1, isActive: isActive),
              const SizedBox(width: 12),
              // Container number field
              Expanded(
                child: _SlotField(
                  label: 'CONTAINER NO.',
                  value: slot?.containerNumber,
                  isActive: isActive,
                ),
              ),
              // Vertical divider
              Container(
                width: 1,
                height: 32,
                color: const Color(0x14FFFFFF),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Origin city field
              Expanded(
                child: _SlotField(
                  label: 'ORIGIN CITY',
                  value: slot?.originCity,
                  isActive: isActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final int number;
  final bool isActive;

  const _SlotBadge({required this.number, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? activeSlotBadgeBg : inactiveSlotBadgeBg,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: syne700(10,
            color: isActive ? accentBlue : textMuted.withOpacity(0.5)),
      ),
    );
  }
}

class _SlotField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isActive;

  const _SlotField({
    required this.label,
    this.value,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: isActive
                ? textMuted
                : textMuted.withOpacity(0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          hasValue ? value! : '—',
          style: syne600(12,
              color: hasValue
                  ? textPrimary
                  : textMuted.withOpacity(isActive ? 0.6 : 0.3)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
