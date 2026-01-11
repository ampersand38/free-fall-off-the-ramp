//#include "script_component.hpp"
/*
Author: Ampers
Animates the vehicle out of the back of the dummy aircraft.

* Arguments:
* 0: _aircraft <OBJECT>
* 1: _dummyVic <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft, _vic] call ffr_main_fnc_animateVic = {
*/

params ["_aircraft", "_dummyVic"];

private _initPos = _aircraft getRelPos _dummyVic;
for "_i" from 1 to 50 do {
    _initPos set [1, (_initPos select 1) - 0.3];
    _dummyVic attachTo [_aircraft, _initPos];
    sleep 0.02;
};
deleteVehicle _dummyVic;
