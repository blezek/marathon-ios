# Makefile to build and install the SDL library

top_builddir = .
srcdir  = /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14
objects = build
gen = gen
prefix = /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/build-scripts/platform/arm64-ios
exec_prefix = ${prefix}
bindir	= ${exec_prefix}/bin
libdir  = ${exec_prefix}/lib
includedir = ${prefix}/include
datarootdir = ${prefix}/share
datadir	= ${datarootdir}
auxdir	= ../build-scripts
distpath = $(srcdir)/..
distdir = SDL2-2.0.14
distfile = $(distdir).tar.gz


SHELL	= /bin/sh
CC      = clang
INCLUDE = -Iinclude -I/Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/include -idirafter /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/khronos
CFLAGS  =  -Wno-unused-local-typedef -Wno-unused-function -DNDEBUG -g -O0 -pipe -fPIC -fobjc-arc -miphoneos-version-min=6.0 -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.3.sdk -I/usr/local/opt/openssl/include -DUSING_GENERATED_CONFIG_H
EXTRA_CFLAGS = -Iinclude -I/Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/include -idirafter /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/khronos  -Wall -fno-strict-aliasing -fvisibility=hidden -Wdeclaration-after-statement -Werror=declaration-after-statement -D_THREAD_SAFE
LDFLAGS = -arch arm64 -miphoneos-version-min=6.0 -L/usr/local/opt/openssl/lib
EXTRA_LDFLAGS =  -lm -liconv  -lm -liconv -lobjc -Wl,-framework,AVFoundation -Wl,-framework,AudioToolbox -Wl,-framework,CoreAudio -Wl,-framework,CoreGraphics -Wl,-framework,CoreMotion -Wl,-framework,Foundation -Wl,-framework,GameController -Wl,-framework,OpenGLES -Wl,-framework,QuartzCore -Wl,-framework,UIKit
LIBTOOL = $(SHELL) $(top_builddir)/libtool
INSTALL = /usr/local/bin/ginstall -c
AR	= ar
RANLIB	= ranlib
RC	= 

