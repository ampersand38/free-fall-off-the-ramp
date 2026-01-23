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

// Move the unit to the static dummy
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
if (isNull _dummy) exitWith {};

private _isInAircraftBay = _unit getVariable 'ffr_in_aircraft_bay';
_unit setVariable ['ffr_static_line_hooked', false, true];

if (isNil '_isInAircraftBay') then {
    if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {
    //add hook action
    hookAction = ['Hook Up','Hook Up','',{
        params ["_unit"];
        _unit setVariable ['ffr_static_line_hooked', true, true];
    },{
        params ["_unit"];
        (_unit getVariable 'ffr_static_line_hooked' == false and _unit getVariable 'ffr_in_aircraft_bay');
    }] call ace_interact_menu_fnc_createAction;

    //add unhook action
    unhookAction = ['Unhook','Unhook','',{
        params ["_unit"];
        _unit setVariable ['ffr_static_line_hooked', false, true];
    },{
        params ["_unit"];
        (_unit getVariable 'ffr_static_line_hooked' and _unit getVariable 'ffr_in_aircraft_bay');
    }] call ace_interact_menu_fnc_createAction;

    [_unit, 1, ["ACE_SelfActions"], unhookAction] call ace_interact_menu_fnc_addActionToObject;
    [_unit, 1, ["ACE_SelfActions"], hookAction] call ace_interact_menu_fnc_addActionToObject;
    } else {
        _dummy addAction ["Hook Up", {
            (_this select 3 select 0) setVariable ['ffr_static_line_hooked', true, true];
        }, [_unit], 1.5, true, true, "", "_this getVariable 'ffr_static_line_hooked' == false"];
    };

};
_unit setVariable ['ffr_in_aircraft_bay', true, true];

private _relPos = _aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit);
private _pos = AGLToASL (_dummy modelToWorldVisual _relPos);
_dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
_dummy hideObject false;
_unit allowDamage false;
_unit setUnitFreefallHeight (((ASLToAGL _pos) select 2) + 5);
moveOut _unit;
_unit setPosASL _pos;
_unit setVelocity [0,0,0];
//if (ffr_testing) then { systemChat "TP to dummy"; };
_unit setVectorDir _dir;
_unit switchMove "";

[{
    params ["_unit", "_aircraft"];
    private _isFreeFall = getUnitFreefallInfo _unit select 0;
    if (_isFreeFall) then {
        _unit moveInCargo _aircraft;
    };
},[_unit, _aircraft], 1] call CBA_fnc_waitAndExecute;

[{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;

[{
    params ["_args", "_pfID"];
    _args params ["_unit", "_aircraft", "_dummy", "_height", "_timeStandSafe"];

    private _alt = getPosASL _unit # 2;

    if (vehicle _unit != _aircraft && {_alt > _height}) exitWith {}; // Safe

    [_pfID] call CBA_fnc_removePerFrameHandler;
    _unit setUnitFreefallHeight -1;

    // Unit got squeezed out
    if (CBA_missionTime < _timeStandSafe) exitWith {
        _unit moveInCargo _aircraft;
    };

    // Return to flying aircraft for free fall
    private _velAircraft = velocity _aircraft;
    _unit allowDamage false;
    private _pos = _aircraft modelToWorldVisualWorld (_dummy worldToModelVisual (ASLToAGL getPosWorldVisual _unit));
    private _dir = _aircraft vectorModelToWorldVisual (_dummy vectorWorldToModelVisual (vectorDir _unit));
    private _vel_unit = velocity _unit # 2;
    private _velRelease = (_velAircraft vectorMultiply 0.9) vectorAdd [0, 0, _vel_unit];


    _unit setPosASL _pos;
    _unit setVectorDir _dir;
    _unit setVelocity _velRelease;
    _dummy hideObject true;

    //open static line if hooked
    if (_unit getVariable ["ffr_static_line_hooked", false]) then {
        [{
            _this action ["OpenParachute", _this];
            _this setVariable ['ffr_in_aircraft_bay', false, true];
        }, _unit, 0.5] call CBA_fnc_waitAndExecute;
    };
    [_aircraft, _unit] call ffr_main_fnc_aiJump;

    [{_this allowDamage true;}, _unit, 0.5] call CBA_fnc_waitAndExecute;
}, 0, [_unit, _aircraft, _dummy, _pos # 2 - 2, CBA_missionTime + 5]] call CBA_fnc_addPerFrameHandler;
