//#include "script_component.hpp"
/*
Author: Ampers
Move unit out of aicraft seat to standing in static dummy.

* Arguments:
* 0: Aircraft <OBJECT>
* 1: Unit <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft, _unit] call ffr_main_fnc_standUp = {
*/

params ["_aircraft", "_unit"];

_unit setVariable ["ffr_aircraft", _aircraft, true];
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];

// Move the unit to the static dummy
_unit allowDamage false;
_unit disableCollisionWith _aircraft;
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
if (isNull _dummy) exitWith {};
private _relPos = _aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit);
private _pos = AGLToASL (_dummy modelToWorldVisual _relPos);
_dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
_dummy hideObject false;
moveOut _unit;
_unit setPosASL _pos;
_unit setVelocity [0,0,0];
//if (ffr_testing) then { systemChat "TP to dummy"; };
_unit setVectorDir _dir;
_unit switchMove "";
[{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;

[{
    params ["_args", "_pfID"];
    _args params ["_unit", "_aircraft", "_dummy", "_time", "_rampAltitude"];
    if (CBA_missionTime > _time) then {
        _unit allowDamage true;
    };
    private _alt = getPosASL _unit # 2;

    if (animationState _unit in ["halofreefall_f", "halofreefall_non"]) then {
        if (_alt > _rampAltitude || {CBA_missionTime < _time}) then {
            // Fix freefall animation
            //if (ffr_testing) then { systemChat format ["Fix Freefall %1 %2", CBA_missionTime, getPosVisual _unit # 2]; };
            _unit switchMove "";
            _args set [3, CBA_missionTime + 0.5];
        } else {
            // Return to flying aircraft
            private _velAircraft = velocity _aircraft;
            _unit allowDamage false;
            private _pos = _aircraft modelToWorldVisual (_dummy worldToModelVisual (ASLToAGL getPosWorldVisual _unit));
            private _dir = _aircraft vectorModelToWorldVisual (_dummy vectorWorldToModelVisual (vectorDir _unit));
            private _vel_unit = velocity _unit;
            _vel_unit set [0, 0]; _vel_unit set [1, 0];
            private _velRelease = (_velAircraft vectorMultiply 0.9) vectorAdd _vel_unit;

            _unit setPosASL AGLToASL _pos;
            _unit setVectorDir _dir;
            _unit setVelocity _velRelease;
            _dummy hideObject true;

            _unit setVariable ["ffr_aircraft", nil, true];
            [_aircraft, _unit] call ffr_main_fnc_aiJump;
            [{
                _this allowDamage true;
            }, _unit, 0.5] call CBA_fnc_waitAndExecute;
            [_pfID] call CBA_fnc_removePerFrameHandler;
        };
    };
}, 0, [_unit, _aircraft, _dummy, CBA_missionTime + 0.5, (_pos # 2) - 1]] call CBA_fnc_addPerFrameHandler;
