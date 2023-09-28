using Toybox.System;
using Rez;
import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.WatchUi;

var MATCH_STATE = 0;
var SESSION as Session?;
var EVENTS as Array<Event> = [];

var SCORE_A = 0;
var SCORE_B = 0;

class LeagueDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  // MATCH
  function onSelect() as Boolean {
    pushView(
      new Rez.Menus.Activity(),
      new MatchMenuDelegate(),
      4 as Toybox.WatchUi.SlideType
    );

    return true;
  }

  // OTHER
  //
  //  SUB ---> OFF[PLAYER] ---> ON[PLAYER]
  // CARD ---> YELLOW[PLAYER]
  //      `-->  RED[PLAYER]
  function onMenu() as Boolean {
    if (MATCH_STATE == 1) {
      pushView(
        new Rez.Menus.Sub(),
        new SubMenuDelegate(),
        4 as Toybox.WatchUi.SlideType
      );
    }

    return true;
  }

  // KEEPER
  function onBack() as Boolean {
    if (MATCH_STATE == 1) {
      pushView(
        new Rez.Menus.Keeper(),
        new KeeperMenuDelegate(),
        4 as Toybox.WatchUi.SlideType
      );
    }

    return true;
  }

  function onKey(evt as KeyEvent) as Boolean {
    if (MATCH_STATE == 1) {
      switch (evt.getKey()) {
        // ATTACK
        case 13 as Toybox.WatchUi.Key:
          pushView(
            new Rez.Menus.Attack(),
            new AttackMenuDelegate(),
            4 as Toybox.WatchUi.SlideType
          );

          return true;

        // DEFENCE
        case 8 as Toybox.WatchUi.Key:
          pushView(
            new Rez.Menus.Defence(),
            new DefenceMenuDelegate(),
            4 as Toybox.WatchUi.SlideType
          );

          return true;

        default:
          System.println("Unhandled key: " + evt.getKey());

          return false;
      }
    }

    return true;
  }
}
