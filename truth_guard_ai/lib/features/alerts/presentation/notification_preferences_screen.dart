import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:truth_guard_ai/core/theme/app_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _viralAlerts = true;
  bool _verificationUpdates = true;
  bool _trendingTopics = false;
  bool _emailDigest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Push Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Viral Misinformation Alerts',
            'Get notified when high-velocity misinformation is detected in your region.',
            _viralAlerts,
            (value) => setState(() => _viralAlerts = value),
            LucideIcons.alertTriangle,
          ),
          _buildSwitchTile(
            'Verification Updates',
            'Status updates on content you submitted for verification.',
            _verificationUpdates,
            (value) => setState(() => _verificationUpdates = value),
            LucideIcons.checkCircle,
          ),
          _buildSwitchTile(
            'Trending Topics',
            'Daily summary of trending narratives.',
            _trendingTopics,
            (value) => setState(() => _trendingTopics = value),
            LucideIcons.trendingUp,
          ),
          const Divider(height: 32),
          const Text(
            'Email Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Weekly Digest',
            'A summary of your activity and key misinformation trends.',
            _emailDigest,
            (value) => setState(() => _emailDigest = value),
            LucideIcons.mail,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        title: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8, left: 32),
          child: Text(subtitle),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
