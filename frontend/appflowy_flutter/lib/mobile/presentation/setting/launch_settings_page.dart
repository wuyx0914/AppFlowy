import 'package:appflowy/mobile/presentation/base/app_bar/app_bar.dart';
import 'package:appflowy/mobile/presentation/presentation.dart';
import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileLaunchSettingsPage extends StatelessWidget {
  const MobileLaunchSettingsPage({
    super.key,
  });

  static const routeName = '/launch_settings';

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceSettingsCubit>();
    return Scaffold(
      appBar: FlowyAppBar(
        titleText: '设置',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Local-only build: self-host settings removed.
              const SupportSettingGroup(),
            ],
          ),
        ),
      ),
    );
  }
}