TARGET  = libSDL2.la
OBJECTS = $(objects)/SDL.lo $(objects)/SDL_assert.lo $(objects)/SDL_dataqueue.lo $(objects)/SDL_error.lo $(objects)/SDL_hints.lo $(objects)/SDL_log.lo $(objects)/SDL_atomic.lo $(objects)/SDL_spinlock.lo $(objects)/SDL_audio.lo $(objects)/SDL_audiocvt.lo $(objects)/SDL_audiodev.lo $(objects)/SDL_audiotypecvt.lo $(objects)/SDL_mixer.lo $(objects)/SDL_wave.lo $(objects)/SDL_cpuinfo.lo $(objects)/SDL_dynapi.lo $(objects)/SDL_clipboardevents.lo $(objects)/SDL_displayevents.lo $(objects)/SDL_dropevents.lo $(objects)/SDL_events.lo $(objects)/SDL_gesture.lo $(objects)/SDL_keyboard.lo $(objects)/SDL_mouse.lo $(objects)/SDL_quit.lo $(objects)/SDL_touch.lo $(objects)/SDL_windowevents.lo $(objects)/SDL_rwops.lo $(objects)/SDL_haptic.lo $(objects)/SDL_gamecontroller.lo $(objects)/SDL_joystick.lo $(objects)/e_atan2.lo $(objects)/e_exp.lo $(objects)/e_fmod.lo $(objects)/e_log.lo $(objects)/e_log10.lo $(objects)/e_pow.lo $(objects)/e_rem_pio2.lo $(objects)/e_sqrt.lo $(objects)/k_cos.lo $(objects)/k_rem_pio2.lo $(objects)/k_sin.lo $(objects)/k_tan.lo $(objects)/s_atan.lo $(objects)/s_copysign.lo $(objects)/s_cos.lo $(objects)/s_fabs.lo $(objects)/s_floor.lo $(objects)/s_scalbn.lo $(objects)/s_sin.lo $(objects)/s_tan.lo $(objects)/SDL_url.lo $(objects)/SDL_power.lo $(objects)/SDL_d3dmath.lo $(objects)/SDL_render.lo $(objects)/SDL_yuv_sw.lo $(objects)/SDL_render_d3d.lo $(objects)/SDL_shaders_d3d.lo $(objects)/SDL_render_d3d11.lo $(objects)/SDL_shaders_d3d11.lo $(objects)/SDL_render_gl.lo $(objects)/SDL_shaders_gl.lo $(objects)/SDL_render_gles.lo $(objects)/SDL_render_gles2.lo $(objects)/SDL_shaders_gles2.lo $(objects)/SDL_render_psp.lo $(objects)/SDL_blendfillrect.lo $(objects)/SDL_blendline.lo $(objects)/SDL_blendpoint.lo $(objects)/SDL_drawline.lo $(objects)/SDL_drawpoint.lo $(objects)/SDL_render_sw.lo $(objects)/SDL_rotate.lo $(objects)/SDL_sensor.lo $(objects)/SDL_crc32.lo $(objects)/SDL_getenv.lo $(objects)/SDL_iconv.lo $(objects)/SDL_malloc.lo $(objects)/SDL_qsort.lo $(objects)/SDL_stdlib.lo $(objects)/SDL_string.lo $(objects)/SDL_strtokr.lo $(objects)/SDL_thread.lo $(objects)/SDL_timer.lo $(objects)/SDL_RLEaccel.lo $(objects)/SDL_blit.lo $(objects)/SDL_blit_0.lo $(objects)/SDL_blit_1.lo $(objects)/SDL_blit_A.lo $(objects)/SDL_blit_N.lo $(objects)/SDL_blit_auto.lo $(objects)/SDL_blit_copy.lo $(objects)/SDL_blit_slow.lo $(objects)/SDL_bmp.lo $(objects)/SDL_clipboard.lo $(objects)/SDL_egl.lo $(objects)/SDL_fillrect.lo $(objects)/SDL_pixels.lo $(objects)/SDL_rect.lo $(objects)/SDL_shape.lo $(objects)/SDL_stretch.lo $(objects)/SDL_surface.lo $(objects)/SDL_video.lo $(objects)/SDL_vulkan_utils.lo $(objects)/SDL_yuv.lo $(objects)/yuv_rgb.lo $(objects)/SDL_locale.lo $(objects)/SDL_nullevents.lo $(objects)/SDL_nullframebuffer.lo $(objects)/SDL_nullvideo.lo $(objects)/SDL_diskaudio.lo $(objects)/SDL_dummyaudio.lo $(objects)/SDL_sysloadso.lo $(objects)/SDL_systhread.lo $(objects)/SDL_syssem.lo $(objects)/SDL_sysmutex.lo $(objects)/SDL_syscond.lo $(objects)/SDL_systls.lo $(objects)/SDL_sysurl.lo $(objects)/SDL_syslocale.lo $(objects)/SDL_coreaudio.lo $(objects)/SDL_mfijoystick.lo $(objects)/SDL_steamcontroller.lo $(objects)/SDL_coremotionsensor.lo $(objects)/SDL_syspower.lo $(objects)/SDL_sysfilesystem.lo $(objects)/SDL_rwopsbundlesupport.lo $(objects)/SDL_systimer.lo $(objects)/SDL_poll.lo $(objects)/SDL_uikitappdelegate.lo $(objects)/SDL_uikitclipboard.lo $(objects)/SDL_uikitevents.lo $(objects)/SDL_uikitmessagebox.lo $(objects)/SDL_uikitmetalview.lo $(objects)/SDL_uikitmodes.lo $(objects)/SDL_uikitopengles.lo $(objects)/SDL_uikitopenglview.lo $(objects)/SDL_uikitvideo.lo $(objects)/SDL_uikitview.lo $(objects)/SDL_uikitviewcontroller.lo $(objects)/SDL_uikitvulkan.lo $(objects)/SDL_uikitwindow.lo $(objects)/SDL_virtualjoystick.lo $(objects)/SDL_syshaptic.lo
GEN_HEADERS = 
GEN_OBJECTS = 
VERSION_OBJECTS = 

