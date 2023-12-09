NAME=javalauncher

NIMOPTS:=--passC:-Iinclude

MACNIMOPTS:=--passC:-Iinclude/darwin

LINUXNIMOPTS:=--passC:-Iinclude/linux

WINDOWSNIMOPTS:=--passC:-Iinclude/windows

PINIMOPTS:=--passC:-Iinclude/linux

ALLTARGETS=mac linux arm

NIMBLE=nim_miniz

#COMPRESS=true

WINAPP:=gui

push:
	docker-compose build
	docker-compose push

test:local
	@set -e
	@echo
	@echo " **** Test external"
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp java/javalauncher.json target/java/.javalauncher.json
	cp target/${NAME}.osx target/java/elaunch
	JAVALAUNCHER_DEBUG=true target/java/elaunch -Dvalue4=third_val param1 -Dvalue5=value_of_four param2
	@echo " **** END OF TEST external"
	@rm -rf target/java
	@echo
	@echo " **** Test embeded"
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	mkdir -p target/java/classes/META-INF
	cp java/javalauncher.json target/java/classes/META-INF/LAUNCHER.INF
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp target/${NAME}.osx target/java/test
	JAVALAUNCHER_DEBUG=true target/java/test -Dvalue4=third_val param1 -Dvalue5=value_of_four param2 --exception
	@echo " **** END OF TEST embeded"

