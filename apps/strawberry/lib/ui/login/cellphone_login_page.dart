import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/bloc/auth/login_event_state.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/login/cellphone_login_page_delegate.dart';
import 'package:strawberry/ui/login/login_center.dart';
import 'package:widgets/widgets/auto_spacer.dart';
import 'package:widgets/widgets/built_text_field.dart';
import 'package:widgets/widgets/buttons.dart';
import 'package:widgets/widgets/country_code_selector.dart';

class CellphoneLoginPage extends AbstractUiWidget {
  const CellphoneLoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _CellphoneLoginPageState();
}

class _CellphoneLoginPageState
    extends
        AbstractUiWidgetState<CellphoneLoginPage, CellphoneLoginPageDelegate> {
  @override
  CellphoneLoginPageDelegate createDelegate() {
    return CellphoneLoginPageDelegate();
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(
        bloc: delegate!.authBloc,
        listener: (context, state) async {
          if (state is LoginSuccess) {
            LoginCenter.success(context);
          }
          if (state is AuthFailure) {
            final message = state.failure.error.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message, textAlign: TextAlign.center)),
            );
          }
        },
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildTextFields(),

        AutoSpacer(0.05),

        BlocLoadingButton.create(
          bloc: delegate!.authBloc,
          onPressed: () {
            delegate!.attemptLogin(context);
          },
          isLoading: (state) => state is AuthLoading,
        ),
      ],
    );
  }

  Widget buildTextFields() {
    return Column(
      children: [
        FractionallySizedBox(
          widthFactor: 0.8,
          child:
              TextFieldBuilder.newBuilder()
                  .hintOf(Localizer.of(context)!.cellphone_here)
                  .alignOf(TextAlign.center)
                  .iconOf(
                    FractionallySizedBox(
                      widthFactor: 0.2,
                      child: CountryCodeSelector(
                        shape: FlagShape.rectangle,
                        width: 24,
                        height: 24,
                        roundedBorderRadius: -1,
                        onSelected: (country) {
                          delegate!.countryCode = country.number;
                        },
                      ),
                    ),
                  )
                  .onChangedOf((text) {
                    delegate!.cellphone = text;
                  })
                  .normal(context)
                  .buildNormal(),
        ),

        FractionallySizedBox(widthFactor: 0.5, child: Divider()),

        FractionallySizedBox(
          widthFactor: 0.8,
          child:
              TextFieldBuilder.newBuilder()
                  .password(context)
                  .alignOf(TextAlign.center)
                  .onChangedOf((text) {
                    delegate!.password = text;
                  })
                  .buildPassword(),
        ),
      ],
    );
  }
}
