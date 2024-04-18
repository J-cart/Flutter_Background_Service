import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_background_service/bg_service_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  await initializeService(service);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final service = FlutterBackgroundService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeView(service: service));
  }
}

class HomeView extends StatefulWidget {
  final FlutterBackgroundService service;
  const HomeView({super.key, required this.service});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String text = "Stop Service";
  // final service = FlutterBackgroundService();
  // final service = NewFlutterBackgroundService.instance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service App'),
      ),
      body: Column(
        children: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: widget.service.on('update'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = snapshot.data!;
              String? device = data["device"];
              DateTime? date = DateTime.tryParse(data["current_date"]);
              return Column(
                children: [
                  Text(device ?? 'Unknown'),
                  Text(date.toString()),
                ],
              );
            },
          ),
          ElevatedButton(
            child: const Text("Foreground Mode"),
            onPressed: () {
              widget.service.invoke("setAsForeground");
            },
          ),
          ElevatedButton(
            child: const Text("Background Mode"),
            onPressed: () {
              widget.service.invoke("setAsBackground");
            },
          ),
          ElevatedButton(
            child: Text(text),
            onPressed: () async {
              var isRunning = await widget.service.isRunning();
              if (isRunning) {
                widget.service.invoke("stopService");
              } else {
                await widget.service.startService();
              }

              if (!isRunning) {
                text = 'Stop Service';
              } else {
                text = 'Start Service';
              }
              setState(() {});
            },
          ),
          const Expanded(
            child: LogView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: widget.service.on('update'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data = snapshot.data!;
                        String? device = data["device"];
                        DateTime? date =
                            DateTime.tryParse(data["current_date"]);
                        return Column(
                          children: [
                            Text(device ?? 'Unknown'),
                            Text(date.toString()),
                          ],
                        );
                      },
                    ),
                  ]),
                );
              });
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}
