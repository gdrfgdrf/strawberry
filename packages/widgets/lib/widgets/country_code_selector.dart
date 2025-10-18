import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:shared/country.dart';

import 'dropdownmenu/smooth_dropdown_menu.dart';

enum FlagShape { circle, rectangle, rounded }

class CountryCodeSelector extends StatefulWidget {
  final FlagShape shape;
  final double width;
  final double height;
  final double roundedBorderRadius;
  final Function(Country) onSelected;

  const CountryCodeSelector({
    super.key,
    required this.shape,
    required this.width,
    required this.height,
    required this.roundedBorderRadius,
    required this.onSelected
  });

  @override
  State<StatefulWidget> createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  static List<DropdownMenuEntry<CountryFlag>> entries = [];
  CountryFlag? selectedValue;

  void countrySelected(CountryFlag flag) {
    setState(() {
      selectedValue = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    generateFlags();

    if (selectedValue == null) {
      switch (widget.shape) {
        case FlagShape.circle:
          {
            selectedValue = Country.china.circleFlag(widget.width, widget.height);
          }
        case FlagShape.rectangle:
          {
            selectedValue = Country.china.rectangleFlag(
              widget.width,
              widget.height,
            );
          }
        case FlagShape.rounded:
          {
            selectedValue = Country.china.roundedFlag(
              widget.width,
              widget.height,
              widget.roundedBorderRadius,
            );
          }
      }
    }

    final china = entries.firstWhere((country) {
      if (country.value.flagCode == "cn") {
        return true;
      }
      return false;
    });

    return SmoothDropdownMenu(
      entries: entries,
      initialEntry: china,
      onSelected: (entry) {
        final country = Country.values.firstWhere((country) {
          if (country.code == entry.value.flagCode?.toUpperCase()) {
            return true;
          }
          return false;
        });

        widget.onSelected(country);
      },
    );
  }

  void generateFlags() {
    if (entries.isEmpty) {
      switch (widget.shape) {
        case FlagShape.circle:
          {
            final flags = Country.listCircle(widget.width, widget.height);
            for (int i = 0; i < Country.values.length; i++) {
              final flag = flags[i];
              final country = Country.values[i];
              entries.add(
                DropdownMenuEntry<CountryFlag>(
                  value: flag,
                  label: "+${country.number}",
                  leadingIcon: flag,
                ),
              );
            }
          }
        case FlagShape.rectangle:
          {
            final flags = Country.listRectangle(widget.width, widget.height);
            for (int i = 0; i < Country.values.length; i++) {
              final flag = flags[i];
              final country = Country.values[i];
              entries.add(
                DropdownMenuEntry<CountryFlag>(
                  value: flag,
                  label: "+${country.number}",
                  leadingIcon: flag,
                ),
              );
            }
          }
        case FlagShape.rounded:
          {
            final flags = Country.listRounded(
              widget.width,
              widget.height,
              widget.roundedBorderRadius,
            );
            for (int i = 0; i < Country.values.length; i++) {
              final flag = flags[i];
              final country = Country.values[i];
              entries.add(
                DropdownMenuEntry<CountryFlag>(
                  value: flag,
                  label: "+${country.number}",
                  leadingIcon: flag,
                ),
              );
            }
          }
      }
    }
  }
}
