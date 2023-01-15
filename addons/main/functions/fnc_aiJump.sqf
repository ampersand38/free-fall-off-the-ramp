//#include "script_component.hpp"
/*
Author: Ampers
Handle AI teammates

* Arguments:
* 0: Unit <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft, _unit] call ffr_main_fnc_aiJump = {
*/

params ["_aircraft", "_unit"];

if (_unit != leader _unit) exitWith {};

private _AIs = units _unit select {
    !isPlayer _x &&
    {vehicle _x == _aircraft} &&
    {(_aircraft getCargoIndex _x) > -1}
};
if (count _AIs == 0) exitWith {};

ffr_AIs = _AIs apply {_x};
// AI teammates eject
[{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_AIs", "_previousAI"];
    if (!isNull _previousAI) then { _previousAI setVelocity velocity _aircraft; };
    private _AI = _AIs # 0;
    _args set [2, _AI];
    moveOut _AI;
    _AIs deleteAt 0;
    if (count _AIs == 0) then {
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
    _args set [1, _AIs];
}, 0.5, [_aircraft, _AIs, objNull]] call CBA_fnc_addPerFrameHandler;

// AI teammates open chute
ffr_ai_playerEH = ["vehicle", {
    params ["_unit", "_newVehicle", "_oldVehicle"];
    if (_newVehicle isKindOf "ParachuteBase") then {
        ffr_ai_openingAlt = getPosASL player # 2;
        [{
            params ["", "_pfID"];
            _args params ["_aircraft", "_AIs", "_previousAI"];
            private _done = true;
            {
                if ((getPosASL _x # 2) > ffr_ai_openingAlt) then {
                    _done = false;
                } else {
                    if (vehicle _x == _x) then {
                        private _vel = velocity _x;
                        _chute = typeOf vehicle player createVehicle [0, 0, 100];
                        _chute setPosASL getPosASL _x;
                        _x moveInAny _chute;
                        _chute setVelocity _vel;
                    };
                };
            } forEach ffr_AIs;
            if (_done) then {
                ffr_AIs = nil;
                ffr_ai_openingAlt = nil;
                [_pfID] call CBA_fnc_removePerFrameHandler;
            };
        }, 0.1] call CBA_fnc_addPerFrameHandler;
        ["vehicle", ffr_ai_playerEH] call CBA_fnc_removePlayerEventHandler;
    };
}] call CBA_fnc_addPlayerEventHandler;
