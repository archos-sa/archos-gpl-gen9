#include "ADTSAudioStreamFramer.hh"

#ifndef _ADTS_AUDIO_STREAM_PARSER_HH
#include "ADTSAudioStreamParser.hh"
#endif
//#define DUMP

static unsigned const samplingFrequencyTable[16] = {
    96000, 88200, 64000, 48000,
    44100, 32000, 24000, 22050,
    16000, 12000, 11025, 8000,
    7350, 0, 0, 0
};

ADTSAudioStreamFramer* ADTSAudioStreamFramer
::createNew(UsageEnvironment& env, FramedSource* inputSource, Boolean includeStartCodeInOutput) {
    return new ADTSAudioStreamFramer(env, inputSource, includeStartCodeInOutput);
}

    ADTSAudioStreamFramer
::ADTSAudioStreamFramer(UsageEnvironment& env, FramedSource* inputSource, Boolean includeStartCodeInOutput)
    : FramedFilter(env, inputSource), fIncludeStartCodeInOutput(includeStartCodeInOutput), fParser(NULL) {
        fParser = new ADTSAudioStreamParser(this, inputSource, false);
    }

ADTSAudioStreamFramer::~ADTSAudioStreamFramer() {
}

void ADTSAudioStreamFramer::doGetNextFrame() {
    fParser->registerReadInterest(fTo, fMaxSize);
    continueReadProcessing();
}

void ADTSAudioStreamFramer::continueReadProcessing(void* clientData,
        unsigned char* /*ptr*/, unsigned /*size*/,
        struct timeval presentationTime) {
    ADTSAudioStreamFramer* framer = (ADTSAudioStreamFramer*)clientData;
    framer->setPresentationTime(presentationTime);
    framer->continueReadProcessing();
}

void ADTSAudioStreamFramer::continueReadProcessing() {
    unsigned acquiredFrameSize = fParser->parse();

    if (acquiredFrameSize > 0) {
#ifdef DUMP
        FILE *log = fopen("/tmp/log/log-audio-after-framer.aac", "a");
        if (NULL == log) {
            fprintf(stderr, "Cannot dump : error %d (%s)\n", errno, strerror(errno));
        } else {
            fwrite(fTo, acquiredFrameSize, 1, log);
            fflush(log);
            fclose(log);
        }
#endif
        fPresentationTime = fNextPresentationTime;
        unsigned long long int uSeconds = fNextPresentationTime.tv_usec + 128000; // TODO compute 128000
        fNextPresentationTime.tv_sec += uSeconds / 1000000;
        fNextPresentationTime.tv_usec = uSeconds % 1000000;

#ifdef DEBUG
        unsigned long secs = (unsigned long)fPresentationTime.tv_sec;
        unsigned uSecs = (unsigned)fPresentationTime.tv_usec;
        fprintf(stderr, "\tADTS Presentation time: %lu.%06u\n", secs, uSecs);
#endif
        
        // We were able to acquire a frame from the input.
        // It has already been copied to the reader's space.
        fFrameSize = acquiredFrameSize;
        fNumTruncatedBytes = fParser->numTruncatedBytes();

        // Call our own 'after getting' function.  Because we're not a 'leaf'
        // source, we can call this directly, without risking infinite recursion.
        afterGetting(this);
    } else {
        // We were unable to parse a complete frame from the input, because:
        // - we had to read more data from the source stream, or
        // - the source stream has ended.
    }
}

void ADTSAudioStreamFramer::afterGettingFrame(void* clientData, unsigned frameSize,
        unsigned numTruncatedBytes,
        struct timeval presentationTime,
        unsigned durationInMicroseconds) {
    ADTSAudioStreamFramer *fragmenter = (ADTSAudioStreamFramer *)clientData;
    fragmenter->afterGettingFrame1(frameSize, numTruncatedBytes, presentationTime,
            durationInMicroseconds);
}

void ADTSAudioStreamFramer::afterGettingFrame1(unsigned frameSize,
        unsigned numTruncatedBytes,
        struct timeval presentationTime,
        unsigned durationInMicroseconds) {
}

void ADTSAudioStreamFramer::setPresentationTime(struct timeval presentationTime) {
    fNextPresentationTime = presentationTime;
}
