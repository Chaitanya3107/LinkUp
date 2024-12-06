import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/Controllers/localSavedData.dart';
import 'package:link_up/pages/chatPage/chatPage.dart';
import 'package:link_up/pages/home/home.dart';
import 'package:link_up/pages/home/searchUser.dart';
import 'package:link_up/pages/loginPage/phone_login.dart';
import 'package:link_up/pages/profilePage/profilePage.dart';
import 'package:link_up/pages/profilePage/updateProfilePage.dart';
import 'package:link_up/stateManagement/chatProvider.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // when context is not available then use navigatorKey.currentState!.context
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);
    // 5 app life cycle state  resumed, paused, inactive, detached, hidden
    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("App resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App inactive");
        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App paused");
        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App detached");
        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("App hidden");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
  await LocalSavedData().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'LinkUp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          // root route
          "/": (context) => CheckUserSession(),
          "/login": (context) => PhoneLogin(),
          "/home": (context) => HomePage(),
          "/chat": (context) => ChatPage(),
          "/profile": (context) => Profilepage(),
          "/update": (context) => UpdateProfilePage(),
          "/search": (context) => SearchUser(),
        },
      ),
    );
  }
}

// checking user session

class CheckUserSession extends StatefulWidget {
  const CheckUserSession({super.key});

  @override
  State<CheckUserSession> createState() => _CheckUserSessionState();
}

class _CheckUserSessionState extends State<CheckUserSession> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _checkUserSession);
  }

  Future<void> _checkUserSession() async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);

    // Load local data first
    await userProvider.loadDataFromLocal();

    // Load additional data from Appwrite using userId
    final userId = userProvider.getUserId;
    if (userId.isNotEmpty) {
      await userProvider.loadUserDataAppwrite(userId);
    }

    // Check session validity
    final sessionValid = await checkSession();

    if (sessionValid) {
      // Decide navigation based on username availability
      final userName = userProvider.getUserName;
      if (userName.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
          (route) => false,
          arguments: {"title": "add"},
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/update",
          (route) => false,
          arguments: {"title": "add"},
        );
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
