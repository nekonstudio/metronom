#include "AudioEngine.h"
#include "AudioProperties.h"
#include "AAssetDataSource.h"
#include "LogUtils.h"

using namespace  oboe;

// Double-buffering offers a good tradeoff between latency and protection against glitches.
constexpr int32_t kBufferSizeInBursts = 2;

constexpr int64_t kMillisecondsInSecond = 1000;
constexpr int64_t convertFramesToMillis(const int64_t frames, const int sampleRate){
    return static_cast<int64_t>((static_cast<double>(frames)/ sampleRate) * kMillisecondsInSecond);
}

AudioEngine::AudioEngine(/* args */)
{
    AudioStreamBuilder builder;
    builder.setSampleRate(44100);
    builder.setFormat(AudioFormat::Float);
    builder.setChannelCount(1);
    builder.setPerformanceMode(PerformanceMode::LowLatency);
    builder.setSharingMode(SharingMode::Exclusive);
    builder.setDataCallback(this);

    Result result = builder.openStream(_stream);

    if (result != Result::OK) {
        LOGE("Nie można otworzyć streamu");
    }

    _stream->setBufferSizeInFrames(_stream->getFramesPerBurst() * kBufferSizeInBursts);

    LOGD("Buffer size in frames: %d", _stream->getBufferSizeInFrames());
}

AudioEngine::~AudioEngine()
{
    _stream->close();
    _stream.reset();

    delete _highSoundSource;
    delete _mediumSoundSource;
    delete _lowSoundSource;
}



void AudioEngine::start()
{
    Result result = _stream->requestStart();

    if (result != Result::OK) {
        LOGE("Nie można wystartować streamu");
    }
}

void AudioEngine::stop()
{
    _framesWritten = 0;
    _shouldGoToNextBeat = true;
    _isSynchronizedMetronome = false;
    _playSynchronizedMetronome = false;

    _currentBeatPerBar = 0;
    _currentClickPerBeat = 0;

    if (_stream) {
        _stream->requestStop();
    }
}

DataCallbackResult
AudioEngine::onAudioReady(AudioStream *audioStream, void *audioData, int32_t numFrames) {
    auto* outputBuffer = static_cast<float*>(audioData);

    auto sampleRate = audioStream->getSampleRate();
    int framesToPlay = static_cast<int>( sampleRate * ( 1 / ( static_cast<float>(_tempo) / 60 ) / _clicksPerBeat ) );

//    SoundId soundId = currentBeatsPerBar == 1
//                      ? currentClickPerBeat == 1 ? SoundId.HIGH_SOUND : SoundId.LOW_SOUND
//                      : currentClickPerBeat == 1 ? SoundId.MEDIUM_SOUND : SoundId.LOW_SOUND;

    auto soundSource = _currentBeatPerBar == 1
            ? _currentClickPerBeat == 1 ? _highSoundSource : _lowSoundSource
            : _currentClickPerBeat == 1 ? _mediumSoundSource : _lowSoundSource;



    auto* readSoundBuffer = soundSource->getData();
    auto bufferSize = soundSource->getSize();

    for (int i = 0; i < numFrames; ++i) {
        if (_isSynchronizedMetronome) {
            if (_playSynchronizedMetronome) {
                if (_framesWritten < bufferSize) {
                    outputBuffer[i] = readSoundBuffer[_framesWritten];
                } else {
                    outputBuffer[i] = 0.0f;
                }

                _framesWritten++;
                if (_framesWritten >= framesToPlay) {
                    _framesWritten = 0;
                    _shouldGoToNextBeat = true;
                }
            } else {
                outputBuffer[i] = 0.0f;
            }
        } else {
            if (_framesWritten < bufferSize) {
                outputBuffer[i] = readSoundBuffer[_framesWritten];
            } else {
                outputBuffer[i] = 0.0f;
            }

            _framesWritten++;
            if (_framesWritten >= framesToPlay) {
                _framesWritten = 0;
                _shouldGoToNextBeat = true;
            }
        }
    }

    return DataCallbackResult::Continue;
}

bool AudioEngine::onError(oboe::AudioStream *audioStream, oboe::Result result) {
//    if (result == oboe::Result::ErrorDisconnected) {
//        std::function<void(void)> restartFunction = std::bind(&AudioEngine::restart, this);
//        new std::thread(restartFunction);
//    }
    return AudioStreamErrorCallback::onError(audioStream, result);
}

bool AudioEngine::shouldGoToNextBeat() {
    return _shouldGoToNextBeat;
}

void AudioEngine::resetShouldGoToNextBeat() {
    _shouldGoToNextBeat = false;
}

void AudioEngine::setMetronomeSettings(int32_t tempo, int32_t clicksPerBeat) {
    _tempo = tempo;
    _clicksPerBeat = clicksPerBeat;
}

void AudioEngine::setupAudioSources(AAssetManager &assetManager) {
    // Set the properties of our audio source(s) to match that of our audio stream
    AudioProperties targetProperties {
            .channelCount = _stream->getChannelCount(),
//            .channelCount = 1,
            .sampleRate = _stream->getSampleRate()
//            .sampleRate = 44100
    };

    // Create a data source and player for the clap sound
//    _highSoundSource = std::shared_ptr<AAssetDataSource>{
//            AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties)
//    };

    _highSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties);
    _mediumSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_medium.wav", targetProperties);
    _lowSoundSource = AAssetDataSource::newFromCompressedAsset(assetManager, "click_low.wav", targetProperties);


    LOGD("Data source size: %d", _highSoundSource->getSize());

//    auto* data = _highSoundSource->getData();

//    for (int i = 0; i < _highSoundSource->getSize(); ++i) {
//        LOGD("Data: %.3f, Index: %d", data[i], i);
//    }


//    _highSoundSource = std::make_shared<AAssetDataSource>(AAssetDataSource::newFromCompressedAsset(assetManager, "click_high.wav", targetProperties));

//    mClap = std::make_unique<Player>(mClapSource);
}
