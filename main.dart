import 'package:flutter/material.dart';
import 'package:untitled/new.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: MediatorExample(),
      ),
    );
  }
}

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

/// [TeamMember] is an abstract class that is used as a base class
/// for all the specific team member class.
abstract class TeamMember {
  final String name;
  String? lastNotification;
  NotificationHub? notificationHub;

  TeamMember({required this.name});

  /// Receives the notification from the notification hub.
  void receive(String from, String message) {
    lastNotification = '$from: "$message"';
  }

  /// sends a notification.
  void send(String message) {
    notificationHub?.send(this, message);
  }

  /// sends a notification to specific team members.
  void sendTo<T extends TeamMember>(String message) {
    notificationHub?.sendTo<T>(this, message);
  }
}

class Admin extends TeamMember {
  Admin({required super.name});

  @override
  String toString() => '$name (Admin)';
}

class Developer extends TeamMember {
  Developer({required super.name});

  @override
  String toString() => '$name (Developer)';
}

class Tester extends TeamMember {
  Tester({required super.name});

  @override
  String toString() => '$name (Tester)';
}

/// [NotificationHub] is an abstract class which is used as a base
/// class for all the specific notification hubs.
abstract class NotificationHub {
  /// Returns a list of team members of the hub;
  List<TeamMember> getTeamMembers();

  /// Registers a team member to the hub
  void register(TeamMember member);

  /// Sends a notification to registered team members(excluding sender).
  void send(TeamMember sender, String message);

  /// sends a notification to specific registered team members(excluding sender)
  void sendTo<T extends TeamMember>(TeamMember sender, String message);
}

class TeamNotificationHub extends NotificationHub {
  /// list of registered team members.
  final _teamMembers = <TeamMember>[];

  TeamNotificationHub({List<TeamMember>? members}) {
    members?.forEach(register);
  }

  @override
  List<TeamMember> getTeamMembers() => _teamMembers;

  @override
  void register(TeamMember member) {
    member.notificationHub = this;
    _teamMembers.add(member);
  }

  @override
  void send(TeamMember sender, String message) {
    final filteredMembers = _teamMembers.where((member) => member != sender);
    for (final member in filteredMembers) {
      member.receive(sender.toString(), message);
    }
  }

  @override
  void sendTo<T extends TeamMember>(TeamMember sender, String message) {
    final filteredMembers =
        _teamMembers.where((member) => member != sender).whereType<T>();
    for (final member in filteredMembers) {
      member.receive(sender.toString(), message);
    }
  }
}

/// Initialises and contains a notification hub property to send and receive notifications, and register team members to the hub.
class MediatorExample extends StatefulWidget {
  const MediatorExample({Key? key}) : super(key: key);

  @override
  State<MediatorExample> createState() => _MediatorExampleState();
}

class _MediatorExampleState extends State<MediatorExample> {
  late final NotificationHub _notificationHub;
  final _admin = Admin(name: 'admin');
  @override
  void initState() {
    super.initState();
    final members = [
      _admin,
      Developer(name: 'Sea Sharp'),
      Developer(name: 'Jan Assembler'),
      Developer(name: 'Dove Dart'),
      Tester(name: 'Cori Debugger'),
      Tester(name: 'Tania Mocha'),
    ];
    _notificationHub = TeamNotificationHub(members: members);
  }

  void _sendToAll() {
    setState(() {
      _admin.send('Hello');
    });
  }

  void _sendToQa() {
    setState(() {
      _admin.sendTo<Tester>('BUG!');
    });
  }

  void _sendToDevelopers() {
    setState(() {
      _admin.sendTo<Developer>('Hello, World!');
    });
  }

  void _addTeamMember() {
    final name = '${faker.person.firstName()} ${faker.person.lastName()}';
    final teamMember = faker.randomGenerator.boolean()
        ? Tester(name: name)
        : Developer(name: name);

    setState(() {
      _notificationHub.register(teamMember);
    });
  }

  void _sendFromMember(TeamMember member) {
    setState(() {
      member.send('Hello from ${member.name}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _sendToAll,
              child: Text("Admin: Send 'Hello' to all"),
            ),
            ElevatedButton(
              onPressed: _sendToQa,
              child: Text("Admin: Send 'BUG!' to QA"),
            ),
            ElevatedButton(
              onPressed: _sendToDevelopers,
              child: Text("Admin: Send 'Hello, World!' to Developers"),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: _addTeamMember,
              child: Text("Add team member"),
            ),
            const SizedBox(height: 12.0),
            NotificationList(
              members: _notificationHub.getTeamMembers(),
              onTap: _sendFromMember,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<TeamMember> members;
  final ValueSetter<TeamMember> onTap;

  const NotificationList({
    super.key,
    required this.members,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Last notifications',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(
          height: 12.0,
        ),
        Text(
          'Note: click on the card to send a notification from the team member.',
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(
          height: 12.0,
        ),
        for (final member in members)
          Card(
            margin: const EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: InkWell(
              onTap: () => onTap(member),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12.0),
                          Text(member.lastNotification ?? '-'),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.message),
                    ),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
}
