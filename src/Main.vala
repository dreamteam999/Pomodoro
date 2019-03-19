public static int main (string[] args) {
        // Create new Pomodoro object defined in Pomodoro.vala
        var app = new Pomodoro.Application ();
        return app.run (args);
}
