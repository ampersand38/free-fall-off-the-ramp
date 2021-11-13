#include "script_component.hpp"
/*
Author: Ampersand
Add actions to aircraft for Plan AI Flight and Set Ramp for Jump

* Arguments:
* 0: Unit <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft] call ffr_main_fnc_prepAircraft = {
*/

params ["_aircraft"];

_aircraft addAction ["Prep Ramp for Free Fall", {
    params ["_aircraft"];
    ["ffr_main_prepRamp", [_aircraft]] call CBA_fnc_serverEvent;
}, nil, 0, true, true, "", "(getPos _target # 2) > 200 && {_this == driver _target || {!isNull driver _target && {!isPlayer driver _target} && {_this == leader _this}}}"];

_aircraft addAction ["Stand Up", {
    call ffr_main_fnc_standUp;
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_dummy', objNull]) && {_this in _target} && {(_target getCargoIndex _this) > -1}"];

_aircraft addAction ["Plan AI Flight", {
    call ffr_main_fnc_planFlight;
}, nil, 0, true, true, "", "!isNull driver _target && { !isPlayer driver _target } && { _this in _target } && {_this == leader _this}"];

_aircraft addAction ["Begin AI Flight", {
    params ["_aircraft"];
    ["ffr_main_aiFlight", [_aircraft, ffr_ai_alt, ffr_ai_rp, ffr_ai_ip], _aircraft] call CBA_fnc_targetEvent;
}, nil, 0, true, true, "", "(_target getCargoIndex _this) > -1 && {_this == leader _this} && {!isNil 'ffr_ai_alt'} && {!isNil 'ffr_ai_rp'} && {!isNil 'ffr_ai_ip'}"];
