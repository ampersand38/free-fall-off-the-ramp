//#include "script_component.hpp"
/*
Author: Ampers
Creates static dummy

* Arguments:
* 0: Aircraft <OBJECT>
* 1: Open Ramp <BOOLEAN>
*
* Return Value:
* -

* Example:
* [_aircraft] call ffr_main_fnc_prepRamp = {
*/

params ["_aircraft", ["_openRamp", false]];

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
_dummy lockDriver true;

if (isMultiplayer) then {
    _dummy hideObjectGlobal true;
} else {
    _dummy hideObject true;
};
_dummy attachTo [_helper, [0, -2000, _z]];
_aircraft setVariable ["ffr_dummy", _dummy, true];
_dummy setVariable ["ffr_aircraft", _aircraft, true];

["ffr_main_prepDummy", _dummy] call CBA_fnc_globalEvent;

// Open ramp
private _jumpInfo = _aircraft getVariable "ffr_jumpInfo";
_jumpInfo params ["_animInfo", "_jumplightPos"];
_animInfo params ["_animType", "_anims", ["_animPhase", 1]];
{
    switch (_animType) do {
        case (""): {
            _aircraft animate [_x, _animPhase];
        };
        case ("source"): {
            _aircraft animateSource [_x, _animPhase];
        };
        case ("door"): {
            _aircraft animateDoor [_x, _animPhase];
        };
    };
} forEach _anims;

// Sync animations from aircraft to dummy
private _pfID = [{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_dummy", "_animInfo"];
    _animInfo params ["_animType", "_anims"];
    {
        [_dummy, [_x, 1]] call _fnc_animateRamp;
    } forEach _animations;
    {
        switch (_animType) do {
            case (""): {
                _dummy animate [_x, _aircraft animationPhase _x, true];
            };
            case ("source"): {
                _dummy animateSource [_x, _aircraft animationSourcePhase _x, true];
            };
            case ("door"): {
                _dummy animateDoor [_x, _aircraft animationSourcePhase _x, true];
            };
        };
    } forEach _anims;
    if (!alive _aircraft || {isNull _dummy}) exitWith {
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
}, 0.1, [_aircraft, _dummy, _animInfo]] call CBA_fnc_addPerFrameHandler;

private _fnc_createJumplight = {
    private _jumplight = "#lightreflector" createVehicle [0,0,0];
    _jumplight
};

private _jumplight = call _fnc_createJumplight;
_jumplight attachTo [_aircraft, _jumplightPos vectorAdd [0, -0.015 * speed _aircraft, 0]]; // Light position is offset and flickers due to vehicle speed
_aircraft setVariable ["ffr_jumplight", _jumplight, true];
_dummy setVariable ["ffr_jumplight", _jumplight, true];
private _jumplight_dummy = call _fnc_createJumplight;
_jumplight_dummy attachTo [_dummy, _jumplightPos];
_aircraft setVariable ["ffr_jumplight_dummy", _jumplight_dummy, true];
_dummy setVariable ["ffr_jumplight_dummy", _jumplight_dummy, true];
["ffr_main_setJumplight", [_aircraft, "off"]] call CBA_fnc_globalEvent;

_aircraft addEventHandler ["Deleted", { call ffr_main_fnc_cleanup }];
_aircraft addEventHandler ["Killed", { call ffr_main_fnc_cleanup }];
