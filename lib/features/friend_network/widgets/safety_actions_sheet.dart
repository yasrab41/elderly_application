import 'package:flutter/material.dart';
import 'package:elderly_prototype_app/core/constants.dart';

Future<bool> confirmActionDialog(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message, style: const TextStyle(fontSize: 17)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.noCancelButton,
              style: const TextStyle(fontSize: 16)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(AppStrings.yesConfirmButton,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showPersonOptionsSheet(
  BuildContext context, {
  VoidCallback? onToggleTrusted,
  bool isTrusted = false,
  VoidCallback? onRemove,
  required VoidCallback onBlock,
  required VoidCallback onReport,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onToggleTrusted != null)
              ListTile(
                leading:
                    const Icon(Icons.shield_rounded, color: Color(0xFF43A047)),
                title: Text(
                  isTrusted
                      ? AppStrings.unmarkTrustedContact
                      : AppStrings.markAsTrustedContact,
                  style: const TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onToggleTrusted();
                },
              ),
            if (onRemove != null)
              ListTile(
                leading: const Icon(Icons.person_remove_rounded,
                    color: Colors.black54),
                title: Text(AppStrings.removeFriendButton,
                    style: const TextStyle(fontSize: 17)),
                onTap: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
              ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Colors.red),
              title: Text(AppStrings.blockUserButton,
                  style: const TextStyle(fontSize: 17, color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onBlock();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_rounded, color: Colors.orange),
              title: Text(AppStrings.reportUserButton,
                  style: const TextStyle(fontSize: 17)),
              onTap: () {
                Navigator.pop(ctx);
                onReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: Text(AppStrings.cancelButton,
                  style: const TextStyle(fontSize: 17)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showReportReasonSheet(
  BuildContext context,
  ValueChanged<String> onReasonSelected,
) {
  const reasons = [
    AppStrings.reportReasonInappropriate,
    AppStrings.reportReasonFakeProfile,
    AppStrings.reportReasonSpam,
    AppStrings.reportReasonOther,
  ];
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(AppStrings.reportUserButton,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final reason in reasons)
              ListTile(
                title: Text(reason, style: const TextStyle(fontSize: 17)),
                onTap: () {
                  Navigator.pop(ctx);
                  onReasonSelected(reason);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: Text(AppStrings.cancelButton,
                  style: const TextStyle(fontSize: 17)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}
