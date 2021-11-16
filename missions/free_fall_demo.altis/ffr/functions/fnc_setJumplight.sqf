//#include "script_component.hpp"
/*
Author: Ampers
Creates jumplight for static dummy and aircraft

* Arguments:
* 0: Dummy <OBJECT>
*
* Return Value:
* -

* Example:
* [_dummy] call ffr_main_fnc_setJumplight = {
*/

params ["_dummy", "_state"];

private _jumplight = _dummy getVariable ["ffr_jumplight", objNull];
private _jumplight_dummy = _dummy getVariable ["ffr_jumplight_dummy", objNull];
switch (_state) do {
    case ("red"): {
        if (_dummy isKindOf "RHS_C130J") then {
            // Is this the dummy?
            private _realAircraft = _dummy getVariable ["ffr_aircraft", objNull];
            if (!isNull _realAircraft) then {
                _dummy = _realAircraft;
            };
            _dummy animateSource ["jumplight", 0];
        };
        {
            _x setLightIntensity 200;
            _x setLightColor [1, 0, 0];
        } forEach [_jumplight, _jumplight_dummy];
    };
    case ("green"): {
        if (_dummy isKindOf "RHS_C130J") then {
            // Is this the dummy?
            private _realAircraft = _dummy getVariable ["ffr_aircraft", objNull];
            if (!isNull _realAircraft) then {
                _dummy = _realAircraft;
            };
            _dummy animateSource ["jumplight", 1];
        };
        {
            _x setLightIntensity 200;
            _x setLightColor [0, 1, 0];
        } forEach [_jumplight, _jumplight_dummy];
    };
    case ("off"): {
        if (_dummy isKindOf "RHS_C130J") then {
            // Is this the dummy?
            private _realAircraft = _dummy getVariable ["ffr_aircraft", objNull];
            if (!isNull _realAircraft) then {
                _dummy = _realAircraft;
            };
            _dummy animateSource ["jumplight", 0];
        };
        {
            _x setLightIntensity 0;
            _x setLightConePars [360, 360, 1];
            _x setLightAttenuation [2, 4, 4, 0, 9, 10];
            _x setLightDayLight true;
            //_x setLightUseFlare true;
            //_x setLightFlareSize 0.5;
            //_x setLightFlareMaxDistance 1000;
        } forEach [_jumplight, _jumplight_dummy];
    };
};
