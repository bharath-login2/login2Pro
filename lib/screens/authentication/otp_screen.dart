// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/authentication/reset_password.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../core/common.dart';
import '../../models/sendOtpModel.dart';
import '../../service/service.dart';
import '../../widgets/size_config.dart';

class OtpScreen extends StatefulWidget {
  String? rno;
  String? mobileNo;

  OtpScreen(this.rno, this.mobileNo, {super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin, CodeAutoFill {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();

  String? _otp;
  bool isLoading = false;
  int secondsRemaining = 30;
  bool isResendButtonEnabled = false;
  Timer? _timer;
  String otpType = "WhatsApp";
  String genOtp = "";

  // Auto verification
  bool autoVerificationCompleted = false;
  Timer? _autoVerifyTimer;

  // Focus nodes for OTP fields
  late FocusNode focusNode1;
  late FocusNode focusNode2;
  late FocusNode focusNode3;
  late FocusNode focusNode4;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  // Blue color palette (matching previous screen)
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color lightBlue = Color(0xFF90CAF9);
  static const Color extraLightBlue = Color(0xFFE3F2FD);
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color gradientStart = Color(0xFF2196F3);
  static const Color gradientEnd = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    genOtp = widget.rno!;

    // Initialize focus nodes
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
    focusNode3 = FocusNode();
    focusNode4 = FocusNode();

    // Initialize animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    startTimer();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode1);
    });

    // Start SMS autofill
    listenForCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoVerifyTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();

    // Dispose focus nodes
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();

    // Dispose controllers
    _fieldOne.dispose();
    _fieldTwo.dispose();
    _fieldThree.dispose();
    _fieldFour.dispose();

    // Cancel SMS autofill
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    // This is called when SMS is detected
    if (code != null && code!.length >= 4) {
      String extractedCode = code!.replaceAll(RegExp(r'\D'), '');
      if (extractedCode.length >= 4) {
        _autoFillOtp(extractedCode.substring(0, 4));
      }
    }
  }

