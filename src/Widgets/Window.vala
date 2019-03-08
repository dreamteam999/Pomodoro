public class Pomo.Window : Gtk.ApplicationWindow {
    public GLib.Settings settings;

    public Window(Pomodoro application) {
        Object(
            application: application
        );
    }
    construct {
        //title = "DreamTeam Pomodoro";

        border_width = 10;
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size(640, 480);

        settings = new GLib.Settings("com.github.DreamTeam999.Pomodoro");

        move(settings.get_int("position-x"), settings.get_int("position-y"));
        resize(settings.get_int("window-width"), settings.get_int("window-height"));

        delete_event.connect(e => {
            return before_destroy();
        });

        var headerbar = new Pomo.HeaderBar();
        set_titlebar(headerbar);

        show_all();
    }

    public bool before_destroy() {
        int width, height, x, y;

        get_size(out width, out height);
        get_position(out x, out y);

        settings.set_int("position-x", x);
        settings.set_int("position-y", y);
        settings.set_int("window-width", width);
        settings.set_int("window-height", height);

        return false;
    }

}


