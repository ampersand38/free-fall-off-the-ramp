#include "script_component.hpp"
/*
Author: Ampers
Creates jumplight for static dummy and aircraft

* Arguments:
* 0: Dummy <OBJECT>
*
* Return Value:
* -

* Example:
* [_dummy] call ffr_main_fnc_setJumplight
*/

params ["_dummy", "_state"];

private _jumplight = _dummy getVariable ["ffr_jumplight", objNull];
private _jumplight_dummy = _dummy getVariable ["ffr_jumplight_dummy", objNull];
switch (_state) do {
    case ("red"): {
        _jumplight setLightIntensity 200;
        _jumplight setLightColor [1, 0, 0];
        _jumplight_dummy setLightIntensity 200;
        _jumplight_dummy setLightColor [1, 0, 0];
    };
    case ("green"): {
        _jumplight setLightIntensity 200;
        _jumplight setLightColor [0, 1, 0];
        _jumplight_dummy setLightIntensity 200;
        _jumplight_dummy setLightColor [0, 1, 0];
    };
    case ("off"): {
        _jumplight setLightIntensity 0;
        _jumplight_dummy setLightIntensity 0;
    };
};
