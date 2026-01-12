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
* [_aircraft] call ffr_main_fnc_cleanUp = {
*/

params ["_aircraft"];

private _dummyAircraft = _aircraft getVariable ["ffr_dummy"];

if (!isNull _dummyAircraft) then {
    private _vics = getVehicleCargo _dummyAircraft;
    {
        deleteVehicle _x;
    } forEach _vics;
};

{
    deleteVehicle (_aircraft getVariable [_x, objNull]);
    _aircraft setVariable [_x, nil];
} forEach ["ffr_dummy", "ffr_helper", "ffr_jumplight", "ffr_jumplight_dummy"];
