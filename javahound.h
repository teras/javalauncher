#ifndef JAVAHOUND_H
#define JAVAHOUND_H

char * find_java();

#define NO_JRE "It was not possible to locate a valid Java Runtime Environment (JRE) installed in your system. If indeed you don't have one, please go to http://www.java.com and download the latest JRE from there.\n\
\n\
If a valid JRE exists but it was unable to find, then you have to manually declare the top-level Java installation directory (known as JAVA_HOME), using the following command:\n\
  export JAVA_HOME=/path/to/java/installation\n\
or if you have csh/tcsh:\n\
  setenv JAVA_HOME /path/to/java/installation\n\
e.g.: export JAVA_HOME=/home/user/openjdk1.7\n\
\n"

#endif
