project(
    'com.github.DreamTeam999.Pomodoro',
    ['vala', 'c'],
    version: '0.0.1',
    license: 'GPL2',
)

gtk = dependency('gtk+-3.0')
glib = dependency('glib-2.0')
granite = dependency('granite', version: '>=0.5')

cc = meson.get_compiler('c')
math = cc.find_library('m', required: false)

meson.add_install_script('meson/post_install.py')

subdir('src')
subdir('data')
