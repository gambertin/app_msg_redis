import 'dart:async';
import 'dart:io';
// import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:win_toast/win_toast.dart';

final channel = WebSocketChannel.connect(
  // Uri.parse('wss://echo.websocket.events'),
  Uri.parse('ws://localhost:3000?token=1234567'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Kerno's notifications";
    win.show();
  });
}

String getTrayImagePath(String imageName) {
  // return Platform.isWindows ? 'assets/$imageName.ico' : 'assets/$imageName.png';
  return Platform.isWindows ? './images/$imageName.ico' : './images/$imageName.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows ? './images/$imageName.bmp' : './images/$imageName.png';
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();
  final Menu _menuSimple = Menu();

  Timer? _timer;
  bool _toogleTrayIcon = true;

  bool _toogleMenu = true;

  @override
  void initState() {
    super.initState();
    initSystemTray();
    initializeToast();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void initializeToast() {
// initialize toast with you aumId, displayName and iconPath
    scheduleMicrotask(() async {
      await WinToast.instance().initialize(
      aumId: 'one.mixin.WinToastExample',
      displayName: 'Kerno\'s Application',
      iconPath: '',
      clsid: 'your-notification-activator-guid-2EB1AE5198B7',
    );});
  }

  Future<void> initSystemTray() async {
    // List<String> iconList = ['darts_icon', 'gift_icon'];

    debugPrint("antes de inicilizar el tray");
    debugPrint(" pepe  $getTrayImagePath('app_icon')");
    // We first init the systray menu and then add the menu entries
    // await _systemTray.initSystemTray(iconPath: getTrayImagePath('app_icon'));
    await _systemTray.initSystemTray(iconPath: './images/app_icon.ico');
    _systemTray.setTitle("system tray");
    _systemTray.setToolTip("How to use system tray with Flutter");

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });

    await _menuMain.buildFrom(
      [
        MenuItemLabel(
          label: 'Change Context Menu',
          image: getImagePath('darts_icon'),
          onClicked: (menuItem) {
            debugPrint("Change Context Menu");

            _toogleMenu = !_toogleMenu;
            _systemTray.setContextMenu(_toogleMenu ? _menuMain : _menuSimple);
          },
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Show', image: getImagePath('darts_icon'), onClicked: (menuItem) => _appWindow.show()),
        MenuItemLabel(label: 'Hide', image: getImagePath('darts_icon'), onClicked: (menuItem) => _appWindow.hide()),
        MenuItemLabel(
          label: 'Start flash tray icon',
          image: getImagePath('darts_icon'),
          onClicked: (menuItem) {
            debugPrint("Start flash tray icon");

            _timer ??= Timer.periodic(
              const Duration(milliseconds: 500),
              (timer) {
                channel.sink.add('${DateTime.now()} Icon flash started');
                _toogleTrayIcon = !_toogleTrayIcon;
                _systemTray.setImage(_toogleTrayIcon ? "" : getTrayImagePath('app_icon'));
              },
            );
          },
        ),
        MenuItemLabel(
          label: 'Stop flash tray icon',
          image: getImagePath('darts_icon'),
          onClicked: (menuItem) {
            debugPrint("Stop flash tray icon");
            channel.sink.add('${DateTime.now()} Icon flash stoped');

            _timer?.cancel();
            _timer = null;

            _systemTray.setImage(getTrayImagePath('app_icon'));
          },
        ),
        MenuSeparator(),
        // SubMenu(
        //   label: "Test API",
        //   image: getImagePath('gift_icon'),
        //   children: [
        //     SubMenu(
        //       label: "setSystemTrayInfo",
        //       image: getImagePath('darts_icon'),
        //       children: [
        //         MenuItemLabel(
        //           label: 'setTitle',
        //           image: getImagePath('darts_icon'),
        //           onClicked: (menuItem) {
        //             final String text = WordPair.random().asPascalCase;
        //             debugPrint("click 'setTitle' : $text");
        //             _systemTray.setTitle(text);
        //           },
        //         ),
        //         MenuItemLabel(
        //           label: 'setImage',
        //           image: getImagePath('gift_icon'),
        //           onClicked: (menuItem) {
        //             String iconName = iconList[Random().nextInt(iconList.length)];
        //             String path = getTrayImagePath(iconName);
        //             debugPrint("click 'setImage' : $path");
        //             _systemTray.setImage(path);
        //           },
        //         ),
        //         MenuItemLabel(
        //           label: 'setToolTip',
        //           image: getImagePath('darts_icon'),
        //           onClicked: (menuItem) {
        //             final String text = WordPair.random().asPascalCase;
        //             debugPrint("click 'setToolTip' : $text");
        //             _systemTray.setToolTip(text);
        //           },
        //         ),
        //         MenuItemLabel(
        //           label: 'getTitle',
        //           image: getImagePath('gift_icon'),
        //           onClicked: (menuItem) async {
        //             String title = await _systemTray.getTitle();
        //             debugPrint("click 'getTitle' : $title");
        //           },
        //         ),
        //       ],
        //     ),
        //     MenuItemLabel(label: 'disabled Item', name: 'disableItem', image: getImagePath('gift_icon'), enabled: false),
        //   ],
        // ),
        // MenuSeparator(),
        // MenuItemLabel(
        //   label: 'Set Item Image',
        //   onClicked: (menuItem) async {
        //     debugPrint("click 'SetItemImage'");

        //     String iconName = iconList[Random().nextInt(iconList.length)];
        //     String path = getImagePath(iconName);

        //     await menuItem.setImage(path);
        //     debugPrint("click name: ${menuItem.name} menuItemId: ${menuItem.menuItemId} label: ${menuItem.label} image: ${menuItem.image}");
        //   },
        // ),
        // MenuItemCheckbox(
        //   label: 'Checkbox 1',
        //   name: 'checkbox1',
        //   checked: true,
        //   onClicked: (menuItem) async {
        //     debugPrint("click 'Checkbox 1'");

        //     MenuItemCheckbox? checkbox1 = _menuMain.findItemByName<MenuItemCheckbox>("checkbox1");
        //     await checkbox1?.setCheck(!checkbox1.checked);

        //     debugPrint("click name: ${checkbox1?.name} menuItemId: ${checkbox1?.menuItemId} label: ${checkbox1?.label} checked: ${checkbox1?.checked}");
        //   },
        // ),
        // MenuSeparator(),
        MenuItemLabel(label: 'Exit', onClicked: (menuItem) => _appWindow.close()),
      ],
    );

    await _menuSimple.buildFrom([
      MenuItemLabel(
        label: 'Change Context Menu',
        image: getImagePath('app_icon'),
        onClicked: (menuItem) {
          debugPrint("Change Context Menu");

          _toogleMenu = !_toogleMenu;
          _systemTray.setContextMenu(_toogleMenu ? _menuMain : _menuSimple);
        },
      ),
      MenuSeparator(),
      MenuItemLabel(label: 'Show', image: getImagePath('app_icon'), onClicked: (menuItem) => _appWindow.show()),
      MenuItemLabel(label: 'Hide', image: getImagePath('app_icon'), onClicked: (menuItem) => _appWindow.hide()),
      MenuItemLabel(
        label: 'Exit',
        image: getImagePath('app_icon'),
        onClicked: (menuItem) => _appWindow.close(),
      ),
    ]);

    _systemTray.setContextMenu(_menuMain);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: WindowBorder(
          color: const Color(0xFF805306),
          width: 1,
          child: Column(
            children: [
              const TitleBar(),
              ContentBody(
                systemTray: _systemTray,
                menu: _menuMain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class TitleBar extends StatelessWidget {
  const TitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [backgroundStartColor, backgroundEndColor], stops: [0.0, 1.0]),
        ),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(),
            ),
            const WindowButtons()
          ],
        ),
      ),
    );
  }
}

