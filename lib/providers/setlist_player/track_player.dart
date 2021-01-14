import '../../models/track.dart';
import '../metronome/metronome_base.dart';
import '../metronome/metronome.dart';
import 'complex_track_player.dart';
import 'simple_track_player.dart';

abstract class TrackPlayer {
  final Track track;

  TrackPlayer(this.track);

  factory TrackPlayer.createPlayerForTrack(Track track) {
    return track.isComplex
        ? ComplexTrackPlayer(track)
        : SimpleTrackPlayer(track);
  }

  bool get isPlaying => Metronome().isPlaying;
  int get currentSectionIndex => null;
  int get currentSectionBar => null;

  void play();
  void selectNextSection();
  void selectPreviousSection();

  void stop() {
    Metronome().stop();
  }
}