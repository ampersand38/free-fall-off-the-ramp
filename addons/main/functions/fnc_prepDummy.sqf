//#include "script_component.hpp"
/*
Author: Ampers
Creates local actions for  dummy

* Arguments:
* 0: Dummy <OBJECT>
*
* Return Value:
* -

* Example:
* _dummy call ffr_main_fnc_prepDummy = {
*/

if (!hasInterface) exitWith {};

_this addAction ["<t color='#999999'>Sit Down</t>", {
    params ["_dummy", "_unit"];
    private _aircraft = _dummy getVariable "ffr_aircraft";
    _unit setVariable ['ffr_in_aircraft_bay', false, true];
    _unit setVariable ['ffr_static_line_hooked', false, true];
    [{
        params ["_unit", "_aircraft"];
        _unit moveInCargo _aircraft;
        vehicle _unit == _aircraft
    }, {}, [_unit, _aircraft], 5] call CBA_fnc_waitUntilAndExecute;
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_aircraft', objNull])"];


//prep actions for dropping cargo
private _aircraft = _dummy getVariable "ffr_aircraft";
private _vics = getVehicleCargo _aircraft;

{
    private _newVic = createVehicle [typeOf _x, position _x, [], 0, "CAN_COLLIDE"];
    _newVic setPhysicsCollisionFlag false;
    _newVic setVariable ["ffr_cargo_original", _x, true];
    _dummy setVehicleCargo _newVic;
    _newVic addAction ["Drop Vehicle", {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _oldVic = _target getVariable ["ffr_cargo_original", objNull];
        if (isNull _oldVic) exitWith {};

        [{
            params ["_oldVic"];
            objNull setVehicleCargo _oldVic;
        }, [_oldVic], 1] call CBA_fnc_waitAndExecute;

        private _strobe = createVehicle ["O_IRStrobe", getPos _oldVic, [], 0, "CAN_COLLIDE"];
        _strobe attachTo [_oldVic, [0,0,1]];
        [_this select 3 select 0, _target] call ffr_main_fnc_animateVic;
        //deleteVehicle _target;
    }, [_dummy], 0, true, true, "", "!isNull (isVehicleCargo _target)"];
} forEach _vics;

