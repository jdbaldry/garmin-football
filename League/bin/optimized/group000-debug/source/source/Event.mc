using Toybox.Time;
import Toybox.Lang;

class Event {
  private var _kind as String;

  function initialize(kind as String) {
    _kind = kind;
  }

  function log() {
    $.jsonLog(["E", "E", "V", "log() not implemented"]);
  }
}

class TimeEvent extends Event {
  private var _time as String;

  function initialize() {
    Event.initialize("Time");
    _time = YYYYMMDD(Time.now());

    log();
  }

  function log() {
    jsonLog(["E", "T", "V", _time]);
  }
}

class MatchEvent extends Event {
  private var _action as String;

  function initialize(action as String) {
    Event.initialize("Match");
    _action = action;

    log();
  }

  function log() {
    jsonLog(["E", "M", "V", _action]);
  }
}

class BeginEvent extends MatchEvent {
  function initialize() {
    MatchEvent.initialize("B");
  }
}

class PauseEvent extends MatchEvent {
  function initialize() {
    MatchEvent.initialize("P");
  }
}

class StopEvent extends MatchEvent {
  function initialize() {
    MatchEvent.initialize("S");
  }
}

class KeeperEvent extends Event {
  private var _action as String;

  function initialize(action as String) {
    Event.initialize("Keeper");
    _action = action;

    log();
  }

  function log() {
    jsonLog(["E", "K", "V", _action]);
  }
}

class DefenceEvent extends Event {
  private var _action as String;

  function initialize(action as String) {
    Event.initialize("Defence");
    _action = action;

    log();
  }

  function log() {
    jsonLog(["E", "D", "V", _action]);
  }
}

class AttackEvent extends Event {
  private var _action as String;

  function initialize(action as String) {
    Event.initialize("Attack");
    _action = action;

    log();
  }

  function log() {
    jsonLog(["E", "A", "V", _action]);
  }
}

class GoalEvent extends Event {
  private var _player as String;

  function initialize(player as String) {
    Event.initialize("Goal");
    _player = player;

    log();
  }

  function log() {
    jsonLog(["E", "G", "V", _player]);
  }
}

class HelpEvent extends Event {
  private var _player as String;

  function initialize(player as String) {
    Event.initialize("Help");
    _player = player;

    log();
  }

  function log() {
    jsonLog(["E", "H", "V", _player]);
  }
}

class InEvent extends Event {
  private var _player as String;

  function initialize(player as String) {
    Event.initialize("In");
    _player = player;

    log();
  }

  function log() {
    jsonLog(["E", "I", "V", _player]);
  }
}

class OutEvent extends Event {
  private var _player as String;

  function initialize(player as String) {
    Event.initialize("Out");
    _player = player;

    log();
  }

  function log() {
    jsonLog(["E", "O", "V", _player]);
  }
}
