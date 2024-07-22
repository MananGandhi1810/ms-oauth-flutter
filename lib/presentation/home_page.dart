import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:calendar_integration/constants.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Config config;
  late AadOAuth aadOauth;
  bool isLoggedIn = false;

  @override
  void initState() {
    config = Config(
      tenant: Constants.tenant, // Set this to "common" for multi-tenant apps
      clientId: Constants.clientId,
      scope: "openid profile offline_access Calendars.ReadWrite",
      redirectUri: "ontrack://login",
      navigatorKey: widget.navigatorKey,
      loader: const Center(child: CircularProgressIndicator()),
    );
    aadOauth = AadOAuth(config);
    _checkLogin();
    super.initState();
  }

  void _checkLogin() async {
    String? token = await aadOauth.getAccessToken();
    debugPrint(token ?? "No Token");
    setState(() {
      isLoggedIn = token != null;
    });
  }

  void _login() async {
    final result = await aadOauth.login();
    debugPrint("LOGGED IN");
    debugPrint(result.toString());
    _checkLogin();
  }

  void _logout() async {
    await aadOauth.logout();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MS OAuth"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoggedIn
                ? ElevatedButton(
                    onPressed: _logout,
                    child: const Text("Logout"),
                  )
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
