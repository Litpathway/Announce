import 'package:flutter/material.dart';
import '../models/container_slot.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class TextOverlayWidget extends StatelessWidget {
  final List<ContainerSlot> slots;
  final double width;

  const TextOverlayWidget({
    super.key,
    required this.slots,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xE108121A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
          bottomRight: Radius.circular(13),
          bottomLeft: Radius.zero,
        ),
        border: Border.all(color: const Color(0x0FFFFFFF), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTAINERS — OFFLOADING TODAY',
            style: syne700(8, color: const Color(0x4DFFFFFF)),
          ),
          const SizedBox(height: 5),
          _divider(),
          ...slots.map((slot) => _slotRow(slot)),
          _divider(),
          const SizedBox(height: 5),
          Text(
            'Is out and offloading today',
            style: dmSans400(10, color: const Color(0x8CFFFFFF)),
          ),
        ],
      ),
    );
  }

  Widget _slotRow(ContainerSlot slot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            slot.containerNumber,
            style: syne800(12),
          ),
          const SizedBox(width: 8),
          Text(
            slot.originCity.toUpperCase(),
            style: syne600(9, color: accentBlue),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: const Color(0x0DFFFFFF),
      margin: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}
