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
    params ["_aircraft"];
    ["ffr_main_prepRamp", [_aircraft]] call CBA_fnc_serverEvent;
}, nil, 0, true, true, "", "(getPos _target # 2) > 200 && {_this == driver _target || {!isNull driver _target && {!isPlayer driver _target} && {_this == leader _this}}}"];

_aircraft addAction ["Stand Up", {
    params ["_aircraft", "_unit"];
    _unit setVariable ["ffr_aircraft", _aircraft, true];
    private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
/*
    // Add jumplight actions to dummy
    if (_aircraft isKindOf "RHS_C130J_Base") then {
        private _redLightID = _aircraft getVariable "ffr_redLightID";
        if (isNil "_redLightID") then
            _dummy addAction ["<t color='#FF0000'>Red Light</t>", {
                params ["_dummy", "_unit"];
                private _aircraft = _dummy getVariable "ffr_aircraft";
                _aircraft animateSource ["jumplight", 0, true];
            }, nil, 6, true, true, "", "(_target  animationSourcePhase 'jumplight') == 1"];
            _dummy setVariable ["ffr_actionID", _actionID, true];
        };
        private _greenLightID = _aircraft getVariable "ffr_greenLightID";
        if (isNil (_dummy getVariable "ffr_greenLightID")) then
            _dummy addAction ["<t color='#00FF00'>Green Light</t>", {
                params ["_dummy", "_unit"];
                private _aircraft = _dummy getVariable "ffr_aircraft";
                _aircraft animateSource ["jumplight", 1, true];
            }, nil, 6, true, true, "", "(_target  animationSourcePhase 'jumplight') == 0"];
        };
    };
*/
    // Move the unit to the static dummy
    _unit allowDamage false;
    _unit disableCollisionWith _aircraft;
    private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
    if (isNull _dummy) exitWith {};
    private _relPos = _aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit);
    // Xian is too narrow, reduce x coord
    /*
    if (_aircraft isKindOf "VTOL_02_infantry_base_F") then {
        _relPos set [0, (_relPos # 0) * 0.5];
        _relPos set [2, (_relPos # 2) - 0.5];
    };
    */
    private _pos = AGLToASL (_dummy modelToWorldVisual _relPos);
    _dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
    _dummy hideObject false;
    moveOut _unit;
    _unit setPosASL _pos;
    _unit setVelocity [0,0,0];
    if (ffr_testing) then { systemChat "TP to dummy"; };
    _unit setVectorDir _dir;
    _unit switchMove "";
    [{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;

    [{
        params ["_args", "_pfID"];
        _args params ["_unit", "_aircraft", "_dummy", "_time", "_rampAltitude"];
        if (CBA_missionTime > _time) then {
            _unit allowDamage true;
        };
        private _alt = getPosASL _unit # 2;

        if (animationState _unit in ["halofreefall_f", "halofreefall_non"]) then {
            if (_alt > _rampAltitude) then {
                // Fix freefall animation
                if (ffr_testing) then { systemChat format ["Fix Freefall %1 %2", CBA_missionTime, getPosVisual _unit # 2]; };
                _unit switchMove "";
            } else {
                if (CBA_missionTime > _time) then {
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

                        _unit setVariable ["ffr_aircraft", nil, true];
                        [{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;
                    };
                    [_pfID] call CBA_fnc_removePerFrameHandler;
                };
            };
        };
    }, 0, [_unit, _aircraft, _dummy, CBA_missionTime + 1, (_pos # 2) - 1]] call CBA_fnc_addPerFrameHandler;

}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_dummy', objNull]) && {(_target getCargoIndex _this) > -1}"];

_aircraft addAction ["Plan AI Flight", {
    params ["_aircraft"];
    _aircraft call ffr_main_fnc_planFlight;
}, nil, 0, true, true, "", "!isNull driver _target && { !isPlayer driver _target } && { _this in _target }"]
