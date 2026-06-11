// MoneyBuddy
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/pin_service.dart';

/// Handles Set PIN, Change PIN, Remove PIN flows.
/// Pass [mode] in Get.arguments:
///   'set'    → set new PIN (no old PIN needed)
///   'change' → verify old PIN then set new
///   'remove' → verify PIN then disable lock
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  // Mode
  late String _mode;

  // Steps
  // set:    step 0 = enter new, step 1 = confirm
  // change: step 0 = enter old, step 1 = enter new, step 2 = confirm
  // remove: step 0 = enter current
  int    _step    = 0;
  String _entered = '';
  String _newPin  = '';
  String _error   = '';

  static const _pinLength = 4;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _mode = args['mode'] as String? ?? 'set';
  }

  // ── Step labels ───────────────────────────────────────────────

  String get _title {
    switch (_mode) {
      case 'set':
        return _step == 0 ? 'Set PIN' : 'Confirm PIN';
      case 'change':
        if (_step == 0) return 'Enter Current PIN';
        if (_step == 1) return 'Enter New PIN';
        return 'Confirm New PIN';
      case 'remove':
        return 'Enter PIN to Disable';
      default:
        return 'Set PIN';
    }
  }

  String get _subtitle {
    switch (_mode) {
      case 'set':
        return _step == 0
            ? 'Choose a 4-digit PIN for app lock'
            : 'Re-enter PIN to confirm';
      case 'change':
        if (_step == 0) return 'Enter your current PIN';
        if (_step == 1) return 'Choose a new 4-digit PIN';
        return 'Re-enter new PIN to confirm';
      case 'remove':
        return 'Enter your PIN to disable app lock';
      default:
        return '';
    }
  }

  // ── Key tap ───────────────────────────────────────────────────

  void _onKeyTap(String key) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += key;
      _error    = '';
    });
    if (_entered.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 100), _processStep);
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() =>
        _entered = _entered.substring(0, _entered.length - 1));
  }

  // ── Process each step ─────────────────────────────────────────

  Future<void> _processStep() async {
    switch (_mode) {
      case 'set':
        await _handleSet();
        break;
      case 'change':
        await _handleChange();
        break;
      case 'remove':
        await _handleRemove();
        break;
    }
  }

  Future<void> _handleSet() async {
    if (_step == 0) {
      // Save first entry, move to confirm
      setState(() {
        _newPin  = _entered;
        _entered = '';
        _step    = 1;
      });
    } else {
      // Confirm step
      if (_entered == _newPin) {
        await PinService.savePin(_newPin);
        Get.back(result: true);
        Get.snackbar(
          'PIN Set',
          'App lock enabled successfully.',
          backgroundColor: AppColors.kSuccess,
          colorText:       Colors.white,
          snackPosition:   SnackPosition.BOTTOM,
        );
      } else {
        setState(() {
          _error   = 'PINs do not match. Try again.';
          _entered = '';
          _step    = 0;
          _newPin  = '';
        });
      }
    }
  }

  Future<void> _handleChange() async {
    if (_step == 0) {
      // Verify old PIN
      final valid = await PinService.verifyPin(_entered);
      if (valid) {
        setState(() {
          _entered = '';
          _step    = 1;
        });
      } else {
        setState(() {
          _error   = 'Incorrect PIN. Try again.';
          _entered = '';
        });
      }
    } else if (_step == 1) {
      // Save new PIN first entry
      setState(() {
        _newPin  = _entered;
        _entered = '';
        _step    = 2;
      });
    } else {
      // Confirm new PIN
      if (_entered == _newPin) {
        await PinService.savePin(_newPin);
        Get.back(result: true);
        Get.snackbar(
          'PIN Changed',
          'Your PIN has been updated.',
          backgroundColor: AppColors.kSuccess,
          colorText:       Colors.white,
          snackPosition:   SnackPosition.BOTTOM,
        );
      } else {
        setState(() {
          _error   = 'PINs do not match. Try again.';
          _entered = '';
          _step    = 1;
          _newPin  = '';
        });
      }
    }
  }

  Future<void> _handleRemove() async {
    final removed = await PinService.removePin(_entered);
    if (removed) {
      Get.back(result: true);
      Get.snackbar(
        'PIN Disabled',
        'App lock has been turned off.',
        backgroundColor: AppColors.kSuccess,
        colorText:       Colors.white,
        snackPosition:   SnackPosition.BOTTOM,
      );
    } else {
      setState(() {
        _error   = 'Incorrect PIN. Try again.';
        _entered = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation:       0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            CupertinoIcons.xmark,
            color: AppColors.kTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.kPrimaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _mode == 'remove'
                    ? CupertinoIcons.lock_slash_fill
                    : CupertinoIcons.lock_shield_fill,
                color: AppColors.kPrimary,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            Text(_title, style: AppTextStyles.headingMedium),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _error.isNotEmpty ? _error : _subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _error.isNotEmpty
                      ? AppColors.kError
                      : AppColors.kTextHint,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // PIN dots
            Row(
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

            const SizedBox(height: 48),

            // Number pad
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

  Widget _buildRow(List<String> keys) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map(_buildKey).toList(),
      );

  Widget _buildKey(String key) => GestureDetector(
        onTap: () => _onKeyTap(key),
        child: Container(
          width:  72,
          height: 72,
          decoration: BoxDecoration(
            color:  AppColors.kCard,
            shape:  BoxShape.circle,
            border: Border.all(color: AppColors.kBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset:     const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              key,
              style: AppTextStyles.headingSmall.copyWith(fontSize: 22),
            ),
          ),
        ),
      );

  Widget _buildDeleteKey() => GestureDetector(
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