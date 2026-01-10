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
if (count _vics > 0) then {
//static line drop of cargo
_this addAction ["Paradrop Cargo Staticline", {
    params ["_dummy", "_unit"];
    private _aircraft = _dummy getVariable "ffr_aircraft";
    private _success = _aircraft setVehicleCargo objNull;
    private _vics = getVehicleCargo _aircraft;
    if (_success) then {
        hint "Cargo para drop released.";
        {
            private _strobe = createVehicle ["O_IRStrobe", _pos, [], 0, "CAN_COLLIDE"];
            _strobe attachTo [_x, [0,0,1]];
        } forEach _vics;
    } else {
        hint "Failed to release cargo para drop.";
    };
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_aircraft', objNull])"];
};
