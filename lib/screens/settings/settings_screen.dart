import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repeater/screens/form/intro_screen.dart';
import 'package:repeater/screens/main/main_navigation.dart';
import 'package:repeater/services/user_preferences.dart';
import 'package:repeater/utils/bool_alert_dialog.dart';
import 'package:repeater/widgets/custom_list_view.dart';
import 'package:repeater/widgets/gap.dart';
import 'package:repeater/widgets/section_title.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String currentTheme;
  late Color currentColor;

  final List<Color> colorSchemeOptions = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.deepOrange,
    Colors.pink,
  ];
  final userGuideUrl =
      Uri.parse('https://danioliden.github.io/repeater/links/guide/');
  final sendFeedbackUrl =
      Uri.parse('https://danioliden.github.io/repeater/links/feedback/');
  final websiteUrl = Uri.parse('https://danioliden.github.io/repeater/');

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    final user =
        Provider.of<UserPreferences>(context, listen: false).getUser()!;
    currentTheme = user.themeMode;
    currentColor = Color(user.colorScheme);
  }

  void _recreateSchedules() async {
    final result = await showBoolAlertDialog(
      context,
      title: 'Recreate Schedules?',
      content:
          'New schedules will be created to replace current ones. Useful if you have edited your memorization info.',
      falseText: const Text('Cancel'),
      trueText: const Text(
        'Recreate',
        style: TextStyle(color: Colors.red),
      ),
    );

    if (!result) return;

    await UserPreferences().logIn(shouldReschedule: true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
      (_) => false,
    );
  }

  void _resetData() async {
    final result = await showBoolAlertDialog(
      context,
      title: 'Reset Data?',
      content: 'All app data will be deleted and cannot be restored.',
      falseText: const Text('Cancel'),
      trueText: const Text(
        'Reset',
        style: TextStyle(color: Colors.red),
      ),
    );

    if (!result) return;

    await UserPreferences().resetUser();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const IntroScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> _launchUrl(Uri url) async {
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: CustomListView(
        children: [
          const SectionTitle('Appearance'),
          _setThemeTile(userPrefs),
          _setColorSchemeTile(userPrefs),
          const LargeGap(),
          const SectionTitle('Danger Zone'),
          _rescheduleTile(),
          _resetDataTile(),
          const LargeGap(),
          const SectionTitle('Extras'),
          _userGuideTile(),
          _sendFeedbackTile(),
          _websiteTile(),
          _aboutAppTile(),
        ],
      ),
    );
  }

  Widget _setThemeTile(UserPreferences userPrefs) => PopupMenuButton(
        tooltip: '',
        child: ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('Theme'),
          trailing: Text(currentTheme),
        ),
        itemBuilder: (_) {
          return ['System', 'Light', 'Dark'].map((e) {
            return PopupMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList();
        },
        onSelected: (value) async {
          setState(() => currentTheme = value);
          await userPrefs.updateUser(themeMode: value);
        },
      );

  Widget _setColorSchemeTile(UserPreferences userPrefs) => PopupMenuButton(
        tooltip: '',
        child: ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Color Scheme'),
          trailing: CircleAvatar(backgroundColor: currentColor),
        ),
        itemBuilder: (_) {
          return colorSchemeOptions.map(
            (color) {
              return PopupMenuItem(
                value: color,
                child: CircleAvatar(backgroundColor: color),
              );
            },
          ).toList();
        },
        onSelected: (value) async {
          setState(() => currentColor = value);
          await userPrefs.updateUser(colorScheme: currentColor.toARGB32());
        },
      );

  Widget _rescheduleTile() => ListTile(
        leading: const Icon(Icons.calendar_month),
        title: const Text('Recreate Schedules'),
        onTap: _recreateSchedules,
      );

  Widget _resetDataTile() => ListTile(
        leading: const Icon(Icons.delete),
        title: const Text('Reset Data'),
        onTap: _resetData,
      );

  Widget _userGuideTile() => ListTile(
        onTap: () async => await _launchUrl(userGuideUrl),
        leading: const Icon(Icons.library_books),
        title: const Text('User Guide'),
      );

  Widget _sendFeedbackTile() => ListTile(
        onTap: () async => await _launchUrl(sendFeedbackUrl),
        leading: const Icon(Icons.mail),
        title: const Text('Send Feedback'),
      );

  Widget _websiteTile() => ListTile(
        onTap: () async => await _launchUrl(websiteUrl),
        leading: const Icon(Icons.language),
        title: const Text('Website'),
      );

  Widget _aboutAppTile() => const AboutListTile(
        icon: Icon(Icons.info),
        applicationIcon: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image(
            image: AssetImage('assets/icon/icon.png'),
            width: 50,
          ),
        ),
        applicationVersion: 'v0.2.3-beta',
        aboutBoxChildren: [
          Text('An app to assist hafiz in scheduling timetables.'),
        ],
      );
}