SDLMAIN_TARGET = libSDL2main.la
SDLMAIN_OBJECTS = $(objects)/SDL_dummy_main.lo

SDLTEST_TARGET = libSDL2_test.la
SDLTEST_OBJECTS = $(objects)/SDL_test_assert.lo $(objects)/SDL_test_common.lo $(objects)/SDL_test_compare.lo $(objects)/SDL_test_crc32.lo $(objects)/SDL_test_font.lo $(objects)/SDL_test_fuzzer.lo $(objects)/SDL_test_harness.lo $(objects)/SDL_test_imageBlit.lo $(objects)/SDL_test_imageBlitBlend.lo $(objects)/SDL_test_imageFace.lo $(objects)/SDL_test_imagePrimitives.lo $(objects)/SDL_test_imagePrimitivesBlend.lo $(objects)/SDL_test_log.lo $(objects)/SDL_test_md5.lo $(objects)/SDL_test_memory.lo $(objects)/SDL_test_random.lo

WAYLAND_SCANNER = 

INSTALL_SDL2_CONFIG = TRUE

SRC_DIST = *.txt acinclude Android.mk autogen.sh android-project build-scripts cmake cmake_uninstall.cmake.in configure configure.ac debian docs include Makefile.* sdl2-config.cmake.in sdl2-config-version.cmake.in sdl2-config.in sdl2.m4 sdl2.pc.in SDL2.spec.in SDL2Config.cmake src test VisualC.html VisualC VisualC-WinRT Xcode Xcode-iOS wayland-protocols
GEN_DIST = SDL2.spec

ifneq ($V,1)
RUN_CMD_AR     = @echo "  AR    " $@;
RUN_CMD_CC     = @echo "  CC    " $@;
RUN_CMD_CXX    = @echo "  CXX   " $@;
RUN_CMD_LTLINK = @echo "  LTLINK" $@;
RUN_CMD_RANLIB = @echo "  RANLIB" $@;
RUN_CMD_RC     = @echo "  RC    " $@;
RUN_CMD_GEN    = @echo "  GEN   " $@;
LIBTOOL += --quiet
endif

HDRS = \
	SDL.h \
	SDL_assert.h \
	SDL_atomic.h \
	SDL_audio.h \
	SDL_bits.h \
	SDL_blendmode.h \
	SDL_clipboard.h \
	SDL_cpuinfo.h \
	SDL_egl.h \
	SDL_endian.h \
	SDL_error.h \
	SDL_events.h \
	SDL_filesystem.h \
	SDL_gamecontroller.h \
	SDL_gesture.h \
	SDL_haptic.h \
	SDL_hints.h \
	SDL_joystick.h \
	SDL_keyboard.h \
	SDL_keycode.h \
	SDL_loadso.h \
	SDL_locale.h \
	SDL_log.h \
	SDL_main.h \
	SDL_messagebox.h \
	SDL_metal.h \
	SDL_misc.h \
	SDL_mouse.h \
	SDL_mutex.h \
	SDL_name.h \
	SDL_opengl.h \
	SDL_opengl_glext.h \
	SDL_opengles.h \
	SDL_opengles2_gl2ext.h \
	SDL_opengles2_gl2.h \
	SDL_opengles2_gl2platform.h \
	SDL_opengles2.h \
	SDL_opengles2_khrplatform.h \
	SDL_pixels.h \
	SDL_platform.h \
	SDL_power.h \
	SDL_quit.h \
	SDL_rect.h \
	SDL_render.h \
	SDL_rwops.h \
	SDL_scancode.h \
	SDL_sensor.h \
	SDL_shape.h \
	SDL_stdinc.h \
	SDL_surface.h \
	SDL_system.h \
	SDL_syswm.h \
	SDL_thread.h \
	SDL_timer.h \
	SDL_touch.h \
	SDL_types.h \
	SDL_version.h \
	SDL_video.h \
	SDL_vulkan.h \
	begin_code.h \
	close_code.h

