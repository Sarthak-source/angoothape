import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/palette.dart';

class AuthDigitRow extends StatelessWidget {
  const AuthDigitRow({
    super.key,
    required this.controller,
    required this.focus,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return GestureDetector(
      onTap: () => focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: List.generate(6, (i) {
              final ch = i < controller.text.length ? controller.text[i] : '';
              final cur = i == controller.text.length;
              return Expanded(
                child: Container(
                  height: 52,
                  margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cur ? p.primarySoft : p.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cur ? p.primary : p.line,
                      width: 1.5,
                    ),
                  ),
                  child: Text(ch, style: display(22, color: p.ink)),
                ),
              );
            }),
          ),
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focus,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
