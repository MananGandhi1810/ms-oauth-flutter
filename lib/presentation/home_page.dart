import 'dart:developer';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:calendar_integration/constants.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_graph_api/microsoft_graph_api.dart';
import 'package:microsoft_graph_api/models/models.dart';

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
  late MSGraphAPI msGraphAPI;

  @override
  void initState() {
    config = Config(
      tenant: Constants.tenant,
      clientId: Constants.clientId,
      scope:
          "openid profile User.read email offline_access Calendars.ReadWrite",
      redirectUri: "ontrack://login",
      navigatorKey: widget.navigatorKey,
      loader: const Center(child: CircularProgressIndicator()),
    );
    aadOauth = AadOAuth(config);
    _checkLogin();
    super.initState();
  }

  void _checkLogin() async {
    await aadOauth.refreshToken();
    String? token = await aadOauth.getAccessToken();
    log(token ?? "No Token");
    setState(() {
      isLoggedIn = token != null;
    });
    if (token != null) {
      msGraphAPI = MSGraphAPI(token);
      User user = await msGraphAPI.me.fetchUserInfo();
      debugPrint(user.id);
      final calendars = await msGraphAPI.calendars.fetchCalendarEventsForRange(
        DateTime.now(),
        DateTime.now().add(
          const Duration(days: 10),
        ),
      );
      debugPrint(calendars.toString());
    }
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
