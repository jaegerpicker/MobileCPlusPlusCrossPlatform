#import "jni.h"
#import <string.h>
#import <stdlib.h>
#import <android/log.h>
#import <pthread.h>
#import <iostream>
#import <assert.h>
#import <stdio.h>
#import "easywsclient.hpp"
#define LOG_TAG "SlingShot"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

extern "C" {
    JNIEXPORT void JNICALL Java_com_codeart_mobilecplusplus_MainActivity_startWSComms(JNIEnv *env, jobject obj);
    JNIEXPORT void JNICALL Java_com_codeart_mobilecplusplus_MainActivity_sendMessage(JNIEnv *env, jobject obj, jstring message);
    JNIEXPORT jstring JNICALL Java_com_codeart_mobilecplusplus_MainActivity_getNewChat(JNIEnv * env, jobject obj);
};

std::string message;
std::string *sendBuf;
static JavaVM *vm = NULL;
static jclass mainAct = NULL;
static jmethodID appendMessage = NULL;
bool newmessage = false;
bool newchat = false;


JNIEnv * getCurrentJNIEnv() {
    JNIEnv *env = NULL;
    int state = vm->GetEnv((void**)&env, JNI_VERSION_1_6);
    LOGE("state: %i", state);
    if(state == JNI_EDETACHED)
    {
    	LOGE("We aren't attached to a Java thread, so we're going to attach now\n");

        if (vm->AttachCurrentThread((JNIEnv **)&env, NULL) != 0)
        {
            LOGE("Failed to attach\n");
            return NULL;
        }
    }
    else if(state == JNI_OK)
    {
    	// NOOP
    	LOGE("JNI_OK == 0");
    }
    else if(state == JNI_EVERSION)
    {
    	LOGE("Version was not supported\n");
    	return NULL;
    }
    return env;
}

void handle_message(const std::string & message)
{
    __android_log_print(ANDROID_LOG_ERROR, "mobilecpp", ">>> %s\n", message.c_str());
    ::message = message;
    newchat = true;
    JNIEnv * env = getCurrentJNIEnv();
    if(env == NULL) {
        LOGE("env is null");
        return;
    }
    //vm->AttachCurrentThread(&env, NULL);
    //mainAct = env->FindClass("com/codeart/mobilecplusplus/MainActivity");
    //jthrowable exc;
    //exc = env->ExceptionOccurred();
    //     if (exc) {
    //         jclass newExcCls;
    //         env->ExceptionDescribe();
    //         env->ExceptionClear();

    //     }
    //if(mainAct == NULL) {
    //    LOGE("MainAct is null");
    //    return;
    //}
    jstring mess = env->NewStringUTF(message.c_str());

    //jclass iClass = env->GetObjectClass();
    //LOGE(mess);
    LOGE("%i", appendMessage);

    //jstring jmess = env->NewGlobalRef(*mess);
    //env->CallVoidMethod(mainAct, appendMessage, mess);
    env->DeleteLocalRef(mess);
    //vm->DetachCurrentThread();
}

void* startWS(void*) {
    using easywsclient::WebSocket;
    WebSocket::pointer ws = WebSocket::from_url("ws://192.168.0.8:8765/chatsocket");
    //assert(ws);
    //ws->send("goodbye");
    //ws->send("hello");
    while (message != "world") {
        if(newmessage){
            ws->send(*sendBuf);
            sendBuf->assign("0");
            newmessage = false;
        }
        ws->poll();
        ws->dispatch(handle_message);
    }
}

jstring
Java_com_codeart_mobilecplusplus_MainActivity_getNewChat(JNIEnv * env, jobject obj) {
    if(newchat) {
        jstring ret = env->NewStringUTF(message.c_str());
        newchat = false;
        return ret;
    } else {
        jstring ret = env->NewStringUTF("0");
        return ret;
    }

}

void
Java_com_codeart_mobilecplusplus_MainActivity_startWSComms(JNIEnv * env, jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "mobilecpp", "startWSComms");
    pthread_t t1;
    pthread_create(&t1, NULL, &startWS, NULL);
    sendBuf = new std::string("0");

    //printf("startWSComms");
}



void
Java_com_codeart_mobilecplusplus_MainActivity_sendMessage(JNIEnv * env, jobject obj, jstring message) {
    const char *s = env->GetStringUTFChars(message, NULL);
    __android_log_print(ANDROID_LOG_ERROR, "mobilecpp", "sendMessage: %s", s);
    sendBuf->assign(s);
    newmessage = true;
    env->ReleaseStringUTFChars(message, s);
    //printf("sendMessage");
}

jint JNI_OnLoad(JavaVM *vm_, void *reserved)
{
	// Keep track of our VM globally
	vm = vm_;


	JNIEnv *env = NULL;

	// Get the environment which is Thread Local
	int state = vm->GetEnv((void**)&env, JNI_VERSION_1_6);
	if(state == JNI_EDETACHED) {
	    LOGE("We aren't attached to a Java thread, so we're going to attach now\n");
	    if(vm->AttachCurrentThread((JNIEnv **)&env, NULL) != 0){
	        LOGE("Failed ot Attach\n");
	    } else {
	        //vm = reinterpret_cast<JavaVM>(env->NewGlobalRef(vm));
	    }
	}
	//jclass localClass = env->FindClass("MyClass");
    //jclass globalClass = (env->NewGlobalRef(localClass));
	jclass mainActs = env->FindClass("com/codeart/mobilecplusplus/MainActivity");
	mainAct = reinterpret_cast<jclass>(env->NewGlobalRef(mainActs));
	if(mainAct != NULL) {
        appendMessage = env->GetMethodID(mainAct, "displayMessage", "(Ljava/lang/String;)V");
        if(appendMessage != NULL) {
            LOGE("Found displayMessage");
        }
	} else {
	    LOGE("Failed to find main activity");
	}
	return JNI_VERSION_1_6;
}




