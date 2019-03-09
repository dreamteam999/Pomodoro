public class Pomo.HeaderBar : Gtk.HeaderBar {
    construct {
        // set title
        set_title("DreamTeam Pomodoro");

        // set subtitle
        set_subtitle("Filler text!");

        // add button
        // set_show_close_button allows the default maximaize/restore, and close buttons to show in the headerbar
        set_show_close_button(true);

        // custom label button creation, styled with the suggested-action css style, aligned to
        // center vertically, and placed at the start of the headerbar (after close of course)
        var miscbutton = new Gtk.Button.with_label("Click me (0)");
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER;
        pack_start(miscbutton);

        // add icon button -> submenu/popup
        var menu_button = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.valign = Gtk.Align.CENTER;
        pack_end(menu_button);
    }
}
