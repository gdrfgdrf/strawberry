import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/themes.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/login/login_center.dart';
import 'package:strawberry/ui/login/qr_code_login_page.dart';
import 'package:strawberry/ui/login/root_login_page_delegate.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';
import 'package:widgets/widgets/auto_spacer.dart';
import 'package:widgets/widgets/strawberry_icon.dart';

import '../../bloc/auth/refresh_token_event_state.dart';
import '../../bloc/auth/register_anonimous_event_state.dart';
import 'cellphone_login_page.dart';

enum LoginType {
  cellphone(Icons.phone_android),
  qrCode(Icons.qr_code);

  final IconData iconData;

  const LoginType(this.iconData);
}

class RootLoginPage extends AbstractUiWidget {
  @override
  State<StatefulWidget> createState() => _RootLoginPageState();
}

class _RootLoginPageState
    extends AbstractUiWidgetState<RootLoginPage, RootLoginPageDelegate> {
  @override
  RootLoginPageDelegate createDelegate() {
    return RootLoginPageDelegate();
  }

  @override
  void delegateReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      delegate!.prepareCookie();
    });
  }

  @override
  List<BlocListener> blocListeners() {
    return [
      BlocListener(
        bloc: delegate!.authBloc,
        listener: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return;
          }

          if (state is RegisterAnonimousSuccess) {
            delegate!.onCookiePrepared();
            return;
          }
          if (state is AuthFailure) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       Localizer.of(context)!.login_preparation_error,
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // );
            return;
          }

          delegate!.tokenRefreshTried = true;

          if (state is RefreshTokenSuccess_Type1) {
            LoginCenter.success(context);
            return;
          }

          if (state is RefreshTokenSuccess_Type2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
      ),
    ];
  }

  Widget buildFloatingActionButton() {
    final switchAnimation = SmoothWidgetSwitchAnimation(
      key: ValueKey<int>(delegate!.animationUpdateKey),
      before:
          delegate!.previousLoginType != null
              ? Icon(delegate!.previousLoginType!.iconData)
              : SizedBox.shrink(),

      after: Icon(delegate!.loginType!.iconData),
      duration: Duration(milliseconds: 500),
    );

    AnimationCombinationBuilder()
        .add(switchAnimation)
        .build(
          onReady: (animation) {
            animation.forwardAll();
          },
        );

    return FloatingActionButton(
      onPressed: () {
        delegate!.onFloatingActionButtonPressed();
      },
      backgroundColor: themeData().colorScheme.surfaceContainerLow,
      child: switchAnimation,
    );
  }

  @override
  void initState() {
    super.initState();

    delegate!.loginType = LoginType.cellphone;
    delegate!.pages.add(CellphoneLoginPage());
    delegate!.pages.add(QrCodeLoginPage());

    delegate!.pageController = PageController();
  }

  @override
  void dispose() {
    delegate!.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    if (delegate!.loginType == null) {
      throw ArgumentError("login type is not initialized");
    }

    final switchAnimation = SmoothWidgetSwitchAnimation(
      before: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
      after: PageView(
        controller: delegate!.pageController,
        onPageChanged: delegate!.onPageChanged,
        children: delegate!.pages,
      ),
      duration: Duration(milliseconds: 500),
    );

    AnimationCombinationBuilder()
        .add(switchAnimation)
        .build(
          onReady: (animation) {
            delegate!.mainSwitchAnimation = animation;
            if (delegate!.cookiePreparedFromCache) {
              animation.forwardAll();
            }
          },
        );

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Container(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSpacer(0.1),

                  Hero(
                    tag: "strawberry_icon",
                    child: StrawberryIcon.window(context),
                  ),

                  AutoSpacer(0.05),

                  Expanded(child: switchAnimation),
                ],
              ),
            ),
          ),

          if (delegate!.cookiePrepared)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8,
              child: buildFloatingActionButton(),
            ),
        ],
      ),
    );
  }
}
