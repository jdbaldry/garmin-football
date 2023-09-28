using Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

class SubMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0;
    pre_0 = 0;
    var id = item.getId().toString() as String;

    var menu = new WatchUi.Menu2({ :title => "Assist" });
    var players = split(
      Properties /*>Application.Properties<*/.getValue("Players"),
      ","
    );

    {
      item /*>i<*/ = pre_0;
      for (; item /*>i<*/ < players.size(); item /*>i<*/ += 1) {
        menu.addItem(
          new MenuItem(players[item /*>i<*/], "", players[item /*>i<*/], {})
        );
      }
    }

    switch (id) {
      case "In":
        WatchUi.pushView(
          menu,
          new InMenuDelegate(),
          pre_0 as Toybox.WatchUi.SlideType
        );

        break;

      case "Out":
        WatchUi.pushView(
          menu,
          new OutMenuDelegate(),
          pre_0 as Toybox.WatchUi.SlideType
        );

        break;
    }
  }
}
