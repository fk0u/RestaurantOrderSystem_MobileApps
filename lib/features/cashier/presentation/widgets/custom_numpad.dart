import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onValueChanged;
  final VoidCallback? onEnter;
  final VoidCallback? onClear;
  final bool showEnter;

  const CustomNumpad({
    super.key,
    required this.onValueChanged,
    this.onEnter,
    this.onClear,
    this.showEnter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      children: values
          .map(
            (val) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _NumpadButton(
                  label: val,
                  onTap: () => onValueChanged(val),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _NumpadButton(
              label: 'C',
              color: Colors.red.shade50,
              textColor: Colors.red,
              onTap: () => onClear?.call(),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _NumpadButton(label: '0', onTap: () => onValueChanged('0')),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _NumpadButton(
              label: '00',
              onTap: () => onValueChanged('00'),
            ),
          ),
        ),
        if (showEnter) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _NumpadButton(
                label: '↲',
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => onEnter?.call(),
              ),
            ),
          ),
        ],
        // If showEnter is false, we can add a Backspace button instead or keep 3 columns
        if (!showEnter)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _NumpadButton(
                icon: Icons.backspace_outlined,
                color: Colors.grey.shade100,
                onTap: () => onValueChanged('BACKSPACE'),
              ),
            ),
          ),
      ],
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _NumpadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color != null ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? AppColors.textPrimary,
                  ),
                )
              : Icon(icon, color: textColor ?? AppColors.textPrimary, size: 24),
        ),
      ),
    );
  }
}
