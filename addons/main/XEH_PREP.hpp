// testing, update fncs on the fly
#define PREP(var1) TRIPLES(ADDON,fnc,var1) = { call compile preProcessFileLineNumbers '\MAINPREFIX\PREFIX\SUBPREFIX\COMPONENT_F\functions\DOUBLES(fnc,var1).sqf' }

PREP(aiJump);
PREP(aiFlight);
PREP(cleanUp);
PREP(planFlight);
PREP(prepAircraft);
PREP(prepRamp);
PREP(setJumplight);
PREP(standUp);
