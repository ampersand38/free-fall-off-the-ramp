/*
run this code globally

then use this to plan the ai Flight
ffr_ai_alt = 8000;
ffr_ai_rp = getPos player;
ffr_ai_ip = player getPos [4000, getDir player];
*/
ffr_main_fnc_aiFlight = {
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
};
ffr_main_fnc_cleanUp = {
params ["_aircraft"];

{
    deleteVehicle (_aircraft getVariable [_x, objNull]);
    _aircraft setVariable [_x, nil];
} forEach ["ffr_dummy", "ffr_helper", "ffr_jumplight", "ffr_jumplight_dummy"];
};
ffr_main_fnc_prepAircraft = {
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
}, nil, 0, true, true, "", "isClass (configFile >> 'ffr_altitude_menu') && {!isNull driver _target} && { !isPlayer driver _target } && { _this in _target } && {_this == leader _this}"];

_aircraft addAction ["Begin AI Flight", {
    params ["_aircraft"];
    ["ffr_main_aiFlight", [_aircraft, ffr_ai_alt, ffr_ai_rp, ffr_ai_ip], _aircraft] call CBA_fnc_targetEvent;
}, nil, 0, true, true, "", "(_target getCargoIndex _this) > -1 && {_this == leader _this} && {!isNil 'ffr_ai_alt'} && {!isNil 'ffr_ai_rp'} && {!isNil 'ffr_ai_ip'}"];

_aircraft addAction ["<t color='#FF0000'>Jumplight Red</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "red"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull])}"];

_aircraft addAction ["<t color='#00FF00'>Jumplight Green</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "green"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull])}"];

