#include <jni.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#define LIBTYPE HINSTANCE
#define OPENLIB(libname) LoadLibrary(TEXT(libname))
#define LIBFUNC(lib, fn) GetProcAddress((lib), (fn))
#else
#include <dlfcn.h>
#define LIBTYPE void*
#define OPENLIB(libname) dlopen((libname), RTLD_LAZY)
#define LIBFUNC(lib, fn) dlsym((lib), (fn))
#endif

typedef int (JNICALL *JLI_Launch_f)(int argc, char ** argv,
                                    int jargc, const char** jargv,
                                    int appclassc, const char** appclassv,
                                    const char* fullversion,
                                    const char* dotversion,
                                    const char* pname,
                                    const char* lname,
                                    jboolean javaargs,
                                    jboolean cpwildcard,
                                    jboolean javaw,
                                    jint ergo);

typedef jint (*JNI_CreateJavaVM_f)(JavaVM **, void **, void *);

int launchjli(char *jlilib, int argc, char** argv) {
	 LIBTYPE libJLI = OPENLIB(jlilib);
	if (!libJLI)
	{
		printf("Unable to load library %s\n", __FILE__,jlilib);
		return 1;
	}
	JLI_Launch_f JLI_Launch = LIBFUNC(libJLI, "JLI_Launch");
	if (!JLI_Launch)
	{
		printf("Unable to get symbol JLI_Launch from library %s\n", jlilib);
		return 1;
	}
	int result = JLI_Launch(argc, argv,
						0, NULL,
						0, NULL,
						"",
						"",
						NULL,
						NULL,
						JNI_FALSE,
						JNI_FALSE,
						JNI_FALSE,
						0);
	return result;
}

int launchjvmExec(char *jvmlib, char **jvmopts, int c_jvmopts, char **args, int c_args, char *mainclass) {
	JavaVM *vm;
	JNIEnv *env;
	JavaVMInitArgs vm_args;
	JavaVMOption options[c_jvmopts];

	memset(&vm_args, 0, sizeof(vm_args));
	vm_args.version = JNI_VERSION_1_8;
	vm_args.ignoreUnrecognized = JNI_TRUE;

	for (int i = 0; i < c_jvmopts; i++)
		options[i].optionString = jvmopts[i];
	vm_args.options = options;
	vm_args.nOptions = c_jvmopts;

	LIBTYPE lib_handle = OPENLIB(jvmlib);
	if (!lib_handle)
	{
		printf("Unable to load library %s\n", jvmlib);
		return 1;
	}
	JNI_CreateJavaVM_f JNI_CreateJavaVM = LIBFUNC(lib_handle, "JNI_CreateJavaVM");
	if (!JNI_CreateJavaVM)
	{
		printf("Unable to get symbol JNI_CreateJavaVM from library %s\n", jvmlib);
		return 1;
	}

	jint res = JNI_CreateJavaVM(&vm, (void **)&env, &vm_args);
	if (res != JNI_OK)
	{
		printf("Failed to create Java VM\n");
		return res;
	}

	jclass cls = (*env)->FindClass(env, mainclass);
	if (cls == NULL)
	{
		printf("Failed to find %s class\n", mainclass);
		return 1;
	}

	jmethodID mid = (*env)->GetStaticMethodID(env, cls, "main", "([Ljava/lang/String;)V");
	if (mid == NULL)
	{
		printf("Failed to find main function in class %s\n", mainclass);
		return 2;
	}

	jobjectArray main_args = (*env)->NewObjectArray(env, c_args, (*env)->FindClass(env, "java/lang/String"), NULL);
	for(int i = 0 ; i < c_args ; i++)
		(*env)->SetObjectArrayElement(env, main_args, i, (*env)->NewStringUTF(env, args[i]));

	int result = 0;
	(*env)->CallStaticVoidMethod(env, cls, mid, main_args);
	if ((*env)->ExceptionOccurred(env)) { // check if an exception occurred
	    (*env)->ExceptionDescribe(env); // print the stack trace
		result = -1;
	}

	(*vm)->DestroyJavaVM(vm);
	return result;
}

int launchjvm(char *jvmlib, char **jvmopts, int c_jvmopts, char **args, int c_args, char *mainclass)
{
	// NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	launchjvmExec(jvmlib, jvmopts, c_jvmopts, args, c_args, mainclass);
	// [pool drain];
}
