import 'package:flutter/material.dart';
import 'package:widgets/widgets/listview/animated_list_item.dart';

class OptimizedDropdownMenuItem<T> extends StatelessWidget {
  final DropdownMenuEntry<T> entry;
  final Function(DropdownMenuEntry<T>) onSelected;
  final double itemHeight;

  const OptimizedDropdownMenuItem({
    super.key,
    required this.entry,
    required this.onSelected,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      child: InkWell(
        onTap: () {
          onSelected(entry);
        },
        child: Container(
          height: itemHeight,
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Row(
            children: [
              entry.leadingIcon ?? SizedBox.shrink(),

              SizedBox(width: 10),

              Text(
                entry.label,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