_aircraft addAction ["<t color='#999999'>Jumplight Off</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "off"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull])}"];
};
ffr_main_fnc_prepRamp = {


params ["_aircraft"];

[_aircraft] call ffr_main_fnc_cleanup;
// create static dummy
private _pos = getPosASL _aircraft;
_pos params ["_x", "_y", "_z"];
_helper = "Land_InvisibleBarrier_F" createVehicle [0, 0, 0];
_aircraft setVariable ["ffr_helper", _helper, true];
_helper setPosASL [_x, _y, 0];
_helper setDir getDir _aircraft;
_dummy = createVehicle [typeOf _aircraft, _pos, [], 0, "FLY"];
_dummy allowDamage false;
_dummy lockDriver true;

if (isMultiplayer) then {
    _dummy hideObjectGlobal true;
} else {
    _dummy hideObject true;
};
_dummy attachTo [_helper, [0, -2000, _z]];
_aircraft setVariable ["ffr_dummy", _dummy, true];
_dummy setVariable ["ffr_aircraft", _aircraft, true];

// Sync animations from aircraft to dummy
private _animInfo = [];
private _jumplightPos = [];
if (_aircraft isKindOf "VTOL_01_infantry_base_F") then {
    _animInfo = ["door", ["Door_1_source"]]; // ["_animType", "_anims"]
    _jumplightPos = [0, -7.5, -3];
};
if (_aircraft isKindOf "USAF_C17") then {
    _animInfo = ["", ["back_ramp_switch", "back_ramp", "back_ramp_st", "back_ramp_p", "back_ramp_p_2", "back_ramp_door_main"]];
    _jumplightPos = [0, -6, 3];
};
if (_aircraft isKindOf "USAF_C130J") then {
    _animInfo = ["source", ["ramp_bottom", "ramp_top"]];
    _jumplightPos = [0, -3.2, 3.87];
};
if (_aircraft isKindOf "RHS_C130J") then {
    _animInfo = ["source", ["ramp", "jumplight"]];
    _jumplightPos = [0, -3, -2];
};
private _pfID = [{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_dummy", "_animInfo"];
    _animInfo params ["_animType", "_anims"];
    {
        switch (_animType) do {
            case (""): {
                _dummy animate [_x, _aircraft animationPhase _x, true];
            };
            case ("source"): {
                _dummy animateSource [_x, _aircraft animationSourcePhase _x, true];
            };
            case ("door"): {
                _dummy animateDoor [_x, _aircraft animationSourcePhase _x, true];
            };
        };
    } forEach _anims;
    if (!alive _aircraft || {isNull _dummy}) exitWith {
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
}, 0.1, [_aircraft, _dummy, _animInfo]] call CBA_fnc_addPerFrameHandler;

private _fnc_createJumplight = {
    private _jumplight = "#lightreflector" createVehicle [0,0,0];
    _jumplight
};

private _jumplight = call _fnc_createJumplight;
_jumplight attachTo [_aircraft, _jumplightPos];
_aircraft setVariable ["ffr_jumplight", _jumplight, true];
_dummy setVariable ["ffr_jumplight", _jumplight, true];
private _jumplight_dummy = call _fnc_createJumplight;
_jumplight_dummy attachTo [_dummy, _jumplightPos];
_aircraft setVariable ["ffr_jumplight_dummy", _jumplight_dummy, true];
_dummy setVariable ["ffr_jumplight_dummy", _jumplight_dummy, true];
["ffr_main_setJumplight", [_aircraft, "off"]] call CBA_fnc_globalEvent;

_aircraft addEventHandler ["Deleted", { call ffr_main_fnc_cleanup }];
_aircraft addEventHandler ["Killed", { call ffr_main_fnc_cleanup }];
};
ffr_main_fnc_setJumplight = {


params ["_dummy", "_state"];

private _jumplight = _dummy getVariable ["ffr_jumplight", objNull];
private _jumplight_dummy = _dummy getVariable ["ffr_jumplight_dummy", objNull];
switch (_state) do {
    case ("red"): {
        if (_dummy isKindOf "RHS_C130J") then {
            // Is this the dummy?
            private _realAircraft = _dummy getVariable ["ffr_dummy", objNull];
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
            private _realAircraft = _dummy getVariable ["ffr_dummy", objNull];
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
            private _realAircraft = _dummy getVariable ["ffr_dummy", objNull];
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
};
ffr_main_fnc_standUp = {


params ["_aircraft", "_unit"];

_unit setVariable ["ffr_aircraft", _aircraft, true];
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];

// Move the unit to the static dummy
_unit allowDamage false;
_unit disableCollisionWith _aircraft;
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
if (isNull _dummy) exitWith {};
private _relPos = _aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit);
private _pos = AGLToASL (_dummy modelToWorldVisual _relPos);
_dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
_dummy hideObject false;
moveOut _unit;
_unit setPosASL _pos;
_unit setVelocity [0,0,0];
//if (ffr_testing) then { systemChat "TP to dummy"; };
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
        if (_alt > _rampAltitude || {CBA_missionTime < _time}) then {
            // Fix freefall animation
            //if (ffr_testing) then { systemChat format ["Fix Freefall %1 %2", CBA_missionTime, getPosVisual _unit # 2]; };
            _unit switchMove "";
            _args set [3, CBA_missionTime + 0.5];
        } else {
            // Return to flying aircraft
            private _velAircraft = velocity _aircraft;
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
            [_aircraft, _unit] call ffr_main_fnc_aiJump;
            [{
                _this allowDamage true;
            }, _unit, 0.5] call CBA_fnc_waitAndExecute;
            [_pfID] call CBA_fnc_removePerFrameHandler;
        };
    };
}, 0, [_unit, _aircraft, _dummy, CBA_missionTime + 0.5, (_pos # 2) - 1]] call CBA_fnc_addPerFrameHandler;
};

["ffr_main_prepRamp", { call ffr_main_fnc_prepRamp; }] call CBA_fnc_addEventHandler;
["ffr_main_setJumplight", { call ffr_main_fnc_setJumplight; }] call CBA_fnc_addEventHandler;
["ffr_main_aiFlight", { call ffr_main_fnc_aiFlight; }] call CBA_fnc_addEventHandler;

if (hasInterface) then {
    {
        if (isClass (configFile >> "CfgVehicles" >> _x)) then {
            [_x, "init", { call ffr_main_fnc_prepAircraft; }, true, [], true] call CBA_fnc_addClassEventHandler;
        };
    } forEach ["USAF_C17", "USAF_C130J", "RHS_C130J", "VTOL_01_infantry_base_F"];
};
