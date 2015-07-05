export GO_EASY_ON_ME = 1

export THEOS=/var/theos

ARCHS = armv7 arm64
TARGET = iphone:clang::8.1
SDKVERSION = 8.1

include /var/theos/makefiles/common.mk

TWEAK_NAME = CryptoNotes
CryptoNotes_FILES = CryptoNotes.xm NSString+AESCrypt.m NSData+AESCrypt.m
CryptoNotes_FRAMEWORKS = UIKit Foundation CoreFoundation
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include /var/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
