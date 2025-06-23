import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/providers/team_provider.dart';

class TeamSettingsScreen extends StatelessWidget {
  static const routeName = "/team-settings";

  const TeamSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final team = teamProvider.currentTeam;

    if (team == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text('${team.teamName} - Ayarlar'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSettingCard(
            title: 'Takım Adı',
            value: team.teamName,
            onTap: () => _showEditDialog(
              context,
              'Takım Adı',
              team.teamName,
              (value) => teamProvider.updateTeamInfo(teamName: value),
            ),
          ),
          _buildSettingCard(
            title: 'Davet Kodu',
            value: team.referralCode,
            onTap: () => _showReferralCode(context, team.referralCode),
          ),
          _buildSettingCard(
            title: 'Üye Sayısı',
            value: '${team.memberCount} üye',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        trailing: onTap != null ? const Icon(Icons.edit) : null,
        onTap: onTap,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Future<void> Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showReferralCode(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davet Kodu'),
        content: SelectableText(
          code,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
