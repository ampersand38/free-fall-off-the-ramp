//#include "script_component.hpp"
/*
Author: Ampers
Move unit out of aicraft seat to standing in ViV space

* Arguments:
* 0: Unit <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft] call ffr_main_fnc_prepRamp
*/

params ["_aircraft"];

if (isServer) then {
    {
        deleteVehicle (_aircraft getVariable [_x, objNull]);
    } forEach ["halo_dummy", "halo_helper", "jumplight"];

    private _pos = getPosASL _aircraft;
    _pos params ["_x", "_y", "_z"];
    _helper = "Land_InvisibleBarrier_F" createVehicle [0, 0, 0];
    _aircraft setVariable ["halo_helper", _helper, true];
    _helper setPosASL [_x, _y, 0];
    _helper setDir getDir _aircraft;
    _dummy = createVehicle [typeOf _aircraft, _pos, [], 0, "FLY"];
    _dummy attachTo [_helper, [0, -1000, _z]];
    _dummy allowDamage false;
    if (isMultiplayer) then {
        _dummy hideObjectGlobal true;
    } else {
        _dummy hideObject true;
    };
    _aircraft setVariable ["halo_dummy", _dummy, true];
    _dummy setVariable ["halo_aircraft", _aircraft, true];

    private _animInfo = [];
    if (_aircraft isKindOf "VTOL_01_infantry_base_F") then {
        _animInfo = ["door", ["Door_1_source"]]; // ["_animType", "_anims"]
    };
    if (_aircraft isKindOf "VTOL_02_infantry_base_F") then {
        _animInfo = ["door", ["Door_1_source"]]; // ["_animType", "_anims"]
    };
    if (_aircraft isKindOf "USAF_C17") then {
        _animInfo = ["", ["back_ramp_switch", "back_ramp", "back_ramp_st", "back_ramp_p", "back_ramp_p_2", "back_ramp_door_main"]];
    };
    if (_aircraft isKindOf "USAF_C130J") then {
        _animInfo = ["source", ["ramp_bottom", "ramp_top"]];
    };
    if (_aircraft isKindOf "RHS_C130J") then {
        _animInfo = ["source", ["ramp", "jumplight"]];
    };

    private _pfID = [{
        params ["_args", "_pfID"];
        _args params ["_aircraft", "_dummy", "_animInfo"];
        _animInfo params ["_animType", "_anims"];
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

    }, 0.5, [_aircraft, _dummy, _animInfo]] call CBA_fnc_addPerFrameHandler;

    _aircraft addEventHandler ["Deleted", {
    	params ["_aircraft"];
        {
            deleteVehicle (_aircraft getVariable [_x, objNull]);
        } forEach ["halo_dummy", "halo_helper", "jumplight"];
    }];
};
