import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/ui/home/desktop/desktop_home_page.dart';
import 'package:strawberry/ui/home/mobile/mobile_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PlatformExtension.isMobile ? MobileHomePage() : DesktopHomePage();
  }
}
