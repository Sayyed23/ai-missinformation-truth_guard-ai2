import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:truth_guard_ai/core/theme/app_colors.dart';

class RegionSelector extends StatefulWidget {
  const RegionSelector({super.key});

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  String _selectedRegion = 'Global';

  final List<String> _regions = [
    'Global',
    'North America',
    'Europe',
    'Asia Pacific',
    'Latin America',
    'Middle East & Africa',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Select Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _regions.map((region) {
              final isSelected = _selectedRegion == region;
              return FilterChip(
                label: Text(region),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedRegion = region;
                  });
                  // In a real app, we would pass this selection back
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      Navigator.pop(context, region);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
