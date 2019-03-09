public class Pomo.Window : Gtk.ApplicationWindow {
    public GLib.Settings settings;

    public Window(Pomodoro application) {
        Object(
            application: application
        );
    }
    construct {
        //setup application defaults
        border_width = 10;
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size(640, 480);

        //setup gsettings, initialize the object with our application
        settings = new GLib.Settings("com.github.DreamTeam999.Pomodoro");

        //pull screen location and window dimensions from gsettings (see data/gschema.xml)
        move(settings.get_int("position-x"), settings.get_int("position-y"));
        resize(settings.get_int("window-width"), settings.get_int("window-height"));

        //connect before_destroy function to window termination for hi-jacking
        delete_event.connect(e => {
            return before_destroy();
        });

        //initialize the headerbar, defined in Widgets/HeaderBar.vala
        var headerbar = new Pomo.HeaderBar();
        set_titlebar(headerbar);

        //Recursively shows a widget, and any child widgets (if the widget is a container)
        show_all();
    }


    // This function normally returns false by default, and has no default actions
    // Here, we hi-jack the function to add saving the window dimensions and screen location to gsettings
    // so they can be re-loaded when the application is launched again.
    // Only after getting the current information and saving that info to gschema.xml does
    // the function return false and close the program as requested

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


