using Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

class GoalMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) as Void {
    item /*>id<*/ = item.getId().toString() as String;

    EVENTS.add(new GoalEvent(item /*>id<*/));
    SCORE_A += 1;

    var menu = new WatchUi.Menu2({ :title => "Assist" });
    var players = split(
      Properties /*>Application.Properties<*/.getValue("Players"),
      ","
    );

    {
      item /*>i<*/ = 0;
      for (; item /*>i<*/ < players.size(); item /*>i<*/ += 1) {
        menu.addItem(
          new MenuItem(players[item /*>i<*/], "", players[item /*>i<*/], {})
        );
      }
    }
    WatchUi.pushView(
      menu,
      new AssistMenuDelegate(),
      0 as Toybox.WatchUi.SlideType
    );
  }
}
