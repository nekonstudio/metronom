import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/nearby/nearby_devices.dart';

class ConnectedNearbyDevicesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final devicesList = watch(nearbyDevicesProvider).connectedDevicesList;

    if (devicesList.isEmpty) {
      return Center(child: Text('Brak połączonych urządzeń'));
    }

    return ListView.separated(
      itemCount: devicesList.length,
      itemBuilder: (context, index) {
        final deviceName = devicesList[index];
        return ListTile(
          leading: Icon(Icons.phone_android),
          title: Text(deviceName),
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
    );
  }
}