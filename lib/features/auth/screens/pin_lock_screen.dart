// MoneyBuddy
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneybuddy/core/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/pin_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _entered       = '';
  int    _attempts      = 0;
  bool   _isCoolingDown = false;
  int    _cooldownSecs  = 30;
  Timer? _cooldownTimer;

  late AnimationController _shakeController;
  late Animation<double>   _shakeAnimation;

  static const _maxAttempts  = 3;
  static const _pinLength    = 4;
  static const _cooldownTime = 30;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  // ── PIN input ─────────────────────────────────────────────────

  void _onKeyTap(String key) {
    if (_isCoolingDown) return;
    if (_entered.length >= _pinLength) return;
    setState(() => _entered += key);
    if (_entered.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verifyPin() async {
    final correct = await PinService.verifyPin(_entered);
    if (correct) {
       Get.offAllNamed(AppRoutes.splash);
    } else {
      _attempts++;
      _shakeController.forward(from: 0);
      setState(() => _entered = '');

      if (_attempts >= _maxAttempts) {
        _startCooldown();
      }
    }
  }

  void _startCooldown() {
    setState(() {
      _isCoolingDown = true;
      _cooldownSecs  = _cooldownTime;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _cooldownSecs--);
      if (_cooldownSecs <= 0) {
        t.cancel();
        setState(() {
          _isCoolingDown = false;
          _attempts      = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // ── Lock icon ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        AppColors.kPrimaryTint,
                shape:        BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.lock_shield_fill,
                color: AppColors.kPrimary,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Enter PIN',
              style: AppTextStyles.headingMedium,
            ),

            const SizedBox(height: 8),

            Text(
              _isCoolingDown
                  ? 'Too many attempts. Try in $_cooldownSecs seconds'
                  : _attempts > 0
                      ? 'Incorrect PIN. ${_maxAttempts - _attempts} attempts left'
                      : 'Enter your 4-digit PIN to continue',
              style: AppTextStyles.bodySmall.copyWith(
                color: _isCoolingDown || _attempts > 0
                    ? AppColors.kError
                    : AppColors.kTextHint,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // ── PIN dots ──────────────────────────────────────
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (_, child) {
                final offset = _shakeAnimation.value *
                    8 *
                    (_shakeController.status ==
                            AnimationStatus.forward
                        ? 1
                        : -1);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width:  16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.kPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? AppColors.kPrimary
                            : AppColors.kBorder,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 48),

            // ── Number pad ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  _buildRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  // Bottom row — empty + 0 + delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72, height: 72),
                      _buildKey('0'),
                      _buildDeleteKey(),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map(_buildKey).toList(),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => _onKeyTap(key),
      child: Container(
        width:  72,
        height: 72,
        decoration: BoxDecoration(
          color:        AppColors.kCard,
          shape:        BoxShape.circle,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withValues(alpha: 0.04),
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            key,
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width:  72,
        height: 72,
        decoration: BoxDecoration(
          color:  AppColors.kCard,
          shape:  BoxShape.circle,
          border: Border.all(color: AppColors.kBorder, width: 0.8),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.delete_left,
            color: AppColors.kTextPrimary,
            size:  22,
          ),
        ),
      ),
    );
  }
}