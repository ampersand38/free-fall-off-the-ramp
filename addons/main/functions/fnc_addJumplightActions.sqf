#include "script_component.hpp"
/*
Author: Ampers
Add jumplight actions for static dummy

* Arguments:
* 0: Dummy <OBJECT>
*
* Return Value:
* -

* Example:
* [_dummy] call ffr_main_fnc_addJumplightActions = {
*/

params ["_dummy"];

_dummy addAction ["<t color='#FF0000'>Jumplight Red</t>", {
    params ["_dummy"];
    ["ffr_main_setJumplight", [_dummy, "red"]] call CBA_fnc_globalEvent;
}, nil, 0];

_dummy addAction ["<t color='#00FF00'>Jumplight Green</t>", {
    params ["_dummy"];
    ["ffr_main_setJumplight", [_dummy, "green"]] call CBA_fnc_globalEvent;
}, nil, 0];

_dummy addAction ["<t color='#999999'>Jumplight Off</t>", {
    params ["_dummy"];
    ["ffr_main_setJumplight", [_dummy, "off"]] call CBA_fnc_globalEvent;
}, nil, 0];