SDLTEST_HDRS = $(shell ls $(srcdir)/include | fgrep SDL_test)

LT_AGE      = 14
LT_CURRENT  = 14
LT_RELEASE  = 2.0
LT_REVISION = 0
LT_LDFLAGS  = -no-undefined -rpath $(libdir) -release $(LT_RELEASE) -version-info $(LT_CURRENT):$(LT_REVISION):$(LT_AGE)

all: $(srcdir)/configure Makefile $(objects)/$(TARGET) $(objects)/$(SDLMAIN_TARGET) $(objects)/$(SDLTEST_TARGET)

$(srcdir)/configure: $(srcdir)/configure.ac
	@echo "Warning, configure is out of date, please re-run autogen.sh"

Makefile: $(srcdir)/Makefile.in
	$(SHELL) config.status $@

Makefile.in:;

$(objects)/.created:
	$(SHELL) $(auxdir)/mkinstalldirs $(objects)
	touch $@

update-revision:
	$(SHELL) $(auxdir)/updaterev.sh

.PHONY: all update-revision install install-bin install-hdrs install-lib install-data uninstall uninstall-bin uninstall-hdrs uninstall-lib uninstall-data clean distclean dist $(OBJECTS:.lo=.d)

$(objects)/$(TARGET): $(GEN_HEADERS) $(GEN_OBJECTS) $(OBJECTS) $(VERSION_OBJECTS)
	$(RUN_CMD_LTLINK)$(LIBTOOL) --tag=CC --mode=link $(CC) -o $@ $(OBJECTS) $(GEN_OBJECTS) $(VERSION_OBJECTS) $(LDFLAGS) $(EXTRA_LDFLAGS) $(LT_LDFLAGS)

$(objects)/$(SDLMAIN_TARGET): $(SDLMAIN_OBJECTS)
	$(RUN_CMD_LTLINK)$(LIBTOOL) --tag=CC --mode=link $(CC) -static -o $@ $(SDLMAIN_OBJECTS) -rpath $(libdir)

$(objects)/$(SDLTEST_TARGET): $(SDLTEST_OBJECTS)
	$(RUN_CMD_LTLINK)$(LIBTOOL) --tag=CC --mode=link $(CC) -static -o $@ $(SDLTEST_OBJECTS) -rpath $(libdir)

install: all install-bin install-hdrs install-lib install-data
install-bin:
ifeq ($(INSTALL_SDL2_CONFIG),TRUE)
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 sdl2-config $(DESTDIR)$(bindir)/sdl2-config
endif

install-hdrs: update-revision
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(includedir)/SDL2
	for file in $(HDRS) $(SDLTEST_HDRS); do \
	    $(INSTALL) -m 644 $(srcdir)/include/$$file $(DESTDIR)$(includedir)/SDL2/$$file; \
	done
	$(INSTALL) -m 644 include/SDL_config.h $(DESTDIR)$(includedir)/SDL2/SDL_config.h
	if test -f include/SDL_revision.h; then \
	    $(INSTALL) -m 644 include/SDL_revision.h $(DESTDIR)$(includedir)/SDL2/SDL_revision.h; \
	else \
	    $(INSTALL) -m 644 $(srcdir)/include/SDL_revision.h $(DESTDIR)$(includedir)/SDL2/SDL_revision.h; \
	fi

