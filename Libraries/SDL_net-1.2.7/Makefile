all:libSDL_net$(SS_LIBEXT)

SOURCE := SDLnet.c	SDLnetTCP.c	SDLnetUDP.c	SDLnetselect.c

OBJS := $(SOURCE:%.c=%$(SS_OBJEXT))

libSDL_net$(SS_LIBEXT): $(OBJS)
	$(SS_CREATELIB)libSDL_net$(SS_LIBEXT) $(OBJS)

%$(SS_OBJEXT):%.c
	$(SS_CC) $(CONFIG) -I../../include -I../$(SDL_INC) $< -c

clean:
	rm -f $(OBJS)
