#!/usr/bin/make

DESTDIR=
PREFIX=/usr/pkg

# The Bourne shell used must understand shell functions.
BIN_SH=/bin/sh
#BIN_SH=/bin/sh5

PROG=colorless
MAN=1
VERSION=106

BINDIR=bin
DBDIR=share/${PROG}
MANDIR=share/man/man${MAN}

.PHONY: all
all: ${PROG}

${PROG}: ${PROG}.sh Makefile
	sed \
	    -e 's;@BIN_SH@;${BIN_SH};g' \
	    -e 's;@PREFIX@;${PREFIX};g' \
	    -e 's;@VERSION@;${VERSION};g' \
	    < $< > $@
	chmod a+rx $@

.PHONY: install
install: ${PROG} ${PROG}.man
	install -m 755 ${PROG} ${DESTDIR}${PREFIX}/${BINDIR}/${PROG}
	install -m 644 ${PROG}.man ${DESTDIR}${PREFIX}/${MANDIR}/${PROG}.${MAN}
	install -m 755 -d ${DESTDIR}${PREFIX}/${DBDIR}
	install -m 644 ${PROG}.conf ${DESTDIR}${PREFIX}/${DBDIR}/${PROG}.conf

clean:
	rm -f ${PROG}
