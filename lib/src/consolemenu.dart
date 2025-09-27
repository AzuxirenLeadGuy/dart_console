import 'dart:math' as math;
import 'package:dart_console/dart_console.dart' as dart_console;
import 'package:dart_console/src/consolecolor.dart' as cc;
import 'package:dart_console/src/textalignment.dart' as align;

enum MenuSearchMode {
  disabled,
  exactSearch,
  caseInsensitiveSearch,
}

/// Represents a Menu that will be drawn in the console
class ConsoleMenu {
  /// The prompt for selection
  late final String prompt;
  /// The console instance running
  final dart_console.Console console;
  /// If true, a custom summary will be printed after an option is selected
  final bool clearsummaryAfterDone;
  /// Specifes the search mode
  final MenuSearchMode searchMode;
  /// The foreground of the prompt header
  final cc.ConsoleColor promptForeground;
  /// The background color of the currently selected item
  final cc.ConsoleColor selectionBackground;
  /// The number of rows for a given page of search results
  late final int searchHeight;
  /// The width of the console window
  late final int windowWidth;
  /// The set of options in our custom format
  final List<MapEntry<String, int>> _optionsMap;
  /// The set of filtered options in our custom format
  late List<MapEntry<String, int>> _filtered;
  /// The item currently selected
  int _selected;
  /// The search term entered so far
  String _searchTerm = "";

  ConsoleMenu(
    String promptText,
    List<String> options, {
    dart_console.Console? consoleInst,
    int startIdx = 0,
    this.clearsummaryAfterDone = true,
    this.searchMode = MenuSearchMode.disabled,
    this.promptForeground = cc.ConsoleColor.brightGreen,
    this.selectionBackground = cc.ConsoleColor.white,
  })  : _optionsMap = options
            .asMap()
            .entries
            .map((ety) => MapEntry(ety.value, ety.key))
            .toList(),
        console = consoleInst ?? dart_console.Console(),
        _selected = startIdx {
    windowWidth = console.windowWidth;
    searchHeight = console.windowHeight - 2;
    _filtered = _optionsMap;
    prompt = fitText(promptText);
  }

  String fitText(String text) {
    if (text.length >= windowWidth) {
      return "${text.substring(0, windowWidth - 3)}..";
    } else {
      return text;
    }
  }

  bool _drawMenu() {
    if (!console.hasTerminal || windowWidth < 4 || searchHeight < 2) {
      return false;
    }
    console.clearScreen();
    console.setForegroundColor(promptForeground);
    console.writeLine(
      prompt,
      align.TextAlignment.center,
    );
    console.resetColorAttributes();
    var curPage = _selected ~/ searchHeight;
    final limit = math.min(
      (curPage + 1) * searchHeight,
      _filtered.length,
    );
    for (int idx = curPage * searchHeight; idx < limit; idx++) {
      if (idx == _selected) {
        console.setBackgroundColor(selectionBackground);
      }
      console.writeLine(
        fitText(
          "${idx + 1}. ${_filtered[idx].key}",
        ),
      );
      if (idx == _selected) {
        console.resetColorAttributes();
      }
    }
    if (searchMode != MenuSearchMode.disabled) {
      console.write("Search term: $_searchTerm");
    }
    return true;
  }

  void _cleanupDraw() {
    if (clearsummaryAfterDone) {
      console.clearScreen();
      console.write("> $prompt : ");
      console.setForegroundColor(promptForeground);
      console.writeLine(_filtered[_selected].key);
      console.resetColorAttributes();
    }
  }

  List<MapEntry<String, int>> _filterSearch(
    List<MapEntry<String, int>> items,
    String term,
  ) {
    switch (searchMode) {
      case MenuSearchMode.caseInsensitiveSearch:
        return items.where((val) => val.key.toLowerCase().contains(term)).toList();
      default:
        return items.where((val) => val.key.contains(term)).toList();
    }
  }

  int? _inputMenu() {
    var key = console.readKey();

    if (!key.isControl) {
      if (searchMode == MenuSearchMode.disabled) return null;
      _searchTerm += searchMode == MenuSearchMode.exactSearch
          ? key.char
          : key.char.toLowerCase();
      _filtered = _filterSearch(_filtered, _searchTerm);
      _selected = 0;
    } else {
      switch (key.controlChar) {
        case dart_console.ControlCharacter.enter:
          return _filtered[_selected].value;

        case dart_console.ControlCharacter.backspace:
          if (_searchTerm.isEmpty) return null;
          _searchTerm = _searchTerm.substring(0, _searchTerm.length - 1);
          _filtered = _searchTerm.isEmpty
              ? _optionsMap
              : _filterSearch(_optionsMap, _searchTerm);
          _selected = 0;
          break;
        case dart_console.ControlCharacter.arrowDown:
          if (_selected < _filtered.length - 1) {
            _selected++;
          }
          break;
        case dart_console.ControlCharacter.arrowUp:
          if (_selected > 0) {
            _selected--;
          }
          break;
        default:
          break;
      }
    }
    return null;
  }

  int? run() {
    if (!_drawMenu()) {
      return null;
    }
    int? value;
    while ((value = _inputMenu()) == null) {
      _drawMenu();
    }
    _cleanupDraw();
    return value;
  }
}
