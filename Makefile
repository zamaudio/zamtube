#!/usr/bin/make -f

PREFIX ?= /usr/local
LIBDIR ?= lib
LV2DIR ?= $(PREFIX)/$(LIBDIR)/lv2

OPTIMIZATIONS ?= -msse -msse2 -mfpmath=sse -ffast-math -fomit-frame-pointer -O3 -fno-finite-math-only

LDFLAGS ?= -Wl,--as-needed -lm
CXXFLAGS ?= $(OPTIMIZATIONS) -Wall 
CFLAGS ?= $(OPTIMIZATIONS) -Wall 

###############################################################################
BUNDLE = zamtube.lv2

CXXFLAGS += -fPIC -DPIC
CFLAGS += -fPIC -DPIC

UNAME=$(shell uname)
ifeq ($(UNAME),Darwin)
  LIB_EXT=.dylib
  LDFLAGS += -dynamiclib
else
  LDFLAGS += -shared -Wl,-Bstatic -Wl,-Bdynamic
  LIB_EXT=.so
endif


ifeq ($(shell pkg-config --exists lv2 lv2core lv2-plugin || echo no), no)
  $(error "LV2 SDK was not found")
else
  LV2FLAGS=`pkg-config --cflags --libs lv2 lv2core lv2-plugin`
endif

$(BUNDLE): manifest.ttl zamtube.ttl zamtube$(LIB_EXT)
	rm -rf $(BUNDLE)
	mkdir $(BUNDLE)
	cp manifest.ttl zamtube.ttl zamtube$(LIB_EXT) $(BUNDLE)

zamtube.peg: zamtube.ttl
	lv2peg zamtube.ttl zamtube.peg

zamtube$(LIB_EXT): zamtube.cpp wdf.cpp
	$(CXX) -o zamtube$(LIB_EXT) \
		$(CXXFLAGS) \
		zamtube.cpp \
		wdf.cpp \
		$(LV2FLAGS) $(LDFLAGS)

install: $(BUNDLE)
	install -d $(DESTDIR)$(LV2DIR)/$(BUNDLE)
	install -t $(DESTDIR)$(LV2DIR)/$(BUNDLE) $(BUNDLE)/*

uninstall:
	rm -rf $(DESTDIR)$(LV2DIR)/$(BUNDLE)

clean:
	rm -rf $(BUNDLE) zamtube$(LIB_EXT) zamtube.peg

.PHONY: clean install uninstall
