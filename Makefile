#  falab - free algorithm lab 
#  Copyright © 2012 luolongzhi  罗龙智 (Chengdu, China)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#  filename: Makefile
#  version : 2.1.0.229
#  time    : 2019/07/14
#  author  : luolongzhi ( falab2012@gmail.com luolongzhi@gmail.com )
#  code URL: https://github.com/Sound-Linux-More/falabaac
#
#  comment : this file is the simple template which will be used in falab,
#            it will be changed according to the project
#

PNAME = falabaac
VERSION_MAJOR = 2
VERSION_MINOR = 1
VERSION_RELEASE = 1
PREFIX = ~/.local

ARCH =
DEBUG =
CROSS =
STRIP =

ifeq ($(ARCH), ARM)
	CROSS = arm-linux-
endif

# CC = $(CROSS)gcc
CC = clang
CFLAGS = -I. -std=c11

ifeq ($(ARCH), ARM)
	CFLAGS += -D__ARM__ -mcpu=arm9tdmi
endif

CFLAGS += -Wall -O3
STRIP = strip

ifneq ($(shell uname -m), i386)
	CFLAGS += -fPIC
endif

AR = $(CROSS)ar
ARFLAG = rcs
RANLIB = $(CROSS)ranlib

.PHONY : all install clean

INCLUDEDIR = ./src/include

CFLAGS      += -I./src -I$(INCLUDEDIR)
TARGET       = $(PNAME)
TLIBA        = lib$(PNAME).a
TLIBSO       = lib$(PNAME).so.$(VERSION_MAJOR)
MANFILES     = $(shell ls ./man/man[0-9]/*.[0-9])
MANGZFILES   = $(patsubst %,%.gz,$(MANFILES))
CSRCFILES    = $(shell ls ./src/frontend/*.c)
CSRCLIBFILES = $(shell ls ./src/lib$(PNAME)/*.c)
COBJFILES    = $(patsubst %.c,%.o,$(CSRCFILES))
COBJLIBFILES = $(patsubst %.c,%.o,$(CSRCLIBFILES))
RM           = rm -f
INSTALL      = install
GZ           = gzip -kf

LDFLAGS += -lm -lpthread -lrt -L. -l$(PNAME)
ifeq ($(ARCH),ARCH_ARM)
	LDFLAGS += -static
else
ifeq ($(SHARED), Y)
	TLIB = $(TLIBSO)
else
	LDFLAGS += -static
	TLIB = $(TLIBA)
endif
endif

all: $(TLIBA) $(TLIBSO) $(TARGET) $(MANGZFILES)

$(TLIBA) : $(COBJLIBFILES)
	$(AR) $(ARFLAG) $@ $^

$(TLIBSO) : $(COBJLIBFILES)
	$(CC) -shared -Wl,-soname,$@ -o $@ $^

$(TARGET) : $(COBJFILES) $(TLIB)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(MANGZFILES) : $(MANFILES)
	$(GZ) $<

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ -c $< -Wno-unused-function

clean : 
	$(RM) $(COBJFILES)
	$(RM) $(COBJLIBFILES)
	$(RM) $(TLIBA)
	$(RM) $(TLIBSO)
	$(RM) $(TARGET)
	$(RM) $(MANGZFILES)

install :
	$(INSTALL) -d $(PREFIX)/lib
	$(INSTALL) -m 0644 $(TLIBA) $(PREFIX)/lib/
	$(INSTALL) -m 0644 $(TLIBSO) $(PREFIX)/lib/
	$(INSTALL) -d $(PREFIX)/bin
	$(INSTALL) -m 0755 $(TARGET) $(PREFIX)/bin/
	$(INSTALL) -d $(PREFIX)/include
	$(INSTALL) -m 0644 ./src/include/fa_aacapi.h $(PREFIX)/include/
	$(INSTALL) -m 0644 ./src/include/fa_inttypes.h $(PREFIX)/include/
	$(INSTALL) -d $(PREFIX)/share/man/man1
	$(INSTALL) -m 0644 $(MANGZFILES) $(PREFIX)/share/

uninstall :
	$(RM) $(PREFIX)/lib/$(TLIBA)
	$(RM) $(PREFIX)/lib/$(TLIBSO)
	$(RM) $(PREFIX)/bin/$(TARGET)
	$(RM) $(PREFIX)/include/fa_aacapi.h
	$(RM) $(PREFIX)/include/fa_inttypes.h
	$(RM) $(PREFIX)/share/man/man1/$(TARGET)*gz
