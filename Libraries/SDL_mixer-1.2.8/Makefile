all:libSDL_mixer$(SS_LIBEXT)
 
SOURCE := \
   ./effect_position.c \
   ./effect_stereoreverse.c \
   music_ogg.c \
   dynamic_ogg.c \
   load_ogg.c \
   ./effects_internal.c \
   ./load_aiff.c \
   ./load_voc.c \
   ./mixer.c \
   ./music.c \
   ./music_cmd.c \
   ./wavestream.c \
   ./dynamic_mp3.c \
   $(wildcard mikmod/*.c) \
   $(wildcard ./timidity/*.c) \
   $(wildcard ./native_midi/*.c)



OBJS := $(SOURCE:%.c=%$(SS_OBJEXT))

libSDL_mixer$(SS_LIBEXT): $(OBJS)
	$(SS_CREATELIB)libSDL_mixer$(SS_LIBEXT) $(OBJS)

ifndef SS_IPHONE
   MP3_FILES := -DMP3_MUSIC
ifndef SS_LINUX
   MIDI_FILES := -DUSE_NATIVE_MIDI
endif
endif

CONFIG := \
   -Imikmod \
   -DOGG_MUSIC \
	-DHAVE_LIBC=1 \
	-DMID_MUSIC \
	-DCMD_MUSIC \
	-DWAV_MUSIC \
	 $(MIDI_FILES) \
	-DMOD_MUSIC \
         $(MP3_FILES) \
	-D__STDC__

%$(SS_OBJEXT):%.c
	$(SS_CC) $(CONFIG) -I../../include -Inative_midi -I../$(SDL_INC) $< -c $(SS_OBJOUT)$@


clean:
	rm -f $(OBJS)
