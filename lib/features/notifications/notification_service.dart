// MoneyBuddy
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await NotificationService.showLocalNotification(
    title: message.notification?.title ?? 'MoneyBuddy',
    body:  message.notification?.body  ?? '',
  );
}

class NotificationService {
  NotificationService._();

  static final _fcm   = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'moneybuddy_channel';
  static const _channelName = 'MoneyBuddy Alerts';
  static const _channelDesc =
      'Budget alerts, EMI reminders and weekly summaries';

  static const _colorBudget  = Color(0xFFF59E0B);
  static const _colorEmi     = Color(0xFF3B82F6);
  static const _colorWeekly  = Color(0xFF059669);
  static const _colorDefault = Color(0xFF059669);

  // ── Initialize ────────────────────────────────────────────────

  static Future<void> initialize() async {
    final settings = await _fcm.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description:     _channelDesc,
      importance:      Importance.high,
      playSound:       true,
      enableVibration: true,
    );

    await _local
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(
        title:   message.notification?.title ?? 'MoneyBuddy',
        body:    message.notification?.body  ?? '',
        payload: message.data['route'],
      );
    });

    final token = await _fcm.getToken();
    debugPrint('[FCM] Token: $token');
  }

  // ── Base show notification ────────────────────────────────────

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String?         payload,
    int             id    = 0,
    Color           color = _colorDefault,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:         Importance.high,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',
      color:              color,
      colorized:          false,
      playSound:          true,
      enableVibration:    true,
      styleInformation:   BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ── Budget alert ──────────────────────────────────────────────

  static Future<void> showBudgetAlert({
    required String category,
    required double spent,
    required double budget,
  }) async {
    final pct       = (spent / budget * 100).toStringAsFixed(0);
    final remaining = (budget - spent).toStringAsFixed(0);
    final body      = 'You have used $pct% of your $category budget. '
                      'Rs.$remaining remaining.';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:         Importance.high,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',
      color:              _colorBudget,
      playSound:          true,
      enableVibration:    true,
      subText:            'Budget Alert',
      styleInformation:   BigTextStyleInformation(
        body,
        summaryText: 'Budget Alert',
      ),
    );

    await _local.show(
      1000,
      '$category Budget — $pct% Used',
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle:     'Budget Alert',
        ),
      ),
      payload: '/budget',
    );
  }

  // ── EMI reminder ─────────────────────────────────────────────

  static Future<void> showEmiReminder({
    required String emiName,
    required double amount,
    required int    daysUntilDue,
  }) async {
    final when = daysUntilDue == 0
        ? 'today'
        : daysUntilDue == 1
            ? 'tomorrow'
            : 'in $daysUntilDue days';
    final body = 'Rs.${amount.toStringAsFixed(0)} is due $when. '
                 "Don't miss your payment.";

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:         Importance.high,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',
      color:              _colorEmi,
      playSound:          true,
      enableVibration:    true,
      subText:            'EMI Reminder',
      styleInformation:   BigTextStyleInformation(
        body,
        summaryText: 'EMI Reminder',
      ),
    );

    await _local.show(
      2000,
      '$emiName Due $when',
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle:     'EMI Reminder',
        ),
      ),
      payload: '/emi',
    );
  }

  // ── Weekly summary ────────────────────────────────────────────

  static Future<void> showWeeklySummary({
    required double weeklySpend,
    required double weeklyBudget,
  }) async {
    final isOver = weeklySpend > weeklyBudget && weeklyBudget > 0;
    final title  = isOver
        ? 'Weekly Summary — Over Budget'
        : 'Weekly Summary';
    final body   = weeklyBudget > 0
        ? 'This week: Rs.${weeklySpend.toStringAsFixed(0)} spent '
          'of Rs.${weeklyBudget.toStringAsFixed(0)} budget.'
        : 'This week you spent Rs.${weeklySpend.toStringAsFixed(0)}.';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:         Importance.defaultImportance,
      priority:           Priority.defaultPriority,
      icon:               '@mipmap/ic_launcher',
      color:              isOver ? _colorBudget : _colorWeekly,
      playSound:          true,
      enableVibration:    false,
      subText:            'Weekly Report',
      styleInformation:   BigTextStyleInformation(
        body,
        summaryText: 'Weekly Report',
      ),
    );

    await _local.show(
      3000,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
          subtitle:     'Weekly Report',
        ),
      ),
      payload: '/analytics',
    );
  }

  // ── Notification tap ──────────────────────────────────────────

  static void _onNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      debugPrint('[Notification] Tapped — route: $route');
    }
  }
}