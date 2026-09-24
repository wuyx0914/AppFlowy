import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/workspace/application/sidebar/space/space_bloc.dart';
import 'package:flutter/material.dart';

class SpacePermissionBottomSheet extends StatelessWidget {
  const SpacePermissionBottomSheet({
    super.key,
    required this.onAction,
    required this.permission,
  });

  final SpacePermission permission;
  final void Function(SpacePermission action) onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowyOptionTile.text(
          text: '民众',
          leftIcon: const FlowySvg(
            FlowySvgs.space_permission_public_s,
          ),
          trailing: permission == SpacePermission.publicToAll
              ? const FlowySvg(
                  FlowySvgs.m_blue_check_s,
                  blendMode: null,
                )
              : null,
          onTap: () => onAction(SpacePermission.publicToAll),
        ),
        FlowyOptionTile.text(
          text: '私人',
          showTopBorder: false,
          leftIcon: const FlowySvg(
            FlowySvgs.space_permission_private_s,
          ),
          trailing: permission == SpacePermission.private
              ? const FlowySvg(
                  FlowySvgs.m_blue_check_s,
                  blendMode: null,
                )
              : null,
          onTap: () => onAction(SpacePermission.private),
        ),
      ],
    );
  }
}
