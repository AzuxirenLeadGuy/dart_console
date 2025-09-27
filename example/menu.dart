import 'package:dart_console/src/consolemenu.dart' as menu;

void main() {
  var fruitList = [
    "Apples",
    "Bananas",
    "Grapes",
    "Orange",
    "Pineapples",
    "Nectarines",
    "Kiwi",
    "Guava",
    "Avacado",
    "Strawberries",
    "Blueberries",
    "Blackberries",
    "Papaya",
    "Gooseberries",
    "Figs",
    "Jackfruits",
    "Peaches"
  ];
  int? idx = menu.ConsoleMenu(
    "Which fruit do you like",
    fruitList,
    searchMode: menu.MenuSearchMode.caseInsensitiveSearch,
  ).run();
  if (idx == null) {
    print("Could not draw the console menu!");
  } else {
    print("Oh yes, ${fruitList[idx]} are nice!");
  }
}
