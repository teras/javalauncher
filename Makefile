.PHONY: clean all osx linux windows test

NAME=javalauncher

NIMFILES = $(wildcard *.nim *.c)

all:osx linux windows

clean:
	rm -rf target

osx:target/${NAME}.osx

linux:target/${NAME}.linux

windows:target/${NAME}.64.exe

target/${NAME}.osx:${NIMFILES}
	mkdir -p target
	nim c -d:release --opt:size ${NAME}
	strip ${NAME}
	mv ${NAME} target/${NAME}.osx

target/${NAME}.linux:${NIMFILES}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c -d:release --opt:size ${NAME} && strip ${NAME}"
	mv ${NAME} target/${NAME}.linux

target/${NAME}.64.exe:${NIMFILES}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c -d:release --opt:size -d:mingw --cpu:i386  ${NAME} && i686-w64-mingw32-strip   ${NAME}.exe"
	mv ${NAME}.exe target/${NAME}.32.exe
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c -d:release --opt:size -d:mingw --cpu:amd64 ${NAME} && x86_64-w64-mingw32-strip ${NAME}.exe"
	mv ${NAME}.exe target/${NAME}.64.exe


test:osx
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	mkdir -p target/java/classes/META-INF
	cp java/LAUNCHER.INF target/java/classes/META-INF
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp target/${NAME}.osx target/java/test
	target/java/test param1 param2
