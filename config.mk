NAME=javalauncher

NIMVER=0.19.6

NIMOPTS=--passC:-Itarget/include --passC:-Itarget/include/darwin

preosx:copyinc

prewindows:copyinc

prelinux:copyinc

prepi:copyinc

copyinc:
	mkdir -p target
	CID=`docker create teras/jdkcross` && docker cp $$CID:/bundles/include `pwd`/target && docker rm $$CID

test:osx
	@echo " **** Test external"
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp java/javalauncher.json target/java/.javalauncher.json
	cp target/${NAME}.osx target/java/elaunch
	DEBUG=true target/java/elaunch -Dvalue4=third_val param1 -Dvalue5=value_of_four param2
	rm -rf target/java
	@echo " **** Test embeded"
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	mkdir -p target/java/classes/META-INF
	cp java/javalauncher.json target/java/classes/META-INF/LAUNCHER.INF
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp target/${NAME}.osx target/java/test
	DEBUG=true target/java/test -Dvalue4=third_val param1 -Dvalue5=value_of_four param2

