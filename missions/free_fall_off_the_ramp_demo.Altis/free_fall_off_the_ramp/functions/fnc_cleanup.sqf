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
* [_aircraft] call ffr_main_fnc_cleanup
*/

params ["_aircraft"];

{
    deleteVehicle (_aircraft getVariable [_x, objNull]);
    _aircraft setVariable [_x, nil];
} forEach ["halo_dummy", "halo_helper", "jumplight"];
