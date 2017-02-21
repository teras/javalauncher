NAME=launcher

JAVA_LOC=test
JAVA_PACK=test
JAVA_BASE=test


CFILES = $(wildcard *.c utils/*.c lib/*.c core/*.c)
HFILES = $(wildcard *.h utils/*.h lib/*.h core/*h)
SOURCE = ${CFILES} ${HFILES}

SIZEOPT=-Os
#SIZEOPT=-Oz

CFLAGS=-DJSMN_PARENT_LINKS -lz ${SIZEOPT} -I. -Iutils -Ilib -Icore -Wall

MAKE ?= make
CC ?= gcc
STRIP ?= strip

DIST=dist
BINBASE=${DIST}/${NAME}
BINFILE=${BINBASE}.${TARGET}
TESTFILE=${DIST}/${NAME}

JAVA_BUILD = $(JAVA_LOC)/build
JAVA_FILE = $(JAVA_LOC)/$(JAVA_BASE).java
JAVA_CLASS = $(JAVA_BUILD)/$(JAVA_PACK)/$(JAVA_BASE).class
JAVA_JAR = $(JAVA_LOC)/$(JAVA_BASE).jar

TARGET = ${shell uname -s|tr [A-Z] [a-z]}

.PHONY: compile
compile:${BINFILE}

.PHONY: test
test:${TESTFILE}
	${TESTFILE} one δύο

.PHONY: test32
test32:${TESTFILE}32
	${TESTFILE}32 one δύο

.PHONY: testdebug
testdebug:${TESTFILE}
	LAUNCHER_DEBUG=true ${TESTFILE} one δύο

.PHONY: clean
clean:
	rm -rf ${DIST}
	rm -rf $(JAVA_BUILD) $(JAVA_JAR)

.PHONY: jar
jar: ${JAVA_JAR}

${DIST}:
	mkdir -p ${DIST}

${BINBASE}.linux:${DIST} ${SOURCE} ${BINFILE}32
	${CC} ${CFILES} -o ${BINFILE} -m64 ${CFLAGS}
	strip -s ${BINFILE}

${BINBASE}.linux32:${DIST} ${SOURCE}
	${CC} ${CFILES} -o ${BINFILE}32 -m32 ${CFLAGS}
	strip -s ${BINFILE}32

${BINBASE}.darwin:${DIST} ${SOURCE}
	${CC} ${CFLAGS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${BINFILE} ${CFILES}
	${STRIP} ${BINFILE}

${TESTFILE}:${DIST} ${BINFILE} ${JAVA_JAR}
	cat ${BINFILE} ${JAVA_JAR} >${TESTFILE}
	chmod a+x ${TESTFILE}

${TESTFILE}32:${DIST} ${BINFILE}32 ${JAVA_JAR}
	cat ${BINFILE}32 ${JAVA_JAR} >${TESTFILE}32
	chmod a+x ${TESTFILE}32

${JAVA_CLASS}:${JAVA_FILE}
	mkdir -p ${JAVA_BUILD}
	javac ${JAVA_FILE} -d ${JAVA_BUILD}
	mkdir -p ${JAVA_BUILD}/META-INF
	cp ${JAVA_LOC}/LAUNCHER.INF ${JAVA_BUILD}/META-INF

${JAVA_JAR}:${JAVA_CLASS}
	jar cmf $(JAVA_LOC)/MANIFEST.MF $(JAVA_JAR)  -C $(JAVA_BUILD) .
