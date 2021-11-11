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
* [_aircraft] call ffr_main_fnc_planFlight
*/

params ["_aircraft"];

// AI plane
private _alt = 5000;
_aircraft limitSpeed 240;
_aircraft flyInHeightASL [_alt, _alt, _alt];
_pos = getPosASL _aircraft;
_pos set [2, _alt];
_aircraft setPosASL _pos;
_aircraft setFuel 1;
_aircraft setVectorUp [0, 0, 1];
_aircraft setVelocityModelSpace [0, 66, 0];
