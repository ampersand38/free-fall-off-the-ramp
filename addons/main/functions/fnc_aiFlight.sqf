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
* [_aircraft, ffr_ai_alt, ffr_ai_rp, ffr_ai_ip] call ffr_main_fnc_aiFlight = {
*/

params ["_aircraft", "_alt", "_rp", "_ip"];

if (hasInterface) then {
    titleCut ["", "BLACK"];
    titleText ["After the flight to the Initial Point...", "PLAIN", 0.5];
    titleCut ["", "BLACK in", 5];
};

if (!local _aircraft) exitWith {};

_aircraft engineOn true;
_aircraft setFuel 1;
private _minDistance = 6000;
private _idealSpeed = 240; // ~130 kts
private _cfg = configOf _aircraft;
private _stallSpeed = getNumber (_cfg >> "stallSpeed");
private _maxSpeed = getNumber (_cfg >> "maxSpeed");
private _spd = (_stallSpeed max 240) min _maxSpeed;
private _dir = _ip getDir _rp;
if (_rp distance2D _ip < _minDistance) then {
    _ip = _rp getPos [_minDistance, _dir - 180];
    if (!isNil "ffr_ai_ipMarker") then {
        ffr_ai_ipMarker setMarkerPos _ip;
    };
};
_rp set [2, _alt];
_ip set [2, _alt];
_aircraft setPosASL _ip;
_aircraft setVectorUp [0, 0, 1];
_aircraft setDir _dir;
_aircraft setVelocityModelSpace [0, _spd / 3.6, 10];
_aircraft limitSpeed _spd;
_aircraft flyInHeightASL [_alt, _alt, _alt];

private _grp = group _aircraft;
for "_i" from count waypoints _grp - 1 to 0 step -1 do
{
	deleteWaypoint [_grp, _i];
};

_wpPos = _rp getPos [4000, _dir - 180];
_wpPos set [2, _alt];
_wp = _grp addWaypoint [_wpPos, -1, 0, "IP"];
private _waypointStatements = {
    _a = vehicle this;
    _a vehicleChat 'Red Light! Stand up and check equipment!';
    if (isNull (_a getVariable ['ffr_dummy', objNull])) then {
        ['ffr_main_prepRamp', [_a, true]] call CBA_fnc_serverEvent;
        ['ffr_main_setJumplight', [_a, 'red']] call CBA_fnc_globalEvent;
    };
};
_wp setWaypointStatements ["true", "call " + str _waypointStatements];

_wpPos = _rp getPos [2000, _dir - 180];
_wpPos set [2, _alt];
_wp = _grp addWaypoint [_wpPos, -1, 1, ""];

_wp = _grp addWaypoint [_rp, -1, 2, "RP"];
_wp setWaypointStatements ["true", "_a = vehicle this; _a vehicleChat 'Green Light! Go! Go! Go!'; ['ffr_main_setJumplight', [_a, 'green']] call CBA_fnc_globalEvent;"];

_wpPos = _rp getPos [2000, _dir];
_wpPos set [2, _alt];
_wp = _grp addWaypoint [_wpPos, -1, 3, "All Out"];

private _wpExfil = _grp addWaypoint [_ip, -1, 4, "Exfil"];
_wpExfil setWaypointStatements ["true", "_a = vehicle this; deleteMarker (a getVariable 'ffr_ai_acMarker'); [a] call ffr_main_fnc_cleanup; deleteVehicleCrew _a; deleteVehicle _a;"];
_aircraft move _wpPos;
