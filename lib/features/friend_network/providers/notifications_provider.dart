import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/notifications_repository.dart';

final _notificationsRepository = NotificationsRepository();

final pendingRequestsCountProvider = StreamProvider<int>((ref) {
  return _notificationsRepository.pendingRequestsCountStream();
});

final unreadConversationsCountProvider = StreamProvider<int>((ref) {
  return _notificationsRepository.unreadConversationsCountStream();
});

/// Convenience combined total for badges. Reads the two streams above;
/// while either is still loading its first value, that side just
/// contributes 0 rather than blocking the whole badge.
int watchTotalNotificationCount(WidgetRef ref) {
  final requests = ref.watch(pendingRequestsCountProvider).asData?.value ?? 0;
  final unread = ref.watch(unreadConversationsCountProvider).asData?.value ?? 0;
  return requests + unread;
}
