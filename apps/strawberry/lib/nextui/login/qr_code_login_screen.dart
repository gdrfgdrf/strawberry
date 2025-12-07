import 'dart:async';

import 'package:domain/entity/login_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared/configuration/desktop_config.dart';
import 'package:shared/configuration/general_config.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/bloc/auth/refresh_token_event_state.dart';
import 'package:strawberry/bloc/auth/register_anonimous_event_state.dart';
import 'package:strawberry/bloc/qrcode/get_qr_code_unikey_event_state.dart';
import 'package:strawberry/bloc/qrcode/qr_code_bloc.dart';
import 'package:strawberry/bloc/qrcode/try_login_qr_code_event_state.dart';
import 'package:strawberry/bloc/user/get_user_detail_event_state.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/nextui/base_screen.dart';
import 'package:strawberry/ui/login/login_center.dart';
import 'package:widgets/widgets/next_double_layer_blur_widget.dart';
import 'package:widgets/widgets/strawberry_icon.dart';

enum _QrCodeStatus {
  loading,
  uniKey,
  loginLoading,
  loginSuccess,
  loginFailure,
  failure,
}

class _QrCodeResult {
  final _QrCodeStatus status;
  final String? uniKey;
  final QrCodeResult? result;

  const _QrCodeResult(this.status, this.uniKey, this.result);

  @override
  bool operator ==(Object other) {
    if (other is! _QrCodeResult) {
      return false;
    }
    return status == other.status;
  }

  @override
  int get hashCode => status.hashCode;
}

class QrCodeLoginScreen extends BaseWidget {
  @override
  State<StatefulWidget> createState() => _QrCodeLoginScreenState();
}

class _QrCodeLoginScreenState extends BaseWidgetState {
  final QrCodeBloc qrCodeBloc = GetIt.instance.get();
  final AuthBloc authBloc = GetIt.instance.get();
  final UserBloc userBloc = GetIt.instance.get();
  StreamSubscription? userBlocSubscription;

  String? uniKey;
  QrCodeResult? qrCodeResult;
  bool refreshingToken = false;
  bool tryingLogin = false;

  @override
  void onStateCreate() {
    super.onStateCreate();
    setupListeners();
  }

  @override
  void onStateDestroy() {
    super.onStateDestroy();
    userBlocSubscription?.cancel();
    userBlocSubscription = null;
    qrCodeBloc.close();
    authBloc.close();
    userBloc.close();
    uniKey = null;
  }

  @override
  void onStateReady() {
    super.onStateReady();
    final desktopConfig = GetIt.instance.get<DesktopConfig>();
    final device = desktopConfig.device;

    authBloc.add(AttemptRegisterAnonimousEvent(deviceId: device.deviceId));
  }

  void setupListeners() {
    userBlocSubscription = userBloc.stream.listen((state) {
      if (state is GetUserDetailSuccess_Type1) {
        if (!mounted) {
          return;
        }
        LoginCenter.success(context);
      }
      if (state is GetUserDetailSuccess_Type2) {
        final account = state.pair.key;
        userBloc.add(
          AttemptGetUserDetailEvent_Type1(account.id, isLogin: true),
        );
      }
      if (state is UserFailure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizer.of(context)!.get_user_detail_failed,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        generate();
      }
    });
  }

  void refreshToken() {
    if (refreshingToken) {
      return;
    }
    refreshingToken = true;
    final generalConfig = GetIt.instance.get<GeneralConfig>();
    authBloc.add(AttemptRefreshTokenEvent_Type1(generalConfig.lastLoginId));
  }

  void generate() {
    uniKey = null;
    qrCodeResult = null;
    qrCodeBloc.add(AttemptGetOrCodeUniKeyEvent());
  }

  void login() {
    if (uniKey == null || tryingLogin) {
      return;
    }
    tryingLogin = true;
    qrCodeBloc.add(AttemptTryLoginQrCodeEvent(uniKey!));
  }

  void handleLoginSuccess(QrCodeResult result) {
    if (!tryingLogin) {
      return;
    }
    tryingLogin = false;
    if (result.needNextCheck()) {
      Timer(Duration(milliseconds: 500), () {
        login();
      });
    }

    if (result.isAuthorized()) {
      userBloc.add(AttemptGetUserDetailEvent_Type2(isLogin: true));
    }
  }

  void handleLoginFailure() {
    if (!tryingLogin) {
      return;
    }
    tryingLogin = false;
  }

