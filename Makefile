#!/usr/bin/make

DESTDIR=
PREFIX=/usr/pkg

# The Bourne shell used must understand shell functions.
#SHELL=/bin/sh5

PROG=colorless
MAN=1
VERSION=108

BINDIR=bin
DBDIR=share/${PROG}
MANDIR=share/man/man${MAN}
TOOLPATH=${PREFIX}/${BINDIR}

RELEASE_ARTIFACTS= \
	Makefile \
	debian/changelog \

RELEASE_TAG=v${VERSION}

.PHONY: all
all: ${PROG}

${PROG}: ${PROG}.sh Makefile
	sed \
	    -e 's;@PREFIX@;${PREFIX};g' \
	    -e 's;@SHELL@;${SHELL};g' \
	    -e 's;@TOOLPATH@;${TOOLPATH};g' \
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

.PHONY: release-add add
release-add add:
	git add ${RELEASE_ARTIFACTS}

.PHONY: release-diff
release-diff diff:
	git diff --staged

.PHONY: release-commit commit
release-commit commit:
	git commit -m 'Release ${VERSION}'
	git tag ${RELEASE_TAG}

.PHONY: release-push push
release-push push:
	git push origin
	git push origin tag ${RELEASE_TAG}

release-archive tar.gz:
	git archive -o ${PROG}-${VERSION}.tar.gz \
	  --prefix=${PROG}-${VERSION}/ ${RELEASE_TAG}
