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
* [_aircraft] call ffr_main_fnc_prepAircraft
*/

params ["_aircraft"];

_aircraft addAction ["Prep Ramp for Free Fall", {
    ["ffr_main_prepRamp", [_aircraft]] call CBA_fnc_serverEvent;
}, nil, 0, true, true, "", "_this == driver _target && {(getPos _target # 2) > 200}"];

_aircraft addAction ["Stand Up", {
    params ["_aircraft", "_unit"];
    _unit setVariable ["halo_aircraft", _aircraft, true];
    private _dummy = _aircraft getVariable ["halo_dummy", objNull];
/*
    // Add jumplight actions to dummy
    if (_aircraft isKindOf "RHS_C130J_Base") then {
        private _redLightID = _aircraft getVariable "halo_redLightID";
        if (isNil "_redLightID") then
            _dummy addAction ["<t color='#FF0000'>Red Light</t>", {
                params ["_dummy", "_unit"];
                private _aircraft = _dummy getVariable "halo_aircraft";
                _aircraft animateSource ["jumplight", 0, true];
            }, nil, 6, true, true, "", "(_target  animationSourcePhase 'jumplight') == 1"];
            _dummy setVariable ["halo_actionID", _actionID, true];
        };
        private _greenLightID = _aircraft getVariable "halo_greenLightID";
        if (isNil (_dummy getVariable "halo_greenLightID")) then
            _dummy addAction ["<t color='#00FF00'>Green Light</t>", {
                params ["_dummy", "_unit"];
                private _aircraft = _dummy getVariable "halo_aircraft";
                _aircraft animateSource ["jumplight", 1, true];
            }, nil, 6, true, true, "", "(_target  animationSourcePhase 'jumplight') == 0"];
        };
    };
*/
    // Move the unit to the static dummy
    _unit allowDamage false;
    _unit disableCollisionWith _aircraft;
    private _dummy = _aircraft getVariable ["halo_dummy", objNull];
    if (isNull _dummy) exitWith {};
    _pos = _dummy modelToWorldVisual (_aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit));
    _dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
    _dummy hideObject false;
    if (ffr_testing) then { systemChat "Unhide dummy"; };
    moveOut _unit;
    _unit setPosASL AGLToASL _pos;
    _unit setVelocity [0,0,0];
    if (ffr_testing) then { systemChat "TP to dummy"; };
    _unit setVectorDir _dir;
    _unit switchMove "";
    [_unit] call ffr_main_fnc_fixFreeFallToWalk;

    [{
        // EH to handle freefall anim
        private _jumpEHID = _unit getVariable "halo_jumpEHID";
        if (!isNil "_jumpEHID") then {
            _unit removeEventHandler ["AnimStateChanged", _jumpEHID];
        };
        _jumpEHID = _unit addEventHandler ["AnimStateChanged", {
            params ["_unit", "_anim"];
            private _alt = getPos _unit # 2;
            private _aircraft = _unit getVariable ["halo_aircraft", objNull];
            private _dummy = _aircraft getVariable ["halo_dummy", objNull];
            if (_anim in ["halofreefall_f", "halofreefall_non"]) then {
                if (
                    _alt < 10
                ) then {
                    // Fix freefall animation
                    if (ffr_testing) then { systemChat format ["Fix Freefall %1 %2", CBA_missionTime, getPos _unit # 2]; };
                    [_unit] call ffr_main_fnc_fixFreeFallToWalk;
                } else {
                    // Return to flying aircraft
                    private _velAircraft = velocity _aircraft;
                    if (vectorMagnitude _velAircraft > 1) then {
                        _unit allowDamage false;
                        private _pos = _aircraft modelToWorldVisual (_dummy worldToModelVisual (ASLToAGL getPosWorldVisual _unit));
                        private _dir = _aircraft vectorModelToWorldVisual (_dummy vectorWorldToModelVisual (vectorDir _unit));
                        private _vel_unit = velocity _unit;
                        _vel_unit set [0, 0]; _vel_unit set [1, 0];
                        private _velRelease = (_velAircraft vectorMultiply 0.9) vectorAdd _vel_unit;

                        _unit setPosASL AGLToASL _pos;
                        _unit setVectorDir _dir;
                        _unit setVelocity _velRelease;
                        _dummy hideObject true;
                        if (ffr_testing) then { systemChat format ["TP speed %1 km/h", speed _aircraft]; };

                        _unit setVariable ["halo_aircraft", nil, true];
                        [{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;
                    };
                    _unit removeEventHandler ["AnimStateChanged", _thisEventHandler];
                };
            };
        }];
        _unit setVariable ["halo_jumpEHID", _jumpEHID];
    }, [_unit], 1] call CBA_fnc_waitAndExecute;

}, nil, 0, true, true, "", "!isNull (_target getVariable ['halo_dummy', objNull]) && {(_target getCargoIndex _this) > -1}"];

_aircraft addAction ["Plan AI Flight", {

}, nil, 0, true, true, "", "!isNull driver _target && { !isPlayer driver _target } && { _this in _target }"]
