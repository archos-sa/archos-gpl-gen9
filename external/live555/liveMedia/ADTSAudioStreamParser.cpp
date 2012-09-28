#include "ADTSAudioStreamParser.hh"

static unsigned const samplingFrequencyTable[16] = {
    96000, 88200, 64000, 48000,
    44100, 32000, 24000, 22050,
    16000, 12000, 11025, 8000,
    7350, 0, 0, 0
};

ADTSAudioStreamParser::ADTSAudioStreamParser(ADTSAudioStreamFramer *usingSource, FramedSource *inputSource, Boolean includeStartCodeInOutput)
    : StreamParser(inputSource, FramedSource::handleClosure, usingSource,
            &ADTSAudioStreamFramer::continueReadProcessing, usingSource),
    fUsingSource(usingSource), fHasHeader(false), fIncludeStartCodeInOutput(includeStartCodeInOutput) {
        fPresentationTime.tv_sec = 0;
        fPresentationTime.tv_usec = 0;
    }

ADTSAudioStreamParser::~ADTSAudioStreamParser() {
}

void ADTSAudioStreamParser::setParseState() {
    fSavedTo = fTo;
    fSavedNumTruncatedBytes = fNumTruncatedBytes;
    saveParserState();
}

void ADTSAudioStreamParser::restoreSavedParserState() {
    StreamParser::restoreSavedParserState();
    fTo = fSavedTo;
    fNumTruncatedBytes = fSavedNumTruncatedBytes;
}

void ADTSAudioStreamParser::registerReadInterest(unsigned char* to,
        unsigned maxSize) {
    fStartOfFrame = fTo = fSavedTo = to;
    fLimit = to + maxSize;
    fNumTruncatedBytes = fSavedNumTruncatedBytes = 0;
}

unsigned ADTSAudioStreamParser::parse() {
    try {
        while(!fHasHeader) {
            parseHeader();
            // If no header found, run through stream
            if (!fHasHeader) {
                get1Byte();
                setParseState();
            }
        }

        u_int8_t *ptr = (u_int8_t *)malloc(7);
        testBytes(ptr, 7);
        // Extract important fields from the :
        Boolean protection_absent = ptr[1]&0x01;
        u_int16_t fFrameLength // fFrameLength is the length of full frame (header included)
            = ((ptr[3]&0x03)<<11) | (ptr[4]<<3) | ((ptr[5]&0xE0)>>5);
        if (!fIncludeStartCodeInOutput)
            fFrameLength -= 7;

        u_int16_t syncword = (ptr[0]<<4) | (ptr[1]>>4);
#ifdef DEBUG
        fprintf(stderr, "Read frame: syncword 0x%x, protection_absent %d, fFrameLength %d\n", syncword, protection_absent, fFrameLength);
#endif
        if (syncword != 0xFFF) fprintf(stderr, "Bad syncword!\n");

        if (!fIncludeStartCodeInOutput)
            skipBytes(7);

        getBytes(fStartOfFrame, fFrameLength);
        setParseState();

        fDurationInMicroseconds = fuSecsPerFrame;

        free(ptr);

        return fFrameLength;
    } catch (int /*e*/) {
#ifdef DEBUG
        fprintf(stderr, "H264VideoStreamParser::parse() EXCEPTION (This is normal behavior - *not* an error)\n");
#endif
        return 0;  // the parsing got interrupted
    }
}

void ADTSAudioStreamParser::parseHeader() {
    u_int32_t first4Bytes;
    u_int8_t channel_configuration;
    u_int8_t sampling_frequency_index;
    u_int8_t profile;
    unsigned char audioSpecificConfig[2];
    u_int8_t audioObjectType;

    first4Bytes = test4Bytes();
    // Check the 'syncword':
    if (!((first4Bytes & 0xFFF00000)>>20 == 0xFFF))
        goto fail;

    // Get and check the 'profile':
    profile = (first4Bytes & 0x0000C000)>>14; // 2 bits
    if (profile == 3)
        goto fail;

    // Get and check the 'sampling_frequency_index':
    sampling_frequency_index = (first4Bytes & 0x00003C00)>>10; // 4 bits
    if (samplingFrequencyTable[sampling_frequency_index] == 0)
        goto fail;

    // Get and check the 'channel_configuration':
    channel_configuration = (first4Bytes & 0x0000001C)>>2; // 3 bits

    audioObjectType = profile + 1;
    fSamplingFrequency = samplingFrequencyTable[sampling_frequency_index];
    fNumChannels = channel_configuration == 0 ? 2 : channel_configuration;
    fuSecsPerFrame
        = (1024/*samples-per-frame*/*1000000) / fSamplingFrequency/*samples-per-second*/;

    // Construct the 'AudioSpecificConfig', and from it, the corresponding ASCII string:
    audioSpecificConfig[0] = (audioObjectType<<3) | (sampling_frequency_index>>1);
    audioSpecificConfig[1] = (sampling_frequency_index<<7) | (channel_configuration<<3);
    sprintf(fConfigStr, "%02X%02x", audioSpecificConfig[0], audioSpecificConfig[1]);

#ifdef DEBUG
    fprintf(stderr, "Read first frame: profile %d, "
            "sampling_frequency_index %d => samplingFrequency %d, "
            "channel_configuration %d, configStr %s, numChannels = %d\n",
            profile,
            sampling_frequency_index, samplingFrequencyTable[sampling_frequency_index],
            channel_configuration, fConfigStr, fNumChannels);
#endif

    fHasHeader = true;
    return;

fail:
    fHasHeader = false;
    return;
}

void ADTSAudioStreamParser::flushInput() {

}

struct timeval ADTSAudioStreamParser::getPresentationTime() {
    return fPresentationTime;
}
