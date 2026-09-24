import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/workspace/application/settings/shortcuts/settings_shortcuts_service.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_shortcuts_cubit.freezed.dart';

@freezed
class ShortcutsState with _$ShortcutsState {
  const factory ShortcutsState({
    @Default(<CommandShortcutEvent>[])
    List<CommandShortcutEvent> commandShortcutEvents,
    @Default(ShortcutsStatus.initial) ShortcutsStatus status,
    @Default('') String error,
  }) = _ShortcutsState;
}

enum ShortcutsStatus {
  initial,
  updating,
  success,
  failure;

  /// Helper getter for when the [ShortcutsStatus] signifies
  /// that the shortcuts have not been loaded yet.
  ///
  bool get isLoading => [initial, updating].contains(this);

  /// Helper getter for when the [ShortcutsStatus] signifies
  /// a failure by itself being [ShortcutsStatus.failure]
  ///
  bool get isFailure => this == ShortcutsStatus.failure;

  /// Helper getter for when the [ShortcutsStatus] signifies
  /// a success by itself being [ShortcutsStatus.success]
  ///
  bool get isSuccess => this == ShortcutsStatus.success;
}

class ShortcutsCubit extends Cubit<ShortcutsState> {
  ShortcutsCubit(this.service) : super(const ShortcutsState());

  final SettingsShortcutService service;

  Future<void> fetchShortcuts() async {
    emit(
      state.copyWith(
        status: ShortcutsStatus.updating,
        error: '',
      ),
    );

    try {
      final customizeShortcuts = await service.getCustomizeShortcuts();
      await service.updateCommandShortcuts(
        commandShortcutEvents,
        customizeShortcuts,
      );

      //sort the shortcuts
      commandShortcutEvents.sort(
        (a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()),
      );

      emit(
        state.copyWith(
          status: ShortcutsStatus.success,
          commandShortcutEvents: commandShortcutEvents,
          error: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ShortcutsStatus.failure,
          error: '无法加载快捷键，请再次尝试',
        ),
      );
    }
  }

  Future<void> updateAllShortcuts() async {
    emit(state.copyWith(status: ShortcutsStatus.updating, error: ''));

    try {
      await service.saveAllShortcuts(state.commandShortcutEvents);
      emit(state.copyWith(status: ShortcutsStatus.success, error: ''));
    } catch (e) {
      emit(
        state.copyWith(
          status: ShortcutsStatus.failure,
          error: '无法保存快捷键，请再次尝试',
        ),
      );
    }
  }

  Future<void> resetToDefault() async {
    emit(state.copyWith(status: ShortcutsStatus.updating, error: ''));

    try {
      await service.saveAllShortcuts(defaultCommandShortcutEvents);
      await fetchShortcuts();
    } catch (e) {
      emit(
        state.copyWith(
          status: ShortcutsStatus.failure,
          error: '无法保存快捷键，请再次尝试',
        ),
      );
    }
  }

  /// Checks if the new command is conflicting with other shortcut
  /// We also check using the key, whether this command is a codeblock
  /// shortcut, if so we only check a conflict with other codeblock shortcut.
  CommandShortcutEvent? getConflict(
    CommandShortcutEvent currentShortcut,
    String command,
  ) {
    // check if currentShortcut is a codeblock shortcut.
    final isCodeBlockCommand = currentShortcut.isCodeBlockCommand;

    for (final shortcut in state.commandShortcutEvents) {
      final keybindings = shortcut.command.split(',');
      if (keybindings.contains(command) &&
          shortcut.isCodeBlockCommand == isCodeBlockCommand) {
        return shortcut;
      }
    }

    return null;
  }
}

extension on CommandShortcutEvent {
  bool get isCodeBlockCommand => localizedCodeBlockCommands.contains(this);
}
