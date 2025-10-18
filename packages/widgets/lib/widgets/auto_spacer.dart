
import 'package:flutter/cupertino.dart';

class AutoSpacer extends StatefulWidget {
  final double _factor;

  const AutoSpacer(this._factor, {super.key});

  @override
  State<StatefulWidget> createState() => _AutoSpacerState();
}

class _AutoSpacerState extends State<AutoSpacer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * widget._factor,
    );
  }
}

