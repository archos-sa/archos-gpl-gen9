#ifndef _ADTS_AUDIO_STREAM_FRAMER_HH
#define _ADTS_AUDIO_STREAM_FRAMER_HH

#ifndef _MPEG_VIDEO_STREAM_FRAMER_HH
#include "FramedFilter.hh"
#endif

#ifndef _ADTS_AUDIO_STREAM_PARSER_HH
#include "ADTSAudioStreamParser.hh"
#endif

class ADTSAudioStreamParser;

class ADTSAudioStreamFramer: public FramedFilter {
public:
  static ADTSAudioStreamFramer* createNew(UsageEnvironment& env, FramedSource* inputSource,
					  Boolean includeStartCodeInOutput = False);

  // redefined virtual functions:
  virtual void doGetNextFrame();
  static void afterGettingFrame(void* clientData, unsigned frameSize, unsigned numTruncatedBytes, 
          struct timeval presentationTime, unsigned durationInMicroseconds);
  static void continueReadProcessing(void* clientData,
				     unsigned char* ptr, unsigned size,
				     struct timeval presentationTime);

protected:
  ADTSAudioStreamFramer(UsageEnvironment& env, FramedSource* inputSource, Boolean includeStartCodeInOutput);
  virtual ~ADTSAudioStreamFramer();

private:
  void parseHeader();
  void afterGettingFrame1(unsigned frameSize, unsigned numTruncatedBytes, struct timeval presentationTime,
					   unsigned durationInMicroseconds);
  void continueReadProcessing();
  void setPresentationTime(struct timeval presentationTime);

private:
  Boolean fIncludeStartCodeInOutput;
  ADTSAudioStreamParser *fParser;
  struct timeval fNextPresentationTime;
};

#endif
