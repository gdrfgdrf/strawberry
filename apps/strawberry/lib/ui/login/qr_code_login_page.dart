import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/qrcode/qr_code_bloc.dart';
import 'package:strawberry/bloc/qrcode/try_login_qr_code_event_state.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/login/login_center.dart';
import 'package:strawberry/ui/login/qr_code_login_page_delegate.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';
import 'package:widgets/widgets/auto_spacer.dart';
import 'package:widgets/widgets/double_layer_blur_widget.dart';

import '../../bloc/qrcode/get_qr_code_unikey_event_state.dart';
import '../../bloc/user/get_user_detail_event_state.dart';

class QrCodeLoginPage extends AbstractUiWidget {
  QrCodeLoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _QrCodeLoginPageState();
}

class _QrCodeLoginPageState
    extends AbstractUiWidgetState<QrCodeLoginPage, QrCodeLoginPageDelegate>
    with AutomaticKeepAliveClientMixin {
  int animationKey = 0;

  @override
  QrCodeLoginPageDelegate createDelegate() {
    return QrCodeLoginPageDelegate();
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        delegate!.generateQrCode();
      },
    ];
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener<QrCodeBloc, QrCodeState>(
        bloc: delegate!.qrcodeBloc,
        listener: (context, state) {
          if (state is TryLoginQrCodeLoading) {
            delegate!.tryLoginTaskRunning = false;
            return;
          }

          if (state is QrCodeLoading) {
            delegate!.upNotifier.value = CircularProgressIndicator();
            delegate!.blurState.value = true;
          }
          if (state is GetQrCodeUniKeySuccess) {
            delegate!.onGetQrCodeUniKeySuccess(state);
          }

          if (state is TryLoginQrCodeSuccess) {
            delegate!.onTryLoginQrCodeSuccess(state);
            return;
          }
          if (state is TryLoginQrCodeFailure) {
            Timer(Duration(milliseconds: 1000), () {
              delegate!.tryLogin();
            });
            return;
          }

          if (state is QrCodeFailure) {
            delegate!.upNotifier.value = ElevatedButton(
              onPressed: () {
                delegate!.generateQrCode();
              },
              child: Text(Localizer.of(context)!.retry),
            );
            delegate!.blurState.value = true;
            delegate!.qrImageNotifier.value = null;
          }
        },
      ),
      BlocListener<UserBloc, UserState>(
        bloc: delegate!.userBloc,
        listener: (context, state) {
          if (state is GetUserDetailSuccess_Type1) {
            LoginCenter.success(context);
          }
          if (state is GetUserDetailSuccess_Type2) {
            final account = state.pair.key;
            delegate!.getUserDetail_Type1(account.id);
          }
          if (state is UserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Localizer.of(context)!.get_user_detail_failed,
                  textAlign: TextAlign.center,
                ),
              ),
            );

            delegate!.generateQrCode();
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    serviceLogger!.info("building page: $runtimeType");

    super.build(context);
    super.buildSelf();

    Widget content = buildContent(context);
    final mergedBlocListeners = delegate!.mergeBlocListeners(blocListeners());
    if (mergedBlocListeners.isNotEmpty) {
      content = MultiBlocListener(
        listeners: mergedBlocListeners,
        child: content,
      );
    }

    return content;
  }

  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: delegate!.qrImageNotifier,
      builder: (_, qrImage, _) {
        delegate!.previous = delegate!.current;

        final size = MediaQuery.of(context).size;
        final squareSize = size.width > size.height ? size.height : size.width;
        final cardSize = squareSize > 160 ? 160 : squareSize / 2;

        final previousWidget =
            delegate!.previous != null
                ? PrettyQrView(qrImage: delegate!.previous!)
                : SizedBox.shrink();
        final widget =
            qrImage != null
                ? PrettyQrView(qrImage: qrImage)
                : SizedBox.shrink();

        animationKey++;
        final switchAnimation = SmoothWidgetSwitchAnimation(
          key: ValueKey<int>(animationKey),
          before: previousWidget,
          after: widget,
          duration: Duration(milliseconds: 500),
        );

        AnimationCombination.newBuilder()
            .add(switchAnimation)
            .build(
              onReady: (animation) {
                delegate!.current = qrImage;
                animation.forwardAllCallback = () {
                  delegate!.previous = null;
                };
                animation.forwardAll();
              },
            );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SmoothContainer(
              width: cardSize + 0.0,
              height: cardSize + 0.0,
              borderRadius: BorderRadius.circular(24),
              color:
                  isDarkMode()
                      ? themeData().colorScheme.onSurface
                      : themeData().colorScheme.surfaceContainer,
              child: DoubleLayerBlurWidget(
                down: Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: switchAnimation,
                ),
                up: CircularProgressIndicator(),
                width: cardSize + 0.0,
                height: cardSize + 0.0,
                borderRadius: BorderRadius.circular(24),
                stateNotifier: delegate!.blurState,
                upNotifier: delegate!.upNotifier,
              ),
            ),

            AutoSpacer(0.05),

            if (PlatformExtension.isMobile)
              Text(Localizer.of(context)!.use_cloudmusic_app_to_scan),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
