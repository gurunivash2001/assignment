import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:test_assignment/widgets/top_containers.dart';
import 'package:test_assignment/services/permissions_helper.dart';
import 'package:test_assignment/services/location_service.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TabHome> {
  final PermissionsHelper _permissionsHelper = PermissionsHelper();
  final LocationService _locationService = LocationService();
  final List<Map<String, double>> _locationDataList = [];
  static const platform = MethodChannel('com.example.notifications/settings');


  Future<void> _requestLocationPermission() async {
    bool granted = await _permissionsHelper.requestLocationPermission();
    if (granted) {
      Get.snackbar(
          "Permission Granted", "Location permission granted successfully.");
    } else {
      Get.snackbar(
          "Permission Denied", "Location permission is required to proceed.");
    }
  }

  void _startLocationUpdate() async {
    final confirm = await _showConfirmationDialog("Start Location Update?");
    if (confirm) {
      bool isNotificationAllowed =
          await _permissionsHelper.requestNotificationPermission();

      if (!isNotificationAllowed) {
        Get.snackbar(
          "Notification Permission Required",
          "Please enable notification permission to receive updates.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _locationService.startLocationUpdates();
      _triggerNotification("Location update started");
      _updateLocationData();
      Future.delayed(const Duration(seconds: 30), _updateLocationData);
    }
  }

  void _stopLocationUpdate() async {
    final confirm = await _showConfirmationDialog("Stop Location Update?");
    if (confirm) {
      await _locationService.stopLocationUpdates();
      _triggerNotification("Location update stopped");
    }
  }

  Future<void> enableNotifications() async {
    try {
      bool locationUpdatesActive = true;

      if (locationUpdatesActive) {
        bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
        await platform.invokeMethod('openNotificationSettings');
      }
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateLocationData() async {
    final data = await _locationService.getLocationData();
    setState(() {
      _locationDataList.add({
        'latitude': data['latitude'] ?? 0.0,
        'longitude': data['longitude'] ?? 0.0,
        'speed': double.parse((data['speed'] ?? 0.0).toStringAsFixed(2)),
      });
    });
  }

  void _triggerNotification(String message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: message,
        body: 'Location update notification',
      ),
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Test App", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,  
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TopContainers(
                          onTap: _requestLocationPermission,
                          text: 'Request Location Permission',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:    TopContainers(
                          onTap: enableNotifications,
                          text: 'Request Notification Permission',
                          color: Colors.yellow,
                          textStyle: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TopContainers(
                          onTap: _startLocationUpdate,
                          text: 'Start Location Update',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TopContainers(
                          onTap: _stopLocationUpdate,
                          text: 'Stop Location Update',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,  
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: _locationDataList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final data = _locationDataList[index];
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request ${index + 1}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("Lat: ${data['latitude'] ?? 0.0}"),
                        Text("Lng: ${data['longitude'] ?? 0.0}"),
                        Text("Speed: ${data['speed'] ?? 0.0}m"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}