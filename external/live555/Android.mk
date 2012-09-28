LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

live555_DEFINES = -DSOCKLEN_T=socklen_t -DNO_SSTREAM=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 -DREAD_FROM_FILES_SYNCHRONOUSLY=1 -DXLOCALE_NOT_USED=1 #-DDEBUG=1

LOCAL_SRC_FILES := \
	BasicUsageEnvironment/BasicTaskScheduler0.cpp\
	BasicUsageEnvironment/BasicHashTable.cpp\
	BasicUsageEnvironment/DelayQueue.cpp\
	BasicUsageEnvironment/BasicUsageEnvironment.cpp\
	BasicUsageEnvironment/BasicTaskScheduler.cpp\
	BasicUsageEnvironment/BasicUsageEnvironment0.cpp\

LOCAL_SRC_FILES += \
	groupsock/GroupsockHelper.cpp\
	groupsock/Groupsock.cpp\
	groupsock/GroupEId.cpp\
	groupsock/NetAddress.cpp\
	groupsock/IOHandlers.cpp\
	groupsock/NetInterface.cpp\
	groupsock/inet.c\

LOCAL_SRC_FILES += \
	liveMedia/RTPSource.cpp\
	liveMedia/MP3HTTPSource.cpp\
	liveMedia/RTPSink.cpp\
	liveMedia/SimpleRTPSource.cpp\
	liveMedia/MP3Transcoder.cpp\
	liveMedia/SimpleRTPSink.cpp\
	liveMedia/MP3ADU.cpp\
	liveMedia/RTCP.cpp\
	liveMedia/RTSPClient.cpp\
	liveMedia/MatroskaFileParser.cpp\
	liveMedia/AVIFileSink.cpp\
	liveMedia/MediaSource.cpp\
	liveMedia/MP3FileSource.cpp\
	liveMedia/SIPClient.cpp\
	liveMedia/FileSink.cpp\
	liveMedia/MultiFramedRTPSource.cpp\
	liveMedia/RTPInterface.cpp\
	liveMedia/MediaSink.cpp\
	liveMedia/Media.cpp\
	liveMedia/ServerMediaSession.cpp\
	liveMedia/ByteStreamFileSource.cpp\
	liveMedia/QuickTimeFileSink.cpp\
	liveMedia/MPEG2IndexFromTransportStream.cpp\
	liveMedia/OnDemandServerMediaSubsession.cpp\
	liveMedia/AC3AudioFileServerMediaSubsession.cpp\
	liveMedia/RTSPServer.cpp\
	liveMedia/QuickTimeGenericRTPSource.cpp\
	liveMedia/MPEG1or2Demux.cpp\
	liveMedia/MP3Internals.cpp\
	liveMedia/FramedFileSource.cpp\
	liveMedia/JPEGVideoRTPSink.cpp\
	liveMedia/MPEG4LATMAudioRTPSource.cpp\
	liveMedia/AC3AudioRTPSink.cpp\
	liveMedia/FramedFilter.cpp\
	liveMedia/FramedSource.cpp\
	liveMedia/AMRAudioFileSource.cpp\
	liveMedia/MP3ADUdescriptor.cpp\
	liveMedia/MP3ADUinterleaving.cpp\
	liveMedia/AMRAudioRTPSink.cpp\
	liveMedia/MediaSession.cpp\
	liveMedia/BitVector.cpp\
	liveMedia/MPEG1or2AudioStreamFramer.cpp\
	liveMedia/MP3ADUTranscoder.cpp\
	liveMedia/MPEG1or2VideoRTPSink.cpp\
	liveMedia/MP3InternalsHuffman.cpp\
	liveMedia/MP3ADURTPSink.cpp\
	liveMedia/JPEGVideoRTPSource.cpp\
	liveMedia/AudioInputDevice.cpp\
	liveMedia/StreamParser.cpp\
	liveMedia/MPEG1or2AudioRTPSink.cpp\
	liveMedia/MPEG4VideoStreamFramer.cpp\
	liveMedia/MPEG1or2AudioRTPSource.cpp\
	liveMedia/H263plusVideoRTPSink.cpp\
	liveMedia/MPEG1or2DemuxedElementaryStream.cpp\
	liveMedia/MPEG1or2VideoRTPSource.cpp\
	liveMedia/MPEG1or2VideoStreamFramer.cpp\
	liveMedia/MPEGVideoStreamParser.cpp\
	liveMedia/FileServerMediaSubsession.cpp\
	liveMedia/MPEG1or2VideoStreamDiscreteFramer.cpp\
	liveMedia/AC3AudioStreamFramer.cpp\
	liveMedia/DarwinInjector.cpp\
	liveMedia/MP3AudioFileServerMediaSubsession.cpp\
	liveMedia/MPEG4ESVideoRTPSink.cpp\
	liveMedia/DigestAuthentication.cpp\
	liveMedia/PassiveServerMediaSubsession.cpp\
	liveMedia/AC3AudioRTPSource.cpp\
	liveMedia/GSMAudioRTPSink.cpp\
	liveMedia/BasicUDPSource.cpp\
	liveMedia/H264VideoRTPSource.cpp\
	liveMedia/MPEG4VideoStreamDiscreteFramer.cpp\
	liveMedia/MPEG2TransportStreamFromPESSource.cpp\
	liveMedia/H263plusVideoRTPSource.cpp\
	liveMedia/DVVideoRTPSource.cpp\
	liveMedia/DVVideoStreamFramer.cpp\
	liveMedia/RTSPCommon.cpp\
	liveMedia/VP8VideoRTPSource.cpp\
	liveMedia/MP3ADURTPSource.cpp\
	liveMedia/QCELPAudioRTPSource.cpp\
	liveMedia/ByteStreamMultiFileSource.cpp\
	liveMedia/MPEG1or2FileServerDemux.cpp\
	liveMedia/DeviceSource.cpp\
	liveMedia/MPEG2TransportStreamMultiplexor.cpp\
	liveMedia/MPEG2TransportFileServerMediaSubsession.cpp\
	liveMedia/MPEG2TransportStreamFramer.cpp\
	liveMedia/MPEG4ESVideoRTPSource.cpp\
	liveMedia/H261VideoRTPSource.cpp\
	liveMedia/MPEG4GenericRTPSource.cpp\
	liveMedia/MPEGVideoStreamFramer.cpp\
	liveMedia/MPEG4LATMAudioRTPSink.cpp\
	liveMedia/uLawAudioFilter.cpp\
	liveMedia/JPEGVideoSource.cpp\
	liveMedia/VideoRTPSink.cpp\
	liveMedia/AudioRTPSink.cpp\
	liveMedia/DVVideoRTPSink.cpp\
	liveMedia/MPEG4VideoFileServerMediaSubsession.cpp\
	liveMedia/AMRAudioSource.cpp\
	liveMedia/AMRAudioFileServerMediaSubsession.cpp\
	liveMedia/InputFile.cpp\
	liveMedia/AMRAudioRTPSource.cpp\
	liveMedia/BasicUDPSink.cpp\
	liveMedia/OutputFile.cpp\
	liveMedia/H264VideoFileSink.cpp\
	liveMedia/Base64.cpp\
	liveMedia/ADTSAudioFileSource.cpp\
	liveMedia/MP3InternalsHuffmanTable.cpp\
	liveMedia/ADTSAudioFileServerMediaSubsession.cpp\
	liveMedia/MP3StreamState.cpp\
	liveMedia/MPEG2TransportStreamFromESSource.cpp\
	liveMedia/H263plusVideoStreamParser.cpp\
	liveMedia/Locale.cpp\
	liveMedia/H263plusVideoStreamFramer.cpp\
	liveMedia/WAVAudioFileServerMediaSubsession.cpp\
	liveMedia/H264VideoRTPSink.cpp\
	liveMedia/H264VideoStreamDiscreteFramer.cpp\
	liveMedia/WAVAudioFileSource.cpp\
	liveMedia/MPEG1or2DemuxedServerMediaSubsession.cpp\
	liveMedia/MPEG2TransportStreamIndexFile.cpp\
	liveMedia/MPEG2TransportStreamTrickModeFilter.cpp\
	liveMedia/H264VideoStreamFramer.cpp\
	liveMedia/AC3AudioMatroskaFileServerMediaSubsession.cpp\
	liveMedia/RTSPServerSupportingHTTPStreaming.cpp\
	liveMedia/AMRAudioFileSink.cpp\
	liveMedia/H264VideoFileServerMediaSubsession.cpp\
	liveMedia/TCPStreamSink.cpp\
	liveMedia/TextRTPSink.cpp\
	liveMedia/T140TextRTPSink.cpp\
	liveMedia/MatroskaDemuxedTrack.cpp\
	liveMedia/H264VideoMatroskaFileServerMediaSubsession.cpp\
	liveMedia/EBMLNumber.cpp\
	liveMedia/AACAudioMatroskaFileServerMediaSubsession.cpp\
	liveMedia/MP3AudioMatroskaFileServerMediaSubsession.cpp\
	liveMedia/MatroskaFileServerDemux.cpp\
	liveMedia/MatroskaFile.cpp\
	liveMedia/T140TextMatroskaFileServerMediaSubsession.cpp\
	liveMedia/H263plusVideoFileServerMediaSubsession.cpp\
	liveMedia/DVVideoFileServerMediaSubsession.cpp\
	liveMedia/VorbisAudioMatroskaFileServerMediaSubsession.cpp\
	liveMedia/VorbisAudioRTPSink.cpp\
	liveMedia/VorbisAudioRTPSource.cpp\
	liveMedia/VP8VideoRTPSink.cpp\
	liveMedia/MultiFramedRTPSink.cpp\
	liveMedia/MPEG1or2VideoFileServerMediaSubsession.cpp\
	liveMedia/VP8VideoMatroskaFileServerMediaSubsession.cpp\
	liveMedia/ByteStreamMemoryBufferSource.cpp\
	liveMedia/MPEG4GenericRTPSink.cpp\
	liveMedia/rtcp_from_spec.c\
	liveMedia/our_md5hl.c\
	liveMedia/our_md5.c\
	liveMedia/ADTSAudioStreamFramer.cpp\
	liveMedia/ADTSAudioStreamParser.cpp\

