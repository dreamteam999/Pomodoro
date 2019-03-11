public class Pomo.Window : Gtk.ApplicationWindow {
    private const string LIGHT_MODE = "display-brightness-symbolic";
    private const string DARK_MODE = "weather-clear-night-symbolic";
    int hbtn_counter = 0;

    public Window(Pomodoro application) {
        // TODO: Look into requesting position to stop window from jumping on open
        Object (application: application,
                height_request: 480,
                width_request: 800); //eliminate need to set size every start

        // TC: This also has other side effects, such as making the above dimesions the minimum size.
        // I don't consider this a bad thing, but in case we want the default size to be smaller
        // in the future, this is a good note to have
    }
    construct {
        border_width = 10;
        //connect before_destroy function to window termination for hi-jacking
        delete_event.connect(e => {
            //return false;
            return before_destroy();
        });

        //add buttons for headerbar
        var miscbutton = new Gtk.Button.with_label("New Timer (0)");
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER; //center in HB

        // add icon button -> submenu/popup
        var menu_button = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.valign = Gtk.Align.CENTER;

        //light/dark Granite.ModeSwitch
        var gtk_settings = Gtk.Settings.get_default ();
        var mode_switch = new Granite.ModeSwitch.from_icon_name (LIGHT_MODE, DARK_MODE);
        mode_switch.primary_icon_tooltip_text = "Light Mode";
        mode_switch.secondary_icon_tooltip_text = "Dark Mode";
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

        //initialize the headerbar
        var headerbar = new Gtk.HeaderBar ();
        headerbar.set_title("DreamTeam Pomodoro");
        headerbar.set_subtitle("What will you accomplish today?");
        headerbar.show_close_button = true;
        headerbar.pack_start(miscbutton); //push to  left of HB
        headerbar.pack_end (menu_button); //push to right of HB
        headerbar.pack_end (mode_switch);
        set_titlebar (headerbar); //activate the headerbar

        //button events
        //connect to miscbutton's "clicked" signal
        miscbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
			miscbutton.label = "I was clicked (%d) times!".printf (++this.hbtn_counter);
		});
        //connect menu buton
        menu_button.clicked.connect (() => {
			// Emitted when the button has been activated:
            miscbutton.label = "Settings requested";
		});


        //Recursively shows a widget, and any child widgets (if the widget is a container)
        show_all();
    }


    // This function normally returns false by default, and has no default actions
    // Here, we hi-jack the function to add saving the window dimensions and screen location to gsettings
    // so they can be re-loaded when the application is launched again.
    // Only after getting the current information and saving that info to gschema.xml does
    // the function return false and close the program as requested
    public bool before_destroy () {
        bool darkmode;
        int width, height, x, y;
        darkmode = Pomo.Window.construct.gtk_settings.gtk-widget-get-settings(mode_switch);
        get_size(out width, out height);
        get_position(out x, out y);
        Pomodoro.settings.set_int("position-x", x);
        Pomodoro.settings.set_int("position-y", y);
        Pomodoro.settings.set_int("window-width", width);
        Pomodoro.settings.set_int("window-height", height);
        if(darkmode) {
            Pomodoro.settings.set_boolean("dark-mode", true);
        } else {
            Pomodoro.settings.set_boolean("dark-mode", false); 
        }

        return false;
        }
}


