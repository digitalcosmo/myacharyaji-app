import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/controls.dart';
import '../../../ui/motion.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tokens.dart';
import '../../../widgets/cosmic_bg.dart';

const _green = Color(0xFF5FE08A);
const _red = Color(0xFFFF6B6B);

/// 4-digit OTP entry.
/// - Android: reads the code from the SMS (SMS User Consent API — the user
///   taps "Allow" once; no change to the SMS template needed).
/// - iOS: the keyboard offers the code from Messages (oneTimeCode autofill).
/// - Verifies by itself as soon as 4 digits are in.
/// - Filled boxes turn green; a wrong or incomplete code turns the boxes red,
///   shakes them and vibrates.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final c = Get.find<AuthController>();
  final _focus = FocusNode();
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 480));

  bool _error = false;

  /// Highlight only the empty boxes after "Verify" with an incomplete code.
  bool _missing = false;
  int _resendIn = 30;
  Timer? _timer;

  bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    c.otpController.clear();
    c.otpError.value = '';
    c.otpController.addListener(_onChanged);
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    _startTimer();
    _listenForSms();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    c.otpController.removeListener(_onChanged);
    if (_android) SmartAuth.instance.removeUserConsentApiListener();
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _listenForSms() async {
    if (!_android) return;
    // Matches the first standalone 4-digit number in the SMS.
    final res = await SmartAuth.instance.getSmsWithUserConsentApi(matcher: r'\b\d{4}\b');
    if (!mounted || !res.hasData) return;
    final code = res.data?.code;
    if (code != null && code.length >= AuthController.otpLength) {
      c.otpController.text = code.substring(0, AuthController.otpLength);
      c.otpController.selection = TextSelection.collapsed(offset: AuthController.otpLength);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendIn = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  void _onChanged() {
    final v = c.otpController.text;
    if (_error || _missing) {
      setState(() {
        _error = false;
        _missing = false;
      });
      c.otpError.value = '';
    } else {
      setState(() {});
    }
    if (v.length == AuthController.otpLength) _verify();
  }

  Future<void> _verify() async {
    if (c.isLoading.value) return;
    if (c.otpController.text.length < AuthController.otpLength) {
      setState(() => _missing = true);
      c.otpError.value = 'Enter all ${AuthController.otpLength} digits.';
      _buzz();
      _focus.requestFocus();
      return;
    }
    _focus.unfocus();
    final ok = await c.verifyOtp();
    if (!ok && mounted) {
      setState(() => _error = true);
      _buzz();
      // Let the red state register, then clear for a fresh attempt.
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      c.otpController.removeListener(_onChanged);
      c.otpController.clear();
      c.otpController.addListener(_onChanged);
      setState(() {});
      _focus.requestFocus();
    }
  }

  void _buzz() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), HapticFeedback.vibrate);
    _shake.forward(from: 0);
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    final ok = await c.sendOtp(navigate: false);
    if (ok) {
      _startTimer();
      _listenForSms();
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = c.phoneController.text;
    final code = c.otpController.text;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CosmicBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    RoundIconButton(icon: Ic.chevLeft, tooltip: 'Back', onTap: () => Get.back()),
                    const SizedBox(width: 16),
                    const _StepDots(current: 2, total: 3),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Verify it\'s you', style: T.h1),
                const SizedBox(height: 10),
                Text.rich(TextSpan(
                  style: T.muted,
                  children: [
                    const TextSpan(text: 'Enter the 4-digit code sent to '),
                    TextSpan(text: '+91 $phone', style: const TextStyle(color: AppColors.tx, fontWeight: FontWeight.w700)),
                  ],
                )),
                const SizedBox(height: 36),

                // Boxes, with an invisible text field underneath that owns the
                // keyboard, paste and autofill.
                AnimatedBuilder(
                  animation: _shake,
                  builder: (_, child) {
                    final t = _shake.value;
                    final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
                    return Transform.translate(offset: Offset(dx, 0), child: child);
                  },
                  child: GestureDetector(
                    onTap: () => _focus.requestFocus(),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0,
                          child: SizedBox(
                            height: 68,
                            child: TextField(
                              controller: c.otpController,
                              focusNode: _focus,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              maxLength: AuthController.otpLength,
                              showCursor: false,
                              enableInteractiveSelection: false,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                              onSubmitted: (_) => _verify(),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: Row(
                            children: [
                              for (var i = 0; i < AuthController.otpLength; i++) ...[
                                if (i > 0) const SizedBox(width: 14),
                                Expanded(
                                  child: _Box(
                                    digit: i < code.length ? code[i] : '',
                                    focused: _focus.hasFocus && i == code.length.clamp(0, AuthController.otpLength - 1),
                                    error: _error || (_missing && i >= code.length),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: c.otpError.value.isEmpty
                          ? const SizedBox(height: 20, width: double.infinity)
                          : SizedBox(
                              key: ValueKey(c.otpError.value),
                              width: double.infinity,
                              child: Text(c.otpError.value,
                                  style: T.small.copyWith(color: _red, fontWeight: FontWeight.w600)),
                            ),
                    )),
                const SizedBox(height: 22),
                Obx(() => c.isLoading.value
                    ? const SizedBox(
                        height: 52,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.sun),
                          ),
                        ),
                      )
                    : PrimaryButton(label: 'Verify', onTap: _verify)),
                const SizedBox(height: 18),
                Center(
                  child: _resendIn > 0
                      ? Text('Resend code in 0:${_resendIn.toString().padLeft(2, '0')}', style: T.small)
                      : TextButton(
                          onPressed: _resend,
                          child: Text('Resend code',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.sun2)),
                        ),
                ),
                if (_android) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text('We\'ll read the code from the SMS when you tap "Allow".',
                        style: T.small.copyWith(fontSize: 11.5), textAlign: TextAlign.center),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final String digit;
  final bool focused;
  final bool error;
  const _Box({required this.digit, required this.focused, required this.error});

  @override
  Widget build(BuildContext context) {
    final filled = digit.isNotEmpty;
    final border = error
        ? _red
        : filled
            ? _green
            : focused
                ? AppColors.sun
                : AppColors.line;
    final fill = error
        ? _red.withValues(alpha: 0.12)
        : filled
            ? _green.withValues(alpha: 0.10)
            : AppColors.card;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: kEase,
      height: 68,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: (filled || focused || error) ? 1.8 : 1.2),
        boxShadow: (filled || error)
            ? [BoxShadow(color: border.withValues(alpha: 0.25), blurRadius: 14)]
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
        child: filled
            ? Text(digit,
                key: ValueKey(digit),
                style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.tx))
            : focused
                ? const _Caret()
                : const SizedBox.shrink(),
      ),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();
  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(width: 2, height: 26, color: AppColors.sun),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (i) => Container(
          height: 4,
          width: 40,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: i < current ? AppColors.sun : AppColors.line,
          ),
        ),
      ),
    );
  }
}
