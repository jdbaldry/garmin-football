using Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

class AttackMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    var pre_0;
    pre_0 = 0;
    switch (item.getId().toString() as String) {
      // TODO: Add player and assist player.
      case "Goal":
        var menu = new WatchUi.Menu2({ :title => "Goal" });
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
        WatchUi.pushView(
          menu,
          new GoalMenuDelegate(),
          pre_0 as Toybox.WatchUi.SlideType
        );

        break;

      case "Miss":
        EVENTS.add(new AttackEvent("M"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;

      case "Save":
        EVENTS.add(new AttackEvent("S"));

        popView(pre_0 as Toybox.WatchUi.SlideType);

        break;
    }
  }
}
