test_local_path := $(call my-dir)
include /Users/shawn/MobileCPlusPlusCrossPlatform/libwebsockets/libwebsockets/Android.mk
LOCAL_PATH := $(test_local_path)

include $(CLEAR_VARS)
LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -lm -lz -ljnigraphics -llog
LOCAL_MODULE := mobilecpp
LOCAL_SRC_FILES := mobilecpp.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../C++/
LOCAL_SHARED_LIBRARIES := libwebsockets
include $(BUILD_SHARED_LIBRARY)
