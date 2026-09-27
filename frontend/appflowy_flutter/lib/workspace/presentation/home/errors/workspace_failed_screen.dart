import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WorkspaceFailedScreen extends StatefulWidget {
  const WorkspaceFailedScreen({super.key});

  @override
  State<WorkspaceFailedScreen> createState() => _WorkspaceFailedScreenState();
}

class _WorkspaceFailedScreenState extends State<WorkspaceFailedScreen> {
  String version = '';
  final String os = Platform.operatingSystem;

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  Future<void> initVersion() async {
    final platformInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = platformInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('出了些问题！我们无法加载工作区。请尝试关闭所有打开的 AppFlowy 实例，然后重试。'),
                const VSpace(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
