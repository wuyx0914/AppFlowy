import 'package:appflowy/features/workspace/logic/workspace_bloc.dart';
import 'package:appflowy/startup/startup.dart';
import 'package:appflowy/workspace/application/favorite/favorite_bloc.dart';
import 'package:appflowy/workspace/application/menu/sidebar_sections_bloc.dart';
import 'package:appflowy/workspace/application/sidebar/folder/folder_bloc.dart';
import 'package:appflowy/workspace/presentation/home/menu/menu_shared_state.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/favorites/favorite_folder.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/folder/_section_folder.dart';
import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SidebarFolder extends StatelessWidget {
  const SidebarFolder({
    super.key,
    this.isHoverEnabled = true,
    required this.userProfile,
  });

  final bool isHoverEnabled;
  final UserProfilePB userProfile;

  @override
  Widget build(BuildContext context) {
    const sectionPadding = 16.0;
    return ValueListenableBuilder(
      valueListenable: getIt<MenuSharedState>().notifier,
      builder: (context, value, child) {
        return Column(
          children: [
            const VSpace(4.0),
            // favorite
            BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                if (state.views.isEmpty) {
                  return const SizedBox.shrink();
                }
                return FavoriteFolder(
                  views: state.views.map((e) => e.item).toList(),
                );
              },
            ),
            // public or private
            BlocBuilder<SidebarSectionsBloc, SidebarSectionsState>(
              builder: (context, state) {
                // only show public and private section if the workspace is collaborative and not local
                final isCollaborativeWorkspace =
                    context.read<UserWorkspaceBloc>().state.isCollabWorkspaceOn;

                // only show public and private section if the workspace is collaborative
                return Column(
                  children: isCollaborativeWorkspace
                      ? [
                          // public
                          const VSpace(sectionPadding),
                          PublicSectionFolder(views: state.section.publicViews),

                          // private
                          const VSpace(sectionPadding),
                          PrivateSectionFolder(
                            views: state.section.privateViews,
                          ),
                        ]
                      : [
                          // personal
                          const VSpace(sectionPadding),
                          PersonalSectionFolder(
                            views: state.section.publicViews,
                          ),
                        ],
                );
              },
            ),
            const VSpace(200),
          ],
        );
      },
    );
  }
}

class PrivateSectionFolder extends SectionFolder {
  PrivateSectionFolder({super.key, required super.views})
      : super(
          title: '私人的',
          spaceType: FolderSpaceType.private,
          expandButtonTooltip: '点击以隐藏私人空间\n您在此处创建的页面仅对您可见',
          addButtonTooltip: '添加页面到私人空间',
        );
}

class PublicSectionFolder extends SectionFolder {
  PublicSectionFolder({super.key, required super.views})
      : super(
          title: '工作区',
          spaceType: FolderSpaceType.public,
          expandButtonTooltip: '点击以隐藏私人空间\n您在此处创建的页面对所有人可见',
          addButtonTooltip: '添加页面到工作空间',
        );
}

class PersonalSectionFolder extends SectionFolder {
  PersonalSectionFolder({super.key, required super.views})
      : super(
          title: '个人的',
          spaceType: FolderSpaceType.public,
          expandButtonTooltip: '点击隐藏个人部分',
          addButtonTooltip: '添加页面',
        );
}
