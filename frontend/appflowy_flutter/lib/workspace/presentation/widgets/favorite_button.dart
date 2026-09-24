import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/application/favorite/favorite_bloc.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flowy_infra_ui/widget/flowy_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewFavoriteButton extends StatelessWidget {
  const ViewFavoriteButton({
    super.key,
    required this.view,
  });

  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFavorite = state.views.any((v) => v.item.id == view.id);
        return Listener(
          onPointerDown: (_) =>
              context.read<FavoriteBloc>().add(FavoriteEvent.toggle(view)),
          child: FlowyTooltip(
            message: isFavorite
                ? '从收藏夹中'
                : '添加到收藏夹',
            child: FlowyHover(
              resetHoverOnRebuild: false,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: FlowySvg(
                  isFavorite ? FlowySvgs.favorited_s : FlowySvgs.favorite_s,
                  size: const Size.square(18),
                  blendMode: isFavorite ? null : BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
