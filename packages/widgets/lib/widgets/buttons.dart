import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingButton extends StatelessWidget {
  final Function() onPressed;

  final Widget child;
  final Widget loadingChild;

  final ButtonStyle? style;

  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.loadingChild,
    required this.isLoading,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading ? loadingChild : child,
    );
  }
}

class BlocLoadingButton<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  final B bloc;

  final bool Function(S state) isLoading;
  final Function() onPressed;

  final Widget child;
  final Widget loadingChild;

  final ButtonStyle? style;

  const BlocLoadingButton({
    super.key,
    required this.bloc,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    required this.loadingChild,
    this.style,
  });

  static BlocLoadingButton create<Bloc extends StateStreamable<State>, State>({
    required Bloc bloc,
    required Function() onPressed,
    required bool Function(dynamic state) isLoading,
    Widget? child,
    Widget? loadingChild,
    ButtonStyle? style,
  }) {
    Widget? actualChild = child ??= Icon(Icons.check);
    Widget? actualLoadingChild =
        loadingChild ??= Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        );

    return BlocLoadingButton(
      bloc: bloc,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingChild: actualLoadingChild,
      style: style,
      child: actualChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,

      builder: (context, state) {
        return LoadingButton(
          isLoading: isLoading(state),
          onPressed: onPressed,
          loadingChild: loadingChild,
          style: style,
          child: child,
        );
      },
    );
  }
}
