# ###################################################################

# 
#  Copyright (C) 2000-2006 Erik Edelmann <Erik.Edelmann@iki.fi>
#
#     This program is free software;  you  can  redistribute  it
#     and/or modify it under the terms of the GNU General Public
#     License version 2 as published  by  the  Free  Software
#     Foundation.
#
#     This program is distributed in the hope that  it  will  be
#     useful, but WITHOUT ANY WARRANTY; without even the implied
#     warranty of MERCHANTABILITY or FITNESS  FOR  A  PARTICULAR
#     PURPOSE.   See  the GNU General  Public License for more
#     details.
#
#     You should have received a copy of the GNU General  Public
#     License along with this program; if not, write to the Free
#     Software Foundation, Inc., 59  Temple  Place,  Suite  330,
#     Boston, MA 02111-1307  USA
# 

# ###################################################################


PROG = makedepf90

VERSION = 2.8.9

CC		?= gcc
CFLAGS		?= -g -O2
CPPFLAGS	+= -DVERSION=\"$(VERSION)\"

LEX		?= flex
LFLAGS		?= -i -B 

YACC		?= bison
YFLAGS		?= -y

# Where to install stuff
PREFIX		?= /usr/local
MANDIR		?= ${PREFIX}/man

bindir		= ${PREFIX}/bin

# How to install stuff
INSTALL		?= /usr/bin/install -c
INSTALL_PROGRAM ?= ${INSTALL}
INSTALL_DATA	?= ${INSTALL} -m 644

SRC_H = errormesg.h finddep.h global.h list.h macro.h modfile_name.h utils.h \
	xmalloc.h
SRC_C = errormesg.c list.c macro.c main.c modfile_name.c utils.c xmalloc.c 
SRC_Y = find_dep.y
SRC_L = lexer.l
SRC = $(SRC_H) $(SRC_C) $(SRC_Y) $(SRC_L)

EXTRA_SRC = strcasecmp.c

DISTFILES = $(SRC) lexer.c find_dep.h find_dep.c Makefile.in configure.in \
            configure makedepf90.1 COPYING NEWS README Makefile.def .depend \
	    $(EXTRA_SRC) install-sh config.h.in config.h

OBJ = ${SRC_C:.c=.o} $(SRC_Y:.y=.o) $(SRC_L:.l=.o)
LIBOBJS = 

.SUFFIXES:
.SUFFIXES: .c .o .l .y .h

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $<

.l.c:
	$(LEX) $(LFLAGS) -t $< > $@

.y.c:
	$(YACC) -d $(YFLAGS) $<
	mv y.tab.c $@

.y.h: 
	$(YACC) -d $(YFLAGS) $<
	mv y.tab.h $@

$(PROG): $(OBJ)
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS) $(OBJ) $(LIBOBJS) $(LIBS)

include .depend

clean:
	rm -f *.o $(PROG) gmon.out gmon.sum 
	find . -name 'core' -exec rm {} \;

realclean: clean
	rm -f lexer.c find_dep.[ch] .depend configure tags config.cache config.log config.status 

install: $(PROG)  makedepf90.1
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) $(PROG) $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(mandir)/man1
	$(INSTALL_DATA) makedepf90.1 $(DESTDIR)$(mandir)/man1

install-strip: $(PROG) makedepf90.1
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) -s $(PROG) $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(mandir)/man1
	$(INSTALL_DATA) makedepf90.1 $(DESTDIR)$(mandir)/man1

test: $(PROG)
	(cd testdir/test1; bash test1.sh)
	(cd testdir/test2; bash test2.sh)
	(cd testdir/bayes; bash bayes.sh)
	(cd testdir/bayes2; bash test.sh)
	(cd testdir/bayes3; bash bayes3.sh)
	(cd testdir/bayes4; bash bayes4.sh)
	(cd testdir/bayes_coco; bash bayes_coco.sh)
	(cd testdir/ranlib; bash ranlib.sh)
	(cd testdir/convert; bash convert.sh)
	(cd testdir/stdtype; bash stdtype.sh)
	(cd testdir/f90ppr; bash f90ppr.sh)
	(cd testdir/f90tops; bash f90tops.sh)
	(cd testdir/e; bash e.sh)
	(cd testdir/err; bash err.sh)
	(cd testdir/recur; bash recur.sh)
	(cd testdir/eol; bash eol.sh)
	(cd testdir/optI; bash optI.sh)
	(cd testdir/glurr; bash glurr.sh)

depend .depend: lexer.c find_dep.c find_dep.h
	$(CC) -MM *.c > .depend

lexer.c: lexer.l
find_dep.h find_dep.c: find_dep.y

configure: configure.in
	autoconf

Makefile: Makefile.in configure
	./configure --prefix=${PREFIX}

Makefile.def: Makefile
	cp Makefile Makefile.def

dist: $(DISTFILES)
	if [ -d makedepf90-$(VERSION) -o -f makedepf90-$(VERSION) ]; then \
		rm -rf makedepf90-$(VERSION); \
	fi
	mkdir makedepf90-$(VERSION)
	cp $(DISTFILES) makedepf90-$(VERSION)
	tar zcvf makedepf90-$(VERSION).tar.gz makedepf90-$(VERSION)
	rm -rf makedepf90-$(VERSION)

wcl:
	wc -l $(SRC) $(EXTRA_SRC)
