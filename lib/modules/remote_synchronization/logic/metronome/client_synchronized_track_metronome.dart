import '../remote_command.dart';
import '../remote_synchronization.dart';
import 'client_synchronized_metronome.dart';

class ClientSynchronizedTrackMetronome extends ClientSynchronizedMetronome {
  ClientSynchronizedTrackMetronome(RemoteSynchronization synchronization) : super(synchronization);

  @override
  RemoteCommand createStartCommand(_) => RemoteCommand.playTrack();

  @override
  RemoteCommand createStopCommand() => RemoteCommand.stopTrack();
}