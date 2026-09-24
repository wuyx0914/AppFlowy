import 'package:appflowy/plugins/database/application/sync/database_sync_bloc.dart';
import 'package:appflowy/plugins/document/application/document_sync_bloc.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-document/entities.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:flowy_infra_ui/widget/flowy_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentSyncIndicator extends StatelessWidget {
  const DocumentSyncIndicator({
    super.key,
    required this.view,
  });

  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DocumentSyncBloc(view: view)..add(const DocumentSyncEvent.initial()),
      child: BlocBuilder<DocumentSyncBloc, DocumentSyncBlocState>(
        builder: (context, state) {
          // don't show indicator if user is local
          if (!state.shouldShowIndicator) {
            return const SizedBox.shrink();
          }
          final Color color;
          final String hintText;

          if (!state.isNetworkConnected) {
            color = Colors.grey;
            hintText = '没有连接网络';
          } else {
            switch (state.syncState) {
              case DocumentSyncState.SyncFinished:
                color = Colors.green;
                hintText = '已同步';
                break;
              case DocumentSyncState.Syncing:
              case DocumentSyncState.InitSyncBegin:
                color = Colors.yellow;
                hintText = '同步中';
                break;
              default:
                return const SizedBox.shrink();
            }
          }

          return FlowyTooltip(
            message: hintText,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              width: 8,
              height: 8,
            ),
          );
        },
      ),
    );
  }
}

class DatabaseSyncIndicator extends StatelessWidget {
  const DatabaseSyncIndicator({
    super.key,
    required this.view,
  });

  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DatabaseSyncBloc(view: view)..add(const DatabaseSyncEvent.initial()),
      child: BlocBuilder<DatabaseSyncBloc, DatabaseSyncBlocState>(
        builder: (context, state) {
          // don't show indicator if user is local
          if (!state.shouldShowIndicator) {
            return const SizedBox.shrink();
          }
          final Color color;
          final String hintText;

          if (!state.isNetworkConnected) {
            color = Colors.grey;
            hintText = '没有连接网络';
          } else {
            switch (state.syncState) {
              case DatabaseSyncState.SyncFinished:
                color = Colors.green;
                hintText = '已同步';
                break;
              case DatabaseSyncState.Syncing:
              case DatabaseSyncState.InitSyncBegin:
                color = Colors.yellow;
                hintText = '同步中';
                break;
              default:
                return const SizedBox.shrink();
            }
          }

          return FlowyTooltip(
            message: hintText,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              width: 8,
              height: 8,
            ),
          );
        },
      ),
    );
  }
}
