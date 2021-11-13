#include "script_component.hpp"
/*
Author: Ampers
Creates static dummy

* Arguments:
* 0: Aircraft <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft] call ffr_main_fnc_prepRamp = {}
*/

params ["_aircraft"];

[_aircraft] call ffr_main_fnc_cleanup;
// create static dummy
private _pos = getPosASL _aircraft;
_pos params ["_x", "_y", "_z"];
_helper = "Land_InvisibleBarrier_F" createVehicle [0, 0, 0];
_aircraft setVariable ["ffr_helper", _helper, true];
_helper setPosASL [_x, _y, 0];
_helper setDir getDir _aircraft;
_dummy = createVehicle [typeOf _aircraft, _pos, [], 0, "FLY"];
_dummy allowDamage false;
if (isMultiplayer) then {
    _dummy hideObjectGlobal true;
} else {
    _dummy hideObject true;
};
_dummy attachTo [_helper, [0, -2000, _z]];
_aircraft setVariable ["ffr_dummy", _dummy, true];
_dummy setVariable ["ffr_aircraft", _aircraft, true];

// Sync animations from aircraft to dummy
private _animInfo = [];
private _jumplightPos = [];
if (_aircraft isKindOf "VTOL_01_infantry_base_F") then {
    _animInfo = ["door", ["Door_1_source"]]; // ["_animType", "_anims"]
    _jumplightPos = [0, -7.5, -3];
};
if (_aircraft isKindOf "USAF_C17") then {
    _animInfo = ["", ["back_ramp_switch", "back_ramp", "back_ramp_st", "back_ramp_p", "back_ramp_p_2", "back_ramp_door_main"]];
    _jumplightPos = [0, -3, -2];
};
if (_aircraft isKindOf "USAF_C130J") then {
    _animInfo = ["source", ["ramp_bottom", "ramp_top"]];
    _jumplightPos = [0, -3, -2];
};
if (_aircraft isKindOf "RHS_C130J") then {
    _animInfo = ["source", ["ramp", "jumplight"]];
    _jumplightPos = [0, -3, -2];
};
private _pfID = [{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_dummy", "_animInfo"];
    _animInfo params ["_animType", "_anims"];
    {
        switch (_animType) do {
            case (""): {
                _dummy animate [_x, _aircraft animationPhase _x];
            };
            case ("source"): {
                _dummy animateSource [_x, _aircraft animationSourcePhase _x];
            };
            case ("door"): {
                _dummy animateDoor [_x, _aircraft animationSourcePhase _x];
            };
        };
    } forEach _anims;
    if (!alive _aircraft || {isNull _dummy}) exitWith {
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
}, 0.5, [_aircraft, _dummy, _animInfo]] call CBA_fnc_addPerFrameHandler;

private _fnc_createJumplight = {
    private _jumplight = "#lightreflector" createVehicle [0,0,0];
    _jumplight setLightIntensity 0;
    _jumplight setLightColor [1, 0, 0];
    _jumplight setLightConePars [360, 360, 1];
    _jumplight setLightAttenuation [2, 4, 4, 0, 9, 10];
    _jumplight
};

private _jumplight = call _fnc_createJumplight;
_jumplight attachTo [_dummy, _jumplightPos];
_aircraft setVariable ["ffr_jumplight_dummy", _jumplight, true];
_dummy setVariable ["ffr_jumplight_dummy", _jumplight, true];

_jumplight = call _fnc_createJumplight;
_jumplight attachTo [_aircraft, _jumplightPos];
_aircraft setVariable ["ffr_jumplight", _jumplight, true];
_dummy setVariable ["ffr_jumplight", _jumplight, true];

["ffr_main_addJumplightActions", [_dummy]] call CBA_fnc_globalEvent;
["ffr_main_addJumplightActions", [_aircraft]] call CBA_fnc_globalEvent;

_aircraft addEventHandler ["Deleted", { call ffr_main_fnc_cleanup }];
_aircraft addEventHandler ["Killed", { call ffr_main_fnc_cleanup }];
