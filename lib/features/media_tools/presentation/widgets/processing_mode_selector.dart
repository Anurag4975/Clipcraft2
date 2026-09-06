import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/di/injection_container.dart';
import '../../../../core/enums/processing_mode.dart';
import '../../../../core/services/usage_service.dart';

class ProcessingModeSelector extends StatefulWidget {
  final ProcessingMode selected;
  final ValueChanged<ProcessingMode> onChanged;

  const ProcessingModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<ProcessingModeSelector> createState() => _ProcessingModeSelectorState();
}

class _ProcessingModeSelectorState extends State<ProcessingModeSelector> {
  int? _remainingCloudUses;
  int? _dailyLimit;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final usageService = getIt<UsageService>();
    final remaining = await usageService.getRemainingCloudUses();
    final limit = await usageService.getDailyLimit();
    if (mounted)
      setState(() {
        _remainingCloudUses = remaining;
        _dailyLimit = limit;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOption(
          mode: ProcessingMode.onDevice,
          title: 'On-Device (Free)',
          subtitle: 'Fully offline. Choose your model size. No usage limits.',
          icon: Icons.smartphone_rounded,
        ),
        const SizedBox(height: 12),
        _buildOption(
          mode: ProcessingMode.cloud,
          title: 'Cloud (Faster)',
          subtitle: _dailyLimit == null
              ? 'Loading...'
              : '$_remainingCloudUses of $_dailyLimit free analyses left today',
          icon: Icons.cloud_rounded,
          trailing: (_remainingCloudUses == 0)
              ? TextButton(
                  onPressed: () {
                    // TODO: navigate to your pricing/upgrade page
                  },
                  child: const Text('Upgrade'),
                )
              : null,
          disabled: _remainingCloudUses == 0,
        ),
      ],
    );
  }

  Widget _buildOption({
    required ProcessingMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    bool disabled = false,
  }) {
    final isSelected = widget.selected == mode;
    return InkWell(
      onTap: disabled ? null : () => widget.onChanged(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: disabled ? AppTheme.textMuted : AppTheme.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: disabled
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: disabled
                            ? AppTheme.textMuted
                            : AppTheme.textSecondary,
                      )),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
