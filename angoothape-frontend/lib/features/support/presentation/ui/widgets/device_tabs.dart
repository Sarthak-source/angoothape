import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';

class DeviceTabs extends StatelessWidget {
  const DeviceTabs({super.key, 
    required this.value,
    required this.onChanged,
    required this.items,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          for (final item in items)
            InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == item.$1 ? p.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  item.$2,
                  style: body(
                    14,
                    weight: FontWeight.w600,
                    color: value == item.$1 ? p.primary : p.ink2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