class ContentBody extends StatelessWidget {
  final SystemTray systemTray;
  final Menu menu;

  const ContentBody({
    super.key,
    required this.systemTray,
    required this.menu,
  });
// const ContentBody({
//     Key? key,
//     required this.systemTray,
//     required this.menu,
//   }) : super(key: key);

  // final channel = WebSocketChannel.connect(
  //   Uri.parse('wss://echo.websocket.events'),
  // );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          children: [
            Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receiving msg from server_msg_redis',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    StreamBuilder(
                      stream: channel.stream,
                      builder: (context, snapshot) {
                        return Text(snapshot.hasData ? '${snapshot.data}' : '');
                      },
                    ),
                    // const Text(
                    //   'Create system tray.',
                    // ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    ElevatedButton(
                      child: const Text("initSystemTrayPEPE"),
                      onPressed: () async {
                        if (await systemTray.initSystemTray(iconPath: getTrayImagePath('app_icon'))) {
                          systemTray.setTitle("new system tray");
                          systemTray.setToolTip("How to use system tray with Flutter");
                          systemTray.setContextMenu(menu);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Show toast with custom XML.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // const Text(
                    //   'Toast test.',
                    // ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    ElevatedButton(
                      child: const Text("Show toast"),
                      onPressed: () async {
                        const xml = """
<?xml version="1.0" encoding="UTF-8"?>
<toast launch="action=viewConversation&amp;conversationId=9813">
   <visual>
      <binding template="ToastGeneric">
         <text>Kerno sent you a message </text>
         <text>Check this out, Happy Canyon in Utah!</text>
      </binding>
   </visual>
   <actions>
      <input id="tbReply" type="text" placeHolderContent="Type a reply" />
      <action content="Reply" activationType="background" arguments="action=reply&amp;conversationId=9813" />
      <action content="Like" activationType="background" arguments="action=like&amp;conversationId=9813" />
      <action content="View" activationType="background" arguments="action=viewImage&amp;imageUrl=https://picsum.photos/364/202?image=883" />
   </actions>
</toast>
            """;
                        try {
                          await WinToast.instance().showCustomToast(xml: xml);
                        } catch (error, stacktrace) {
                          debugPrint("Error en el toast ");
                        }
                        debugPrint("despues del toast");
                        // await systemTray.destroy();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Show toast with builder.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // const Text(
                    //   'Toast test.',
                    // ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    ElevatedButton(
                      child: const Text("Show toast"),
                      onPressed: () async {
                        try {
                          await WinToast.instance().showToast(
                            toast: Toast(
                              duration: ToastDuration.short,
                              launch: 'action=viewConversation&conversationId=9813',
                              children: [
                                // ToastChildAudio(source: ToastAudioSource.defaultSound),
                                ToastChildAudio(source: ToastAudioSource.alarm10),
                                ToastChildVisual(
                                  binding: ToastVisualBinding(
                                    children: [
                                      ToastVisualBindingChildText(
                                        text: 'HelloWorld',
                                        id: 1,
                                      ),
                                      ToastVisualBindingChildText(
                                        text: 'by Kerno\'s notifications',
                                        id: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                ToastChildActions(children: [
                                  ToastAction(
                                    content: "Close",
                                    arguments: "close_argument",
                                  )
                                ]),
                              ],
                            ),
                          );
                        } catch (error, stacktrace) {
                          // i('showTextToast error: $error, $stacktrace');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306), mouseOver: const Color(0xFFF6A00C), mouseDown: const Color(0xFF805306), iconMouseOver: const Color(0xFF805306), iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(mouseOver: const Color(0xFFD32F2F), mouseDown: const Color(0xFFB71C1C), iconNormal: const Color(0xFF805306), iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Exit Program?'),
                  content: const Text(('The window will be hidden, to exit the program you can use the system menu.')),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        appWindow.hide();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
