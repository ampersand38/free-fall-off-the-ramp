// COMPONENT should be defined in the script_component.hpp and included BEFORE this hpp

#define MAINPREFIX z
#define PREFIX ffr

#include "script_version.hpp"

#define VERSION MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

#define FFR_TAG FFR

// MINIMAL required version for the Mod. Components can specify others..
#define REQUIRED_VERSION 2.18

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(ffr - COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(ffr - COMPONENT)
#endif
