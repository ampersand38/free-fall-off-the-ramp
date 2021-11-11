ffr_testing = true;

ffr_main_fnc_cleanup = compile preProcessFileLineNumbers "free_fall_off_the_ramp\functions\fnc_cleanup.sqf";
ffr_main_fnc_planFlight = compile preProcessFileLineNumbers "free_fall_off_the_ramp\functions\fnc_planFlight.sqf";
ffr_main_fnc_prepAircraft = compile preProcessFileLineNumbers "free_fall_off_the_ramp\functions\fnc_prepAircraft.sqf";
ffr_main_fnc_prepRamp = compile preProcessFileLineNumbers "free_fall_off_the_ramp\functions\fnc_prepRamp.sqf";

["ffr_main_prepRamp", { call ffr_main_fnc_prepRamp; }] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

{
    if (isClass (configFile >> "CfgVehicles" >> _x)) then {
        [_x, "init", { call ffr_main_fnc_prepAircraft; }, true, [], true] call CBA_fnc_addClassEventHandler;
    };
} forEach ["USAF_C17", "USAF_C130J", "RHS_C130J", "VTOL_01_infantry_base_F", "VTOL_02_infantry_base_F"];