LOCAL_SRC_FILES += \
	mediaServer/live555MediaServer.cpp\
	mediaServer/DynamicRTSPServer.cpp\

LOCAL_SRC_FILES += \
	UsageEnvironment/HashTable.cpp\
	UsageEnvironment/strDup.cpp\
	UsageEnvironment/UsageEnvironment.cpp\

LOCAL_C_INCLUDES += $(LOCAL_PATH)\
	$(LOCAL_PATH)/BasicUsageEnvironment/include/\
	$(LOCAL_PATH)/groupsock/include/\
	$(LOCAL_PATH)/liveMedia/include/\
	$(LOCAL_PATH)/liveMedia/\
	$(LOCAL_PATH)/mediaServer/\
	$(LOCAL_PATH)/testProgs/\
	$(LOCAL_PATH)/UsageEnvironment/include/\
	$(LOCAL_PATH)/WindowsAudioInputDevice/\
	prebuilt/ndk/android-ndk-r6/sources/cxx-stl/gnu-libstdc++/libs/armeabi/include


LOCAL_NDK_STL_VARIANT := gnustl_static

LOCAL_CFLAGS += -Wall $(live555_DEFINES) -g -O2
LOCAL_CPPFLAGS += -frtti -fexceptions -Wall $(live555_DEFINES) -g -O2  

LOCAL_NDK_VERSION := 6
LOCAL_SDK_VERSION := 9

LOCAL_MODULE:= liblive555
LOCAL_MODULE_TAGS:= optional

LOCAL_PRELINK_MODULE := false

include $(BUILD_SHARED_LIBRARY)
