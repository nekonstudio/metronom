import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronom/providers/metronome/metronome_base.dart';
import 'package:metronom/providers/metronome/metronome.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/metronome/notifier_metronome.dart';
import 'package:mockito/mockito.dart';

// class MockMetronomeImpl extends Mock implements Metronome {}
class MockMetronomeImpl extends MetronomeBase {
  @override
  void onStart(MetronomeSettings settings) {
    // TODO: implement onStart
  }

  @override
  void onChange(MetronomeSettings settings) {
    // TODO: implement onChange
  }

  @override
  void onStop() {
    // TODO: implement onStop
  }

  @override
  Stream<int> getCurrentBarBeatStream() {
    StreamController<int> controller;
    Timer timer;
    int counter = 1;

    void tick(_) {
      controller.add(counter); // Ask stream to send counter values as event.
      counter++;
      if (counter > 4) {
        counter = 1;
      }
    }

    void startTimer() {
      timer = Timer.periodic(Duration(seconds: 1), tick);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        controller.close();
      }
    }

    controller = StreamController<int>.broadcast(
      onListen: startTimer,
      onCancel: stopTimer,
    );

    return controller.stream;
  }
}

void main() {
  group('Metronome', () {
    test('isPlaying flag is set to false by default', () {
      final metronome = MockMetronomeImpl();

      expect(metronome.isPlaying, false);
    });

    test('isPlaying flag is set to true after start', () {
      final metronome = MockMetronomeImpl();

      metronome.start(MetronomeSettings(120, 4, 1));

      expect(metronome.isPlaying, true);
    });

    test('settings are correctly saved after start', () {
      final MetronomeBase metronome = MockMetronomeImpl();

      final settings = MetronomeSettings(120, 4, 1);
      metronome.start(settings);

      expect(metronome.settings, settings);
    });

    test('isPlaying flag is set to false if change is called before start', () {
      final metronome = MockMetronomeImpl();

      metronome.change(MetronomeSettings(120, 4, 1));

      expect(metronome.isPlaying, false);
    });

    test('isPlaying flag is set to true if change is called after start', () {
      final MetronomeBase metronome = MockMetronomeImpl();

      final settings = MetronomeSettings(120, 4, 1);
      metronome.start(settings);
      metronome.change(settings);

      expect(metronome.isPlaying, true);
    });

    test('isPlaying flag is set to false after stop is called', () {
      final MetronomeBase metronome = MockMetronomeImpl();

      metronome.stop();

      expect(metronome.isPlaying, false);
    });

    test('isPlaying flag is set to false when stop is called after start', () {
      final MetronomeBase metronome = MockMetronomeImpl();

      metronome.start(MetronomeSettings(120, 4, 1));
      metronome.stop();

      expect(metronome.isPlaying, false);
    });
  });

  group('Metronome Providers', () {
    // test('metronomeProvider returns instance of NotifierMetronome', () {
    //   final container = ProviderContainer();

    //   final metronome = container.read(metronomeProvider);

    //   expect(metronome is NotifierMetronome, true);
    // });
  });
}