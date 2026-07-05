import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/core/state/notifications_provider.dart';
import 'package:sabil_life/data/models/app_notification.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

class NotificaionsScreen extends ConsumerWidget {
  const NotificaionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncNotifications = ref.watch(notificationsFeedProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () => ref.refresh(notificationsFeedProvider.future),
          child: asyncNotifications.when(
            loading: () => const RefreshableMessage(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => RefreshableMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.genericLoadError, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(notificationsFeedProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (items) => items.isEmpty
                ? RefreshableMessage(child: Text(l10n.noResults))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _NotificationTile(
                      notification: items[i],
                      onTap: () async {
                        await ref
                            .read(notificationRepositoryProvider)
                            .postNotificationRead(items[i].id);
                        ref.invalidate(notificationsFeedProvider);
                        ref.invalidate(unreadCountProvider);
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.notifications,
        color: unread ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(notification.body),
      trailing: unread
          ? const CircleAvatar(radius: 4, backgroundColor: AppColors.primary)
          : null,
    );
  }
}
