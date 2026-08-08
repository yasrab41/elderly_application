import 'package:flutter/material.dart';
import '../data/models/friend_profile_model.dart';

class FriendPersonCard extends StatelessWidget {
  final int avatarId;
  final String name;
  final String? subtitle;
  final List<String>? tags;
  final String? trailingLabel;
  final bool isTrusted;
  final List<Widget> actions;
  final VoidCallback? onMoreOptions;

  const FriendPersonCard({
    super.key,
    required this.avatarId,
    required this.name,
    required this.actions,
    this.subtitle,
    this.tags,
    this.trailingLabel,
    this.isTrusted = false,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarOptions[avatarId];
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: avatar.color, shape: BoxShape.circle),
                  child: Icon(avatar.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isTrusted) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.shield_rounded,
                                color: Color(0xFF43A047), size: 18),
                          ],
                        ],
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      if (trailingLabel != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.place_rounded,
                                size: 14, color: Colors.black38),
                            const SizedBox(width: 3),
                            Text(trailingLabel!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black45)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (onMoreOptions != null)
                  IconButton(
                    onPressed: onMoreOptions,
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.black45),
                  ),
              ],
            ),
            if (tags != null && tags!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags!
                    .take(3)
                    .map((tag) => Chip(
                          label:
                              Text(tag, style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFFF3E5F5),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
