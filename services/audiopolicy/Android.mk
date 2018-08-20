LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    service/AudioPolicyService.cpp \
    service/AudioPolicyEffects.cpp

ifeq ($(USE_LEGACY_AUDIO_POLICY), 1)
LOCAL_SRC_FILES += \
    service/AudioPolicyInterfaceImplLegacy.cpp \
    service/AudioPolicyClientImplLegacy.cpp

    LOCAL_CFLAGS += -DUSE_LEGACY_AUDIO_POLICY
else
LOCAL_SRC_FILES += \
    service/AudioPolicyInterfaceImpl.cpp \
    service/AudioPolicyClientImpl.cpp
endif

LOCAL_C_INCLUDES := \
    frameworks/av/services/audioflinger \
    $(call include-path-for, audio-utils) \
    frameworks/av/services/audiopolicy/common/include \
    frameworks/av/services/audiopolicy/engine/interface \
    frameworks/av/services/audiopolicy/utilities

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    liblog \
    libbinder \
    libaudioclient \
    libhardware \
    libhardware_legacy \
    libserviceutility \
    libmedia_helper \
    libmediametrics \
    libeffectsconfig

ifneq ($(USE_LEGACY_AUDIO_POLICY), 1)
LOCAL_SHARED_LIBRARIES += \
    libaudiopolicymanager
endif

LOCAL_STATIC_LIBRARIES := \
    libaudiopolicycomponents

LOCAL_MULTILIB := $(AUDIOSERVER_MULTILIB)

LOCAL_MODULE:= libaudiopolicyservice

LOCAL_CFLAGS += -fvisibility=hidden
LOCAL_CFLAGS += -Wall

include $(BUILD_SHARED_LIBRARY)

ifneq ($(USE_LEGACY_AUDIO_POLICY), 1)

include $(CLEAR_VARS)

LOCAL_SRC_FILES:= managerdefault/AudioPolicyManager.cpp

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    liblog \
    libsoundtrigger

ifeq ($(USE_CONFIGURABLE_AUDIO_POLICY), 1)

ifneq ($(USE_XML_AUDIO_POLICY_CONF), 1)
$(error Configurable policy does not support legacy conf file)
endif #ifneq ($(USE_XML_AUDIO_POLICY_CONF), 1)

LOCAL_REQUIRED_MODULES := \
    parameter-framework.policy \
    audio_policy_criteria.conf \

LOCAL_C_INCLUDES += frameworks/av/services/audiopolicy/engineconfigurable/include
LOCAL_C_INCLUDES += frameworks/av/include

LOCAL_SHARED_LIBRARIES += libaudiopolicyengineconfigurable

else

LOCAL_SHARED_LIBRARIES += libaudiopolicyenginedefault

endif # ifeq ($(USE_CONFIGURABLE_AUDIO_POLICY), 1)

LOCAL_C_INCLUDES += \
    frameworks/av/services/audiopolicy/common/include \
    frameworks/av/services/audiopolicy/engine/interface \
    frameworks/av/services/audiopolicy/utilities

LOCAL_STATIC_LIBRARIES := \
    libaudiopolicycomponents

LOCAL_SHARED_LIBRARIES += libmedia_helper
LOCAL_SHARED_LIBRARIES += libmediametrics

ifeq ($(USE_XML_AUDIO_POLICY_CONF), 1)
LOCAL_SHARED_LIBRARIES += libicuuc libxml2

LOCAL_CFLAGS += -DUSE_XML_AUDIO_POLICY_CONF
endif #ifeq ($(USE_XML_AUDIO_POLICY_CONF), 1)

LOCAL_CFLAGS += -Wall

LOCAL_MULTILIB := $(AUDIOSERVER_MULTILIB)

LOCAL_MODULE:= libaudiopolicymanagerdefault

include $(BUILD_SHARED_LIBRARY)

ifneq ($(USE_CUSTOM_AUDIO_POLICY), 1)

include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    manager/AudioPolicyFactory.cpp

LOCAL_SHARED_LIBRARIES := \
    libaudiopolicymanagerdefault

LOCAL_STATIC_LIBRARIES := \
    libaudiopolicycomponents

LOCAL_C_INCLUDES += \
    frameworks/av/services/audiopolicy/common/include \
    frameworks/av/services/audiopolicy/engine/interface

LOCAL_CFLAGS := -Wall

LOCAL_MULTILIB := $(AUDIOSERVER_MULTILIB)

LOCAL_MODULE:= libaudiopolicymanager

include $(BUILD_SHARED_LIBRARY)

endif
endif

#######################################################################
# Recursive call sub-folder Android.mk
#
include $(call all-makefiles-under,$(LOCAL_PATH))