install-lib: $(objects)/$(TARGET) $(objects)/$(SDLMAIN_TARGET) $(objects)/$(SDLTEST_TARGET)
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(libdir)
	$(LIBTOOL) --mode=install $(INSTALL) $(objects)/$(TARGET) $(DESTDIR)$(libdir)/$(TARGET)
	$(LIBTOOL) --mode=install $(INSTALL) $(objects)/$(SDLMAIN_TARGET) $(DESTDIR)$(libdir)/$(SDLMAIN_TARGET)
	$(LIBTOOL) --mode=install $(INSTALL) $(objects)/$(SDLTEST_TARGET) $(DESTDIR)$(libdir)/$(SDLTEST_TARGET)
install-data:
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(datadir)/aclocal
	$(INSTALL) -m 644 $(srcdir)/sdl2.m4 $(DESTDIR)$(datadir)/aclocal/sdl2.m4
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(libdir)/pkgconfig
	$(INSTALL) -m 644 sdl2.pc $(DESTDIR)$(libdir)/pkgconfig
ifeq ($(INSTALL_SDL2_CONFIG),TRUE)
	$(SHELL) $(auxdir)/mkinstalldirs $(DESTDIR)$(libdir)/cmake/SDL2
	$(INSTALL) -m 644 sdl2-config.cmake $(DESTDIR)$(libdir)/cmake/SDL2
	$(INSTALL) -m 644 sdl2-config-version.cmake $(DESTDIR)$(libdir)/cmake/SDL2
endif

uninstall: uninstall-bin uninstall-hdrs uninstall-lib uninstall-data
uninstall-bin:
	rm -f $(DESTDIR)$(bindir)/sdl2-config
uninstall-hdrs:
	for file in $(HDRS) $(SDLTEST_HDRS); do \
	    rm -f $(DESTDIR)$(includedir)/SDL2/$$file; \
	done
	rm -f $(DESTDIR)$(includedir)/SDL2/SDL_config.h
	rm -f $(DESTDIR)$(includedir)/SDL2/SDL_revision.h
	-rmdir $(DESTDIR)$(includedir)/SDL2
uninstall-lib:
	$(LIBTOOL) --mode=uninstall rm -f $(DESTDIR)$(libdir)/$(TARGET)
	rm -f $(DESTDIR)$(libdir)/$(SDLMAIN_TARGET)
	rm -f $(DESTDIR)$(libdir)/$(SDLTEST_TARGET)
uninstall-data:
	rm -f $(DESTDIR)$(datadir)/aclocal/sdl2.m4
	rm -f $(DESTDIR)$(libdir)/pkgconfig/sdl2.pc
	rm -f $(DESTDIR)$(libdir)/cmake/SDL2/sdl2-config.cmake
	rm -f $(DESTDIR)$(libdir)/cmake/SDL2/sdl2-config-version.cmake

clean:
	rm -rf $(objects)
	rm -rf $(gen)
	if test -f test/Makefile; then (cd test; $(MAKE) $@); fi

distclean: clean
	rm -f Makefile Makefile.rules sdl2-config
	rm -f config.status config.cache config.log libtool
	rm -rf $(srcdir)/autom4te*
	find $(srcdir) \( \
	    -name '*~' -o \
	    -name '*.bak' -o \
	    -name '*.old' -o \
	    -name '*.rej' -o \
	    -name '*.orig' -o \
	    -name '.#*' \) \
	    -exec rm -f {} \;
	if test -f test/Makefile; then (cd test; $(MAKE) $@); fi

