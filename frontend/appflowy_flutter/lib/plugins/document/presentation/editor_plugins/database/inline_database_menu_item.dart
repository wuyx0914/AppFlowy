import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/application/document_bloc.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/insert_page_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/workspace/application/view/view_service.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

SelectionMenuItem inlineGridMenuItem(DocumentBloc documentBloc) =>
    SelectionMenuItem(
      getName: () => '新建网格',
      icon: (editorState, onSelected, style) => SelectableSvgWidget(
        data: FlowySvgs.grid_s,
        isSelected: onSelected,
        style: style,
      ),
      keywords: ['grid', 'database'],
      handler: (editorState, menuService, context) async {
        // create the view inside current page
        final parentViewId = documentBloc.documentId;
        final value = await ViewBackendService.createView(
          parentViewId: parentViewId,
          name: '未命名页面',
          layoutType: ViewLayoutPB.Grid,
        );
        value.map((r) => editorState.insertInlinePage(parentViewId, r));
      },
    );

SelectionMenuItem inlineBoardMenuItem(DocumentBloc documentBloc) =>
    SelectionMenuItem(
      getName: () => '新建看板',
      icon: (editorState, onSelected, style) => SelectableSvgWidget(
        data: FlowySvgs.board_s,
        isSelected: onSelected,
        style: style,
      ),
      keywords: ['board', 'kanban', 'database'],
      handler: (editorState, menuService, context) async {
        // create the view inside current page
        final parentViewId = documentBloc.documentId;
        final value = await ViewBackendService.createView(
          parentViewId: parentViewId,
          name: '未命名页面',
          layoutType: ViewLayoutPB.Board,
        );
        value.map((r) => editorState.insertInlinePage(parentViewId, r));
      },
    );

SelectionMenuItem inlineCalendarMenuItem(DocumentBloc documentBloc) =>
    SelectionMenuItem(
      getName: () => '新建日历',
      icon: (editorState, onSelected, style) => SelectableSvgWidget(
        data: FlowySvgs.date_s,
        isSelected: onSelected,
        style: style,
      ),
      keywords: ['calendar', 'database'],
      handler: (editorState, menuService, context) async {
        // create the view inside current page
        final parentViewId = documentBloc.documentId;
        final value = await ViewBackendService.createView(
          parentViewId: parentViewId,
          name: '未命名页面',
          layoutType: ViewLayoutPB.Calendar,
        );
        value.map((r) => editorState.insertInlinePage(parentViewId, r));
      },
    );
