import 'package:flutter/cupertino.dart';
import 'package:shared/themes.dart';
import 'package:widgets/widgets/strawberry_icon.dart';

class StrawberryTitle extends StatelessWidget {
  final bool hero;

  const StrawberryTitle({super.key, this.hero = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hero)
          Hero(
            tag: "strawberry_icon",
            child: StrawberryIcon(50, 50, elevation: 0),
          ),
        if (!hero) StrawberryIcon(50, 50, elevation: 0),

        SizedBox(width: 8),
        Text(
          'Strawberry',
          style: TextStyle(
            color: themeData().colorScheme.onSurfaceVariant,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
