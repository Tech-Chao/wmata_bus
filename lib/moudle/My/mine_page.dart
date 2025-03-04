import 'dart:convert';

import 'package:wmata_bus/Model/bus_route_new.dart';
import 'package:wmata_bus/Providers/route_provider.dart';
import 'package:wmata_bus/Utils/const_tool.dart';
import 'package:wmata_bus/Utils/store_manager.dart';
import 'package:wmata_bus/moudle/Services/api_services_new.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MinePageView extends StatefulWidget {
  const MinePageView({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageViewState();
}

class _MinePageViewState extends State<MinePageView> {
  bool autoRefresh = false;
  String? lastUpdateTime;
  bool loading = false;
  late final Uri emailLaunchUri;

  @override
  void initState() {
    super.initState();
    _initEmailUri();
    _loadInitialData();
  }

  void _initEmailUri() {
    emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'wuchaoyu1991@gmail.com',
      query: _encodeQueryParameters({
        'subject': 'DC Bus Tracker Feedback!',
      }),
    );
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _getAutoRefreshState(),
      _loadLastUpdateTime(),
    ]);
  }

  Future<void> _getAutoRefreshState() async {
    String? res = await StoreManager.get("autoRefresh");
    setState(() {
      autoRefresh = res == true.toString();
    });
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _loadLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final tempLastUpdateTime = prefs.getString('last_update_time');
    if (tempLastUpdateTime != null) {
      setState(() {
        lastUpdateTime = tempLastUpdateTime;
      });
    }
  }

  Future<void> _fetchRemoteDatas(BuildContext context) async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final temp = await APIService.getBusroute();
      if (temp != null && temp.isNotEmpty) {
        await _updateRouteData(context, temp);
      }
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _updateRouteData(
      BuildContext context, List<BusRouteNew> routes) async {
    Provider.of<AppRouteProvider>(context, listen: false).setBusRoutes(routes);

    final prefs = await SharedPreferences.getInstance();
    final newRoutes = json.encode(routes);
    await prefs.setString(ConstTool.kAllRouteskey, newRoutes);

    final currentTime = DateTime.now().toIso8601String();
    await prefs.setString('last_update_time', currentTime);

    setState(() => lastUpdateTime = currentTime);
  }

  Widget _buildSettingsSection() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildAutoRefreshTile(),
    );
  }

  Widget _buildAutoRefreshTile() {
    return ListTile(
      title:
          Text('Auto Refresh', style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('Estimated arrival time refreshed every minute',
          style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch.adaptive(
          value: autoRefresh,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) {
            setState(() => autoRefresh = value);
            StoreManager.save("autoRefresh", value.toString());
          }),
    );
  }

  Widget _buildUpdateDataTile() {
    String formattedTime = lastUpdateTime != null
        ? DateFormat("yyyy-MM-dd HH:mm:ss")
            .format(DateTime.parse(lastUpdateTime!))
        : "Not updated yet";

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => _fetchRemoteDatas(context),
        title: Text('Update Service Data',
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('Last Update: $formattedTime',
            style: Theme.of(context).textTheme.bodySmall),
        trailing: loading
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.sync),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => launchUrl(emailLaunchUri),
        leading: Icon(Icons.bug_report,
            color: Theme.of(context).colorScheme.primary),
        title:
            Text('Report Bug', style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Setting',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsSection(),
          _buildUpdateDataTile(),
          _buildSupportSection(),
        ],
      ),
    );
  }
}
