#ifndef _ADTS_AUDIO_STREAM_PARSER_HH
#define _ADTS_AUDIO_STREAM_PARSER_HH

#ifndef _STREAM_PARSER_HH
#include "StreamParser.hh"
#endif

#ifndef _FRAMED_SOURCE_HH
#include "FramedSource.hh"
#endif

#ifndef _ADTS_AUDIO_STREAM_FRAMER_HH
#include "ADTSAudioStreamFramer.hh"
#endif

class ADTSAudioStreamFramer;

class ADTSAudioStreamParser: public StreamParser {
public:
  ADTSAudioStreamParser(ADTSAudioStreamFramer *usingSource, FramedSource *inputSource, Boolean includeStartCodeInOutput);
  virtual ~ADTSAudioStreamParser();

  void registerReadInterest(unsigned char* to, unsigned maxSize);
  virtual unsigned parse();
      // The number of truncated bytes (if any) is given by:
  unsigned numTruncatedBytes() const { return fNumTruncatedBytes; }
  struct timeval getPresentationTime();

private:
  void restoreSavedParserState();
  void setParseState();
  void parseHeader();

  ADTSAudioStreamFramer *usingSource() {
    return (ADTSAudioStreamFramer *)fUsingSource;
  }

  void saveByte(u_int8_t byte) {
    if (fTo >= fLimit) { // there's no space left
      ++fNumTruncatedBytes;
      return;
    }

    *fTo++ = byte;
  }

  void save4Bytes(u_int32_t word) {
    if (fTo+4 > fLimit) { // there's no space left
      fNumTruncatedBytes += 4;
      return;
    }

    *fTo++ = word>>24; *fTo++ = word>>16; *fTo++ = word>>8; *fTo++ = word;
  }

  virtual void flushInput();

private:
  ADTSAudioStreamFramer *fUsingSource;
  bool fIncludeStartCodeInOutput;
  bool fHasHeader;
  unsigned char* fStartOfFrame;
  unsigned char* fTo;
  unsigned char* fLimit;
  unsigned fFrameLength;
  unsigned fNumValidDataBytes;
  unsigned fNumTruncatedBytes;
  unsigned curFrameSize() { return fTo - fStartOfFrame; }
  unsigned char* fSavedTo;
  unsigned fSavedNumTruncatedBytes;
  unsigned fSamplingFrequency; 
  unsigned fNumChannels; 
  unsigned fuSecsPerFrame; 
  char fConfigStr[5]; 
  struct timeval fPresentationTime;
  unsigned fDurationInMicroseconds;

};

#endif