  Widget buildQrCodeContent() {
    return BlocSelector<QrCodeBloc, QrCodeState, _QrCodeResult>(
      bloc: qrCodeBloc,
      selector: (state) {
        _QrCodeStatus status = _QrCodeStatus.failure;

        if (state is GetQrCodeUniKeySuccess) {
          uniKey = state.uniKey;
          qrCodeResult = null;
          status = _QrCodeStatus.uniKey;
          login();
        }
        if (state is QrCodeLoading) {
          status = _QrCodeStatus.loading;
        }
        if (state is QrCodeFailure) {
          status = _QrCodeStatus.failure;
        }
        if (state is TryLoginQrCodeLoading) {
          status = _QrCodeStatus.loginSuccess;
        }
        if (state is TryLoginQrCodeSuccess) {
          handleLoginSuccess(state.result);
          status = _QrCodeStatus.loginSuccess;
          qrCodeResult = state.result;
        }
        if (state is TryLoginQrCodeFailure) {
          handleLoginFailure();
          status = _QrCodeStatus.loginFailure;
        }
        return _QrCodeResult(status, uniKey, qrCodeResult);
      },
      builder: (context, selected) {
        final status = selected.status;
        final uniKey = selected.uniKey;
        final result = selected.result;

        QrImage? qrImage;
        if (uniKey != null) {
          final qrCode = QrCode(8, QrErrorCorrectLevel.L);
          qrCode.addData("https://music.163.com/login?codekey=$uniKey");
          qrImage = QrImage(qrCode);
        }

        Widget? overlay;
        if (status == _QrCodeStatus.failure ||
            status == _QrCodeStatus.loginFailure) {
          overlay = ElevatedButton(
            onPressed: () {
              generate();
            },
            child: Text("Error"),
          );
        }
        if (status == _QrCodeStatus.loading) {
          overlay = CircularProgressIndicator();
        }
        if (result != null && result.isAuthorizing()) {
          overlay = Text("Authorizing");
        }
        if (result != null && result.isExpired()) {
          overlay = CircularProgressIndicator();
          generate();
        }

        return NextDoubleBlurWidget(
          bottom: Padding(
            padding: EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              switchInCurve: Curves.fastEaseInToSlowEaseOut,
              switchOutCurve: Curves.fastEaseInToSlowEaseOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child:
                  uniKey?.isNotEmpty == true
                      ? PrettyQrView(qrImage: qrImage!)
                      : SizedBox.shrink(),
            ),
          ),
          overlay: overlay,
          blur: (uniKey?.isNotEmpty == true) && overlay == null ? 0 : 10,
        );
      },
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final iconId = ConstraintId("icon");

    final size = MediaQuery.of(context).size;
    final squareSize = size.width > size.height ? size.height : size.width;
    double cardSize = squareSize > 160 ? 160 : squareSize / 2;

    return Scaffold(
      body: ConstraintLayout(
        children: [
          Hero(
            tag: "strawberry_icon",
            child: StrawberryIcon.window(context),
          ).applyConstraint(
            id: iconId,
            top: parent.top,
            left: parent.left,
            right: parent.right,
            margin: EdgeInsets.only(top: screenSize!.height / 6),
          ),

          SmoothContainer(
            width: cardSize,
            height: cardSize,
            borderRadius: BorderRadius.circular(24),
            color:
                isDarkMode()
                    ? themeData().colorScheme.onSurface
                    : themeData().colorScheme.surfaceContainer,
            child: BlocSelector<AuthBloc, AuthState, AuthState>(
              bloc: authBloc,
              selector: (state) {
                return state;
              },
              builder: (context, state) {
                if (state is AuthInitial || state is AuthLoading) {
                  return CircularProgressIndicator();
                }
                if (state is RefreshTokenSuccess_Type1) {
                  refreshingToken = false;
                  LoginCenter.success(context);
                  return SizedBox.shrink();
                }
                if (state is RegisterAnonimousSuccess) {
                  refreshToken();
                  return CircularProgressIndicator();
                }
                if (state is AuthFailure ||
                    state is RefreshTokenSuccess_Type2) {
                  refreshingToken = false;
                  generate();
                  return buildQrCodeContent();
                }
                generate();
                return buildQrCodeContent();
              },
            ),
          ).applyConstraint(
            top: iconId.bottom,
            left: parent.left,
            right: parent.right,
            margin: EdgeInsets.only(top: 24),
          ),
        ],
      ),
    );
  }
}
