import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/metronome/remote_synchronized_metronome.dart';
import 'package:metronom/providers/remote/remote_synchronization.dart';

class HostSynchronizedMetronome extends RemoteSynchronizedMetronome {
  HostSynchronizedMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  void startImplementation(MetronomeSettings settings) {
    assert(synchronization.hostStartTime != null,
        'synchronization.hostStartTime must be set before HostSynchronizedMetronome.start() call');

    final hostTimeDifference = synchronization.hostTimeDifference;
    final latency = DateTime.now()
        .difference(synchronization.hostStartTime.add(Duration(milliseconds: -hostTimeDifference)))
        .inMilliseconds;

    print('latency: $latency ms');

    final waitTime = synchronization.hostStartTime.add(Duration(
        milliseconds: -hostTimeDifference + 500 + (synchronization.clockSyncLatency ~/ 2)));

    prepareToRun(settings);

    print(
        '1. CLIENT START! time:\t${DateTime.now().add(Duration(milliseconds: hostTimeDifference))}');

    Future.doWhile(() => DateTime.now().isBefore(waitTime)).then((_) {
      print(
          '2. CLIENT START! time:\t${DateTime.now().add(Duration(milliseconds: hostTimeDifference))}');
      run();

      synchronization.hostStartTime = null;
    });
  }
}
