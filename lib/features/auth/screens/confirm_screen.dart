// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../services/auth_service.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args      = Get.arguments as Map<String, dynamic>? ?? {};
    final title     = args['title']      as String? ?? 'Check Your Email';
    final message   = args['message']    as String? ??
        'We sent you an email. Please check your inbox.';
    final isRegister = args['isRegister'] as bool? ?? true;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - MediaQuery.of(context).padding.bottom
                  - AppSpacing.screenV * 2,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Flexible(flex: 2, child: SizedBox(height: R.h(context, 40))),

                  // ── Success animation ────────────────
                  SizedBox(
                    width:  R.w(context, 180),
                    height: R.w(context, 180),
                    child: Lottie.asset(
                      AppAssets.successLottie,
                      fit: BoxFit.contain,
                      repeat: false,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.check_circle_rounded,
                        size: R.w(context, 100),
                        color: AppColors.kPrimary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),

                  Gap(R.h(context, 24)),

                  // ── Title ────────────────────────────
                  Text(
                    title,
                    style: AppTextStyles.authHeading,
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 300.ms),

                  Gap(R.h(context, 12)),

                  // ── Message ──────────────────────────
                  Text(
                    message,
                    style: AppTextStyles.authSubHeading,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 300.ms),

                  Flexible(flex: 3, child: SizedBox(height: R.h(context, 40))),

                  // ── Back to login button ─────────────
                  PrimaryButton(
                    text: 'Back to Login',
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),

                  Gap(R.h(context, 12)),

                  // ── Resend button — only for register ─
                  if (isRegister)
                    SecondaryButton(
                      text: 'Resend Email',
                      onPressed: () async {
                        await AuthService().resendVerification();
                      },
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 300.ms),

                  Gap(R.h(context, 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}