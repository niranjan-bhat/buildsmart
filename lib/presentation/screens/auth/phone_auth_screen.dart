import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  // Step 1: phone entry
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+91';

  // Step 2: OTP entry
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _isVerifying = false;
  String _verificationId = '';
  int? _resendToken;

  // Resend cooldown
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get _fullPhone => '$_countryCode${_phoneCtrl.text.trim()}';

  String get _otpValue => _otpCtrl.map((c) => c.text).join();

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendOtp({int? forceResendingToken}) async {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).verifyPhoneNumber(
      phoneNumber: _fullPhone,
      forceResendingToken: forceResendingToken,
      codeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _otpSent = true;
        });
        _startResendTimer();
      },
      verificationFailed: (_) {
        // Error shown via listener below.
      },
      verificationCompleted: () {
        if (mounted) context.go(AppRoutes.projects);
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length < 6 || _isVerifying) return;
    setState(() => _isVerifying = true);
    final success = await ref.read(authNotifierProvider.notifier).signInWithOtp(
      verificationId: _verificationId,
      smsCode: _otpValue,
    );
    if (mounted) {
      setState(() => _isVerifying = false);
      if (success) context.go(AppRoutes.projects);
    }
  }

  void _onOtpDigit(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocus[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
    setState(() {});
    if (_otpValue.length == 6) _verifyOtp();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: _otpSent ? context.l10n.verifyingOtp : context.l10n.sendingOtp,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              if (_otpSent) {
                setState(() {
                  _otpSent = false;
                  for (final c in _otpCtrl) {
                    c.clear();
                  }
                });
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _otpSent
                  ? _OtpStep(
                      key: const ValueKey('otp'),
                      phone: _fullPhone,
                      otpCtrl: _otpCtrl,
                      otpFocus: _otpFocus,
                      onDigit: _onOtpDigit,
                      onVerify: _verifyOtp,
                      resendSeconds: _resendSeconds,
                      onResend: () => _sendOtp(forceResendingToken: _resendToken),
                    )
                  : _PhoneStep(
                      key: const ValueKey('phone'),
                      formKey: _phoneFormKey,
                      phoneCtrl: _phoneCtrl,
                      countryCode: _countryCode,
                      onCountryCodeChanged: (code) =>
                          setState(() => _countryCode = code),
                      onSend: _sendOtp,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 1: Phone Number ────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final String countryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final VoidCallback onSend;

  const _PhoneStep({
    super.key,
    required this.formKey,
    required this.phoneCtrl,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.phone_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 28),
          Text(context.l10n.phoneAuthTitle,
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(context.l10n.phoneAuthSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code field
              SizedBox(
                width: 88,
                child: TextFormField(
                  initialValue: countryCode,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\+\d*')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(labelText: 'Code'),
                  onChanged: onCountryCodeChanged,
                  validator: (v) {
                    if (v == null || !RegExp(r'^\+\d{1,4}$').hasMatch(v.trim())) {
                      return '?';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Phone number field
              Expanded(
                child: TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.phoneNumber,
                    hintText: '9876543210',
                  ),
                  onFieldSubmitted: (_) => onSend(),
                  validator: (v) {
                    if (v == null || v.trim().length < 7) {
                      return context.l10n.phoneNumberInvalid;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSend,
              child: Text(context.l10n.sendOtp),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: OTP Entry ───────────────────────────────────────────────────────

class _OtpStep extends StatelessWidget {
  final String phone;
  final List<TextEditingController> otpCtrl;
  final List<FocusNode> otpFocus;
  final void Function(int index, String value) onDigit;
  final VoidCallback onVerify;
  final int resendSeconds;
  final VoidCallback onResend;

  const _OtpStep({
    super.key,
    required this.phone,
    required this.otpCtrl,
    required this.otpFocus,
    required this.onDigit,
    required this.onVerify,
    required this.resendSeconds,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otp = otpCtrl.map((c) => c.text).join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.sms_outlined, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 28),
        Text(context.l10n.enterOtpTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            children: [
              TextSpan(text: context.l10n.otpSentTo),
              TextSpan(
                text: ' $phone',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        // 6-box OTP input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            final isFilled = otpCtrl[i].text.isNotEmpty;
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: otpCtrl[i],
                focusNode: otpFocus[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: isFilled
                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isFilled
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (v) => onDigit(i, v),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: otp.length == 6 ? onVerify : null,
            child: Text(context.l10n.verifyOtp),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: resendSeconds > 0
              ? Text(
                  context.l10n.resendOtpIn(resendSeconds),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : TextButton(
                  onPressed: onResend,
                  child: Text(context.l10n.resendOtp),
                ),
        ),
      ],
    );
  }
}