dist $(distfile):
	$(SHELL) $(auxdir)/mkinstalldirs $(distdir)
	(cd $(srcdir); tar cf - $(SRC_DIST)) | (cd $(distdir); tar xf -)
	tar cf - $(GEN_DIST) | (cd $(distdir); tar xf -)
	find $(distdir) \( \
	    -name '*~' -o \
	    -name '*.bak' -o \
	    -name '*.old' -o \
	    -name '*.rej' -o \
	    -name '*.orig' -o \
	    -name '.#*' \) \
	    -exec rm -f {} \;
	if test -f $(distdir)/test/Makefile; then (cd $(distdir)/test && make distclean); fi
	(cd $(distdir); build-scripts/updaterev.sh)
	tar cvf - $(distdir) | gzip --best >$(distfile)
	rm -rf $(distdir)

rpm: $(distfile)
	rpmbuild -ta $?

# Build rules for objects
-include $(OBJECTS:.lo=.d)

# Special dependency for SDL.c, since it depends on SDL_revision.h
/Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL.c: update-revision

$(objects)/SDL.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_assert.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL_assert.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_dataqueue.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL_dataqueue.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_error.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL_error.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_hints.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL_hints.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_log.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/SDL_log.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_atomic.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/atomic/SDL_atomic.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_spinlock.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/atomic/SDL_spinlock.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_audio.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_audio.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_audiocvt.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_audiocvt.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_audiodev.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_audiodev.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_audiotypecvt.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_audiotypecvt.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_mixer.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_mixer.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_wave.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/SDL_wave.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_cpuinfo.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/cpuinfo/SDL_cpuinfo.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_dynapi.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/dynapi/SDL_dynapi.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_clipboardevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_clipboardevents.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_displayevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_displayevents.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_dropevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_dropevents.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_events.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_events.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_gesture.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_gesture.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_keyboard.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_keyboard.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_mouse.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_mouse.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_quit.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_quit.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_touch.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_touch.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_windowevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/events/SDL_windowevents.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_rwops.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/file/SDL_rwops.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_haptic.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/haptic/SDL_haptic.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_gamecontroller.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/joystick/SDL_gamecontroller.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_joystick.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/joystick/SDL_joystick.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_atan2.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_atan2.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_exp.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_exp.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_fmod.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_fmod.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_log.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_log.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_log10.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_log10.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_pow.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_pow.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_rem_pio2.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_rem_pio2.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/e_sqrt.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/e_sqrt.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/k_cos.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/k_cos.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/k_rem_pio2.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/k_rem_pio2.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/k_sin.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/k_sin.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/k_tan.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/k_tan.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_atan.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_atan.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_copysign.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_copysign.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_cos.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_cos.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_fabs.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_fabs.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_floor.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_floor.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_scalbn.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_scalbn.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_sin.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_sin.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/s_tan.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/libm/s_tan.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_url.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/misc/SDL_url.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_power.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/power/SDL_power.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_d3dmath.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/SDL_d3dmath.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/SDL_render.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_yuv_sw.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/SDL_yuv_sw.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_d3d.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/direct3d/SDL_render_d3d.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_shaders_d3d.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/direct3d/SDL_shaders_d3d.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_d3d11.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/direct3d11/SDL_render_d3d11.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_shaders_d3d11.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/direct3d11/SDL_shaders_d3d11.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_gl.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/opengl/SDL_render_gl.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_shaders_gl.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/opengl/SDL_shaders_gl.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_gles.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/opengles/SDL_render_gles.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_gles2.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/opengles2/SDL_render_gles2.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_shaders_gles2.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/opengles2/SDL_shaders_gles2.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_psp.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/psp/SDL_render_psp.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blendfillrect.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_blendfillrect.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blendline.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_blendline.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blendpoint.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_blendpoint.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_drawline.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_drawline.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_drawpoint.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_drawpoint.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_render_sw.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_render_sw.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_rotate.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/render/software/SDL_rotate.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_sensor.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/sensor/SDL_sensor.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_crc32.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_crc32.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_getenv.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_getenv.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_iconv.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_iconv.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_malloc.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_malloc.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_qsort.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_qsort.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_stdlib.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_stdlib.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_string.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_string.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_strtokr.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/stdlib/SDL_strtokr.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_thread.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/SDL_thread.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_timer.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/timer/SDL_timer.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_RLEaccel.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_RLEaccel.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_0.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_0.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_1.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_1.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_A.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_A.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_N.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_N.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_auto.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_auto.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_copy.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_copy.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_blit_slow.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_blit_slow.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_bmp.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_bmp.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_clipboard.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_clipboard.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_egl.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_egl.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_fillrect.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_fillrect.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_pixels.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_pixels.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_rect.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_rect.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_shape.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_shape.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_stretch.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_stretch.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_surface.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_surface.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_video.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_video.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_vulkan_utils.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_vulkan_utils.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_yuv.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/SDL_yuv.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/yuv_rgb.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/yuv2rgb/yuv_rgb.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_locale.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/locale/SDL_locale.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_nullevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/dummy/SDL_nullevents.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_nullframebuffer.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/dummy/SDL_nullframebuffer.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_nullvideo.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/dummy/SDL_nullvideo.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_diskaudio.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/disk/SDL_diskaudio.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_dummyaudio.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/dummy/SDL_dummyaudio.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_sysloadso.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/loadso/dlopen/SDL_sysloadso.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_systhread.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/pthread/SDL_systhread.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_syssem.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/pthread/SDL_syssem.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_sysmutex.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/pthread/SDL_sysmutex.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_syscond.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/pthread/SDL_syscond.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_systls.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/thread/pthread/SDL_systls.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_sysurl.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/misc/ios/SDL_sysurl.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_syslocale.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/locale/macosx/SDL_syslocale.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_coreaudio.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/audio/coreaudio/SDL_coreaudio.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_mfijoystick.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/joystick/iphoneos/SDL_mfijoystick.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_steamcontroller.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/joystick/steam/SDL_steamcontroller.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_coremotionsensor.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/sensor/coremotion/SDL_coremotionsensor.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_syspower.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/power/uikit/SDL_syspower.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_sysfilesystem.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/filesystem/cocoa/SDL_sysfilesystem.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_rwopsbundlesupport.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/file/cocoa/SDL_rwopsbundlesupport.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_systimer.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/timer/unix/SDL_systimer.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_poll.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/core/unix/SDL_poll.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitappdelegate.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitappdelegate.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitclipboard.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitclipboard.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitevents.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitevents.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitmessagebox.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitmessagebox.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitmetalview.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitmetalview.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitmodes.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitmodes.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitopengles.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitopengles.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitopenglview.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitopenglview.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitvideo.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitvideo.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitview.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitview.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitviewcontroller.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitviewcontroller.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitvulkan.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitvulkan.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_uikitwindow.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/video/uikit/SDL_uikitwindow.m $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_virtualjoystick.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/joystick/virtual/SDL_virtualjoystick.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_syshaptic.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/haptic/dummy/SDL_syshaptic.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@


$(objects)/SDL_dummy_main.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/main/dummy/SDL_dummy_main.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

$(objects)/SDL_test_assert.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_assert.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_common.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_common.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_compare.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_compare.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_crc32.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_crc32.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_font.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_font.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_fuzzer.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_fuzzer.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_harness.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_harness.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_imageBlit.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_imageBlit.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_imageBlitBlend.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_imageBlitBlend.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_imageFace.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_imageFace.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_imagePrimitives.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_imagePrimitives.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_imagePrimitivesBlend.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_imagePrimitivesBlend.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_log.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_log.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_md5.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_md5.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_memory.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_memory.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@ 
$(objects)/SDL_test_random.lo: /Users/taxxodium/Documents/ExternalDev/marathon-ios/submodules/Libraries/SDL2-2.0.14/src/test/SDL_test_random.c $(objects)/.created
	$(RUN_CMD_CC)$(LIBTOOL) --tag=CC --mode=compile $(CC) $(CFLAGS) $(EXTRA_CFLAGS) -MMD -MT $@ -c $< -o $@

