#include "script_component.hpp"

["ffr_main_prepRamp", { call ffr_main_fnc_prepRamp; }] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

{
    if (isClass (configFile >> "CfgVehicles" >> _x)) then {
        [_x, "init", { call ffr_main_fnc_prepAircraft; }, true] call CBA_fnc_addClassEventHandler;
    };
} forEach ["USAF_C17", "USAF_C130J", "RHS_C130J", "VTOL_01_infantry_base_F", "VTOL_02_infantry_base_F"];
