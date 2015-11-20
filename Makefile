JAR ?= test/test.jar
NAME=launcher

COPTS = -O2 -Wall

CFILES = main.c utils.c javahound.c
HFILES = utils.h javahound.h
SOURCE = ${CFILES} ${HFILES}

MAKE ?= make
CC ?= gcc
STRIP ?= strip

BUILD=build
DIST=dist
BINFILE=${BUILD}/${NAME}.${TARGET}
EXEFILE=${DIST}/${NAME}

TARGET = ${shell uname -s|tr [A-Z] [a-z]}

compile:${EXEFILE}

clean:
	rm -rf ${BUILD} ${DIST}

${BUILD}:
	mkdir -p ${BUILD}

${DIST}:
	mkdir -p ${DIST}

${BUILD}/${NAME}.linux:${BUILD}/${NAME}.linux64 ${BUILD}/${NAME}.linux32

${BUILD}/${NAME}.linux64:${BUILD} ${SOURCE}
	${CC} ${COPTS} -m64 -o ${BINFILE}64 ${CFILES}
	strip -s ${BINFILE}64

${BUILD}/${NAME}.linux32:${BUILD} ${SOURCE}
	${CC} ${COPTS} -m32 -o ${BINFILE}32 ${CFILES}
	strip -s ${BINFILE}32


${BUILD}/${NAME}.darwin:${BUILD} ${SOURCE}
	${CC} ${COPTS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${BINFILE} ${CFILES}
	${STRIP} ${BINFILE}


${EXEFILE}:${DIST} ${BINFILE}
	cat ${BINFILE} ${JAR} >${EXEFILE}
	chmod a+x ${EXEFILE}

