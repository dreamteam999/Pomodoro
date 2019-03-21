namespace Pomodoro {

public class Application : Gtk.Application {

    public Application () {
        Object(application_id: "com.github.DreamTeam999.Pomodoro", flags: ApplicationFlags.FLAGS_NONE);
    }

    private Window window;

    construct {
        //setup gsettings as a global obj
        //settings = new GLib.Settings ("com.github.DreamTeam999.Pomodoro");
    }

    protected override void activate () {
        window = new Window (this); //new window object defined in Window.vala

        add_window (window);
    }
}
} //namespace Pomodoro