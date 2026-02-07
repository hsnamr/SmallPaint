# GNUmakefile for SmallPaint (Linux/GNUstep)
#
# Simple pixel editor similar to Windows Paint. Uses SmallStepLib for app
# lifecycle, menus, window style, and file dialogs. No extra libraries.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallPaint

SmallPaint_OBJC_FILES = \
	main.m \
	App/AppDelegate.m \
	Canvas/CanvasView.m \
	UI/PaintWindow.m

SmallPaint_HEADER_FILES = \
	App/AppDelegate.h \
	Canvas/CanvasView.h \
	UI/PaintWindow.h

SmallPaint_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-ICanvas \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

# SmallStep framework (from SmallStepLib)
SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallPaint_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallPaint_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallPaint_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallPaint_TOOL_LIBS = -lSmallStep -lobjc

include $(GNUSTEP_MAKEFILES)/application.make
