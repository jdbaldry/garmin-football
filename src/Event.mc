public class Event {
    private var _kind as String;

    public function initialize(kind as String) {
        _kind = kind;
    }

    public function jsonLog() {
        throw new NotImplementedException("jsonLog");
    }
}

public class ActionEvent extends Event {
    private var _action as String;

    public function initialize(action as String) {
        Event.initialize("A")
        _action = action;

        jsonLog()
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "value", _action]);
    }
}

public class StartedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("started")
    }
}

public class PausedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("paused")
    }
}

public class StoppedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("stopped")
    }
}

public class SavedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("saved")
    }
}

public class KeeperEvent extends Event {
    private var _team as String;
    private var _player as String;

    public function initialize(team as String, player as String) {
        Event.initialize("K")
        _team = team;
        _player = player;


        jsonLog();
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class GoalEvent extends Event {
    private var _team as String;
    private var _player as String;
    private var _keeper as String;

    public function initialize(team as String, player as String, keeper as String) {
        Event.initialize("G")
        _team = team;
        _player = player;
        _keeper = keeper;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CaptainEvent extends Event {
    private var _team as String;
    private var _captain as String;

    public function initialize(team as String, captain as String) {
        Event.initialize("C")
        _team = team;
        _captain = captain;

        jsonLog()
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class TeamEvent extends Event {
    private var _team;
    private var _players;

    public function initialize(team, players) {
        Event.initialize("T")
        _team = team;
        _players = players;

        jsonLog()
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "players", _players]);
    }
}

public class OwnGoalEvent extends Event {
    private var _team as String;
    private var _player as String;
    private var _keeper as String;

    public function initialize(team as String, player as String, keeper as String) {
        Event.initialize("OG")
        _team = team;
        _player = player;
        _keeper = keeper;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CardEvent extends Event {
    private var _team as String;
    private var _player as String;

    public function initialize(kind as String, team as String, player as String) {
        Event.initialize(kind)
        _team = team;
        _player = player;
    }

    public function jsonLog() {
        $.jsonLog(["event", _event, "team", _team, "player", _player]);
    }
}

public class YellowCardEvent extends CardEvent {
    public function initialize(team, player) {
        CardEvent.initialize("YC", team, player)
    }
}

public class RedCardEvent extends Event {
    public function initialize(team, player) {
        CardEvent.initialize("RC", team, player)
    }
}
