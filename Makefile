.PHONY: clean all desktop posix osx linux pi windows win32 win64 local install install-only run docker xclean

# needs to be defined before include
default:local

include config.mk

DEST:=~/Works/System/bin/arch

ifeq ($(DEBUG),true)
BASENIMOPTS=-d:VERSION=$(VERSION) --opt:size $(NIMOPTS)
else
BASENIMOPTS=-d:release -d:VERSION=$(VERSION) --opt:size $(NIMOPTS)
endif

ifeq ($(EXECNAME),)
EXECNAME:=$(NAME)
endif

ifeq ($(VERSION),)
VERSION:=0.1
endif

ifeq ($(COMPILER),)
COMPILER:=c
endif

ifeq ($(WINAPP),)
WINAPP:=console
endif

ifeq ($(ALLTARGETS),)
ALLTARGETS:=desktop pi
endif

ifneq ($(NIMBLE),)
NIMBLE:=nimble refresh ; nimble -y install $(NIMBLE);
DOCKERNAME:=teras/nimcross:${NAME}
else
DOCKERNAME:=teras/nimcross
endif

ifneq ($(NIMVER),)
NIMVER:=choosenim $(NIMVER);
endif

DOCOMPRESS:=$(shell echo $(COMPRESS) | tr A-Z a-z | cut -c1-1)

BUILDDEP:=$(wildcard *.nim *.c *.m Makefile config.mk)


initlocal:
	${NIMVER} ${NIMBLE}

local:target/${EXECNAME}

all:$(ALLTARGETS)

desktop:osx linux windows

posix:osx linux pi

pi:target/${EXECNAME}.aarch64.linux

osx:target/${EXECNAME}.osx

linux:target/${EXECNAME}.linux

windows:win32 win64

win32:target/${EXECNAME}.32.exe

win64:target/${EXECNAME}.64.exe

clean:xclean
	rm -rf target docker.tmp nimcache ${NAME} ${NAME}.exe

docker:
	@if [ "${NIMBLE}" != "" ] ; then \
	rm -rf docker.tmp && \
	mkdir docker.tmp && \
	echo >docker.tmp/Dockerfile "FROM teras/nimcross" && \
	echo >>docker.tmp/Dockerfile "RUN ${NIMBLE}" && \
	cd docker.tmp ; docker build -t ${DOCKERNAME} . && \
	rm -rf docker.tmp ; \
	fi

target/${EXECNAME}:${BUILDDEP}
	nim ${COMPILER} ${BASENIMOPTS} ${OSXNIMOPTS} ${NAME}
	mkdir -p target
	mv ${NAME} target/${EXECNAME}
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME} ; fi
	cp target/${EXECNAME} target/${EXECNAME}.osx

target/${EXECNAME}.osx:${BUILDDEP}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${OSXNIMOPTS} --os:macosx --passC:'-mmacosx-version-min=10.7 -gfull' --passL:'-mmacosx-version-min=10.7 -dead_strip' ${NAME} && x86_64-apple-darwin19-strip ${NAME}"
	mv ${NAME} target/${EXECNAME}.osx
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.osx ; fi

target/${EXECNAME}.linux:${BUILDDEP}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${LINUXNIMOPTS} ${NAME} && strip ${NAME}"
	mv ${NAME} target/${EXECNAME}.linux
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.linux ; fi

target/${EXECNAME}.aarch64.linux:${BUILDDEP}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${PINIMOPTS} --cpu:arm --os:linux ${NAME} && arm-linux-gnueabi-strip ${NAME}"
	mv ${NAME} target/${EXECNAME}.arm.linux
	#if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.arm.linux ; fi
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${PINIMOPTS} --cpu:arm64 --os:linux ${NAME} && aarch64-linux-gnu-strip ${NAME}"
	mv ${NAME} target/${EXECNAME}.aarch64.linux
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.aarch64.linux ; fi

target/${EXECNAME}.32.exe:${BUILDDEP}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${WINDOWSNIMOPTS} -d:mingw --cpu:i386  --app:${WINAPP} ${NAME} && i686-w64-mingw32-strip   ${NAME}.exe"
	mv ${NAME}.exe target/${EXECNAME}.32.exe
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.32.exe ; fi

target/${EXECNAME}.64.exe:${BUILDDEP}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app ${DOCKERNAME} bash -c "${NIMVER} nim ${COMPILER} ${BASENIMOPTS} ${WINDOWSNIMOPTS} -d:mingw --cpu:amd64 --app:${WINAPP} ${NAME} && x86_64-w64-mingw32-strip ${NAME}.exe"
	mv ${NAME}.exe target/${EXECNAME}.64.exe
	if [ "$(DOCOMPRESS)" = "t" ] ; then upx --best target/${EXECNAME}.64.exe ; fi


install: | all install-only

install-only:
	if [ -f target/${EXECNAME}.osx         ] ; then mkdir -p ${DEST}/darwin-x86_64/ && cp target/${EXECNAME}.osx ${DEST}/darwin-x86_64/${EXECNAME} ; fi
	if [ -f target/${EXECNAME}.linux       ] ; then mkdir -p ${DEST}/linux-x86_64/  && cp target/${EXECNAME}.linux ${DEST}/linux-x86_64/${EXECNAME} ; fi
	if [ -f target/${EXECNAME}.arm.linux   ] ; then mkdir -p ${DEST}/linux-arm      && cp target/${EXECNAME}.arm.linux ${DEST}/linux-arm/${EXECNAME} ; fi
	if [ -f target/${EXECNAME}.aarch64.linux ] ; then mkdir -p ${DEST}/linux-aarch64    && cp target/${EXECNAME}.aarch64.linux ${DEST}/linux-aarch64/${EXECNAME} ; fi
	if [ -f target/${EXECNAME}.64.exe      ] ; then mkdir -p ${DEST}/windows-x86_64 && cp target/${EXECNAME}.64.exe ${DEST}/windows-x86_64/${EXECNAME}.exe ; fi
	if [ -f target/${EXECNAME}.32.exe      ] ; then mkdir -p ${DEST}/windows-i686   && cp target/${EXECNAME}.32.exe ${DEST}/windows-i686/${EXECNAME}.exe ; fi

run:local
	./target/${EXECNAME} ${RUNARGS}
