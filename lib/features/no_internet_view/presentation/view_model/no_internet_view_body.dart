import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/no_internet_view/manager/cubit/connection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoInternetViewBody extends StatefulWidget {
  const NoInternetViewBody({super.key});

  @override
  State<NoInternetViewBody> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetViewBody> {
  bool _isChecking = false;
  bool _stillOffline = false;

  Future<void> _retry() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _stillOffline = false;
    });

    final online = await context.read<ConnectionCubit>().checkNow();

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _stillOffline = !online;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    final illustrationSize = (screenSize.height * 0.28)
        .clamp(140.0, 260.0)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.06,
                        vertical: screenSize.height * 0.03,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NoInternetIllustration(size: illustrationSize),
                          SizedBox(height: screenSize.height * 0.04),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: context.tr('offline.title')),
                                TextSpan(
                                  text: '📡',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                            style: Styles.textStyle26B,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('offline.message'),
                            style: Styles.textStyle14,
                            textAlign: TextAlign.center,
                          ),
                          if (_stillOffline) ...[
                            const SizedBox(height: 12),
                            Text(
                              context.tr('offline.still'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFEF4444),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: screenSize.height * 0.05),
                          ButtonWidget(
                            width: double.infinity,
                            height: 52,
                            onPressed: _retry,
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: Colors.white,
                            text: _isChecking
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.tr('common.try_again'),
                                    style: Styles.textStyle16,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Placeholder illustration مبني بالأيقونات.
/// لو عندك illustration جاهزة استبدله بـ Image.asset.
class _NoInternetIllustration extends StatelessWidget {
  const _NoInternetIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withAlpha(46),
              shape: BoxShape.circle,
            ),
          ),
          Icon(Icons.wifi_off_rounded, size: size * 0.3, color: kPrimaryBlue),
          Positioned(
            top: size * 0.14,
            right: size * 0.14,
            child: Icon(
              Icons.cloud_off_rounded,
              size: size * 0.14,
              color: const Color(0xFF93C5FD),
            ),
          ),
        ],
      ),
    );
  }
}
