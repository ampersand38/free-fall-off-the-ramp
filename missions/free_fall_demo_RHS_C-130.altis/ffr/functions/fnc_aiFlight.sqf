//#include "script_component.hpp"
/*
Author: Ampers
Set AI piloted aircraft to fly the drop

* Arguments:
* 0: Aircraft <OBJECT>
* 1: Altitude <NUMBER>
* 2: Release Point <ARRAY>
* 3: Initial Point <ARRAY>
*
* Return Value:
* -

* Example:
* [_aircraft, ffr_ai_alt, ffr_ai_rp, ffr_ai_ip] call ffr_main_fnc_aiFlight ={
*/

params ["_aircraft", "_alt", "_rp", "_ip"];

private _minDistance = 4000;
private _dir = _ip getDir _rp;
_aircraft engineOn true;
_aircraft limitSpeed 240;
_aircraft flyInHeightASL [_alt, _alt, _alt];
if (_rp distance2D _ip < _minDistance) then {
    _ip = _rp getPos [_minDistance, _dir - 180];
};
_rp set [2, _alt];
_ip set [2, _alt];
_aircraft setPosASL _ip;
_aircraft setFuel 1;
_aircraft setVectorUp [0, 0, 1];
_aircraft setDir _dir;
_aircraft setVelocityModelSpace [0, 66, 0];

private _grp = group _aircraft;
for "_i" from count waypoints _grp - 1 to 0 step -1 do
{
	deleteWaypoint [_grp, _i];
};

_wp = _grp addWaypoint [_ip, -1, 0, "IP"];

_wpPos = _rp getPos [2000, _dir - 180];
_wpPos set [2, _alt];
_wp = _grp addWaypoint [_wpPos, -1, 1, "Red Light"];
_wp setWaypointStatements ["true", "hint 'Open ramp and stand up!'; _a = vehicle this; if (isNull (_a getVariable ['ffr_dummy', objNull])) then {['ffr_main_prepRamp', [_a]] call CBA_fnc_serverEvent; ['ffr_main_setJumplight', [_a, 'red']] call CBA_fnc_globalEvent;};"];

_wp = _grp addWaypoint [_rp, -1, 2, "RP"];
_wp setWaypointStatements ["true", "hint 'Go! Go! Go!'; _a = vehicle this; ['ffr_main_setJumplight', [_a, 'green']] call CBA_fnc_globalEvent;"];

_wpPos = _rp getPos [2000, _dir];
_wpPos set [2, _alt];
_wp = _grp addWaypoint [_wpPos, -1, 3, "All Out"];

_wpPos = _rp getPos [_minDistance, _dir];
_wpPos set [2, _alt];
private _wpExfil = _grp addWaypoint [_wpPos, -1, 4, "Exfil"];
_wpExfil setWaypointStatements ["true", "_a = vehicle this; deleteMarker (a getVariable 'ffr_ai_acMarker'); [a] call ffr_main_fnc_cleanup; deleteVehicleCrew _a; deleteVehicle _a;"];
_aircraft move _wpPos;