  void _autoFillOtp(String otpCode) {
    if (!mounted || autoVerificationCompleted) return;

    HapticFeedback.heavyImpact();

    // Split OTP into digits
    _fieldOne.text = otpCode[0];
    _fieldTwo.text = otpCode[1];
    _fieldThree.text = otpCode[2];
    _fieldFour.text = otpCode[3];

    // Auto-verify after a short delay
    _autoVerifyTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !autoVerificationCompleted) {
        _checkAndVerifyOtp(auto: true);
      }
    });
  }

  void _checkOtpCompletion() {
    if (autoVerificationCompleted) return;

    String otp =
        _fieldOne.text + _fieldTwo.text + _fieldThree.text + _fieldFour.text;
    if (otp.length == 4) {
      // All fields filled, auto-verify after a tiny delay for better UX
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !autoVerificationCompleted) {
          _checkAndVerifyOtp(auto: true);
        }
      });
    }
  }

  void startTimer() {
    setState(() {
      secondsRemaining = 30;
      isResendButtonEnabled = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isResendButtonEnabled = true;
        });
        _pulseController.stop();
      }
    });
  }

  void resendOTP() async {
    if (isResendButtonEnabled) {
      HapticFeedback.lightImpact();

      int min = 1000;
      int max = 9999;
      var randomizer = Random();
      var rNum = min + randomizer.nextInt(max - min);
      genOtp = rNum.toString();

      setState(() {
        isLoading = true;
        autoVerificationCompleted = false;
      });

      SendOtpModel otp = await HttpService.sendOtp(
          widget.mobileNo, rNum, otpType == "WhatsApp" ? "default" : "sms");

      setState(() => isLoading = false);

      if (otp.status == true) {
        HapticFeedback.heavyImpact();
        Common.toastMessaage('OTP sent successfully!', Colors.green);
        // Clear fields
        _fieldOne.clear();
        _fieldTwo.clear();
        _fieldThree.clear();
        _fieldFour.clear();
        FocusScope.of(context).requestFocus(focusNode1);
      } else {
        HapticFeedback.vibrate();
        Common.toastMessaage(otp.message, Colors.red);
      }
      startTimer();
    }
  }

  void _checkAndVerifyOtp({bool auto = false}) {
    _otp = _fieldOne.text + _fieldTwo.text + _fieldThree.text + _fieldFour.text;

    if (_otp == genOtp) {
      _verifySuccess(auto);
    } else {
      _verifyFailure(auto);
    }
  }

  void verifyOtp() async {
    if (autoVerificationCompleted) return;

    HapticFeedback.lightImpact();
    _checkAndVerifyOtp(auto: false);
  }

  void _verifySuccess(bool auto) {
    autoVerificationCompleted = true;
    HapticFeedback.heavyImpact();

    if (auto) {
      Common.toastMessaage('✓ Auto-verified successfully!', Colors.green);
    }

    // Navigate to reset password
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResetPassword(widget.mobileNo),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          var scale = Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          );

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _verifyFailure(bool auto) {
    HapticFeedback.vibrate();
    _shakeController.forward().then((_) => _shakeController.reset());

    String errorMsg = auto
        ? 'Auto-verification failed. Please enter OTP manually.'
        : 'Invalid OTP. Please try again.';

    Common.toastMessaage(errorMsg, Colors.red);
  }

  void onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index == 1) FocusScope.of(context).requestFocus(focusNode2);
      if (index == 2) FocusScope.of(context).requestFocus(focusNode3);
      if (index == 3) FocusScope.of(context).requestFocus(focusNode4);
      if (index == 4) FocusScope.of(context).unfocus();

      // Check if all fields are filled after this change
      Future.delayed(const Duration(milliseconds: 50), () {
        _checkOtpCompletion();
      });
    } else if (value.isEmpty && index > 1) {
      if (index == 2) FocusScope.of(context).requestFocus(focusNode1);
      if (index == 3) FocusScope.of(context).requestFocus(focusNode2);
      if (index == 4) FocusScope.of(context).requestFocus(focusNode3);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
        );
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Animated background
              Positioned.fill(
                child: CustomPaint(
                  painter: BlueWavePainter(),
                ),
              ),

              // Decorative floating elements
              Positioned(
                top: -30,
                right: -20,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 3),
                  curve: Curves.easeInOut,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, sin(value * pi * 2) * 10),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightBlue.withOpacity(0.15),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: -40,
                left: -40,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeInOut,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(cos(value * pi * 2) * 15, 0),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: extraLightBlue.withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo with white background
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryBlue.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/main/funriders.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Title
                        Text(
                          "Verification Code",
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: deepBlue,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle with phone number
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text: "We've sent a verification code to ",
                                ),
                                TextSpan(
                                  text: "+91 ${widget.mobileNo}",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // OTP Type Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: extraLightBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                otpType == "WhatsApp"
                                    ? FontAwesomeIcons.whatsapp
                                    : Icons.message_rounded,
                                color: otpType == "WhatsApp"
                                    ? const Color(0xFF25D366)
                                    : primaryBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Sent via $otpType",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: deepBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Auto-detection indicator
                        if (code == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: extraLightBlue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Auto-detecting OTP...",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: deepBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // OTP Input Fields
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildOtpField(_fieldOne, focusNode1, 1),
                                _buildOtpField(_fieldTwo, focusNode2, 2),
                                _buildOtpField(_fieldThree, focusNode3, 3),
                                _buildOtpField(_fieldFour, focusNode4, 4),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Submit Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (isLoading || autoVerificationCompleted)
                                ? null
                                : verifyOtp,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [gradientStart, gradientEnd],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        autoVerificationCompleted
                                            ? "Verified ✓"
                                            : "Verify & Continue",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Timer Section
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: extraLightBlue.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: isResendButtonEnabled
                                    ? Colors.grey
                                    : primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isResendButtonEnabled
                                    ? 'OTP expired'
                                    : 'Resend OTP in $secondsRemaining seconds',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isResendButtonEnabled
                                      ? Colors.grey.shade600
                                      : deepBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resend Options
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // _buildResendButton(
                              //   label: "SMS",
                              //   icon: Icons.message_rounded,
                              //   type: "Phone",
                              //   color: primaryBlue,
                              //   enabled: isResendButtonEnabled,
                              // ),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey.shade300,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              _buildResendButton(
                                label: "WhatsApp",
                                icon: FontAwesomeIcons.whatsapp,
                                type: "WhatsApp",
                                color: const Color(0xFF25D366),
                                enabled: isResendButtonEnabled,
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.grey.shade300,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back to Login
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Change phone number?",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // if (genOtp.isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 10),
                        //     child: Container(
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 12, vertical: 6),
                        //       decoration: BoxDecoration(
                        //         color: Colors.grey.shade100,
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Text(
                        //         'Test OTP: $genOtp',
                        //         style: GoogleFonts.inter(
                        //           fontSize: 12,
                        //           color: Colors.grey.shade600,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
              ),

              // Success overlay
              if (autoVerificationCompleted)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.9),
                    child: Center(
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, double scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(
    TextEditingController controller,
    FocusNode focusNode,
    int index,
  ) {
    return Container(
      width: 65,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: index == 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: lightBlue.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) => onOtpChanged(value, index),
      ),
    );
  }

  Widget _buildResendButton({
    required String label,
    required IconData icon,
    required String type,
    required Color color,
    required bool enabled,
  }) {
    final isSelected = otpType == type;

    return InkWell(
      onTap: enabled
          ? () {
              setState(() => otpType = type);
              resendOTP();
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? color
                    : enabled
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for blue wave background
class BlueWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE3F2FD).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.3,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Draw second wave
    final paint2 = Paint()
      ..color = const Color(0xFFBBDEFB).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.15,
        size.width * 0.6,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.4,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
