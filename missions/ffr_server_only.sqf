// Functions
ffr_main_fnc_aiFlight = {


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
    ['ffr_main_aiVehicleChat', [_a, 'Red Light! Stand up and check equipment!']] call CBA_fnc_globalEvent;
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
};
ffr_main_fnc_aiJump = {


params ["_aircraft", "_unit"];

if (_unit != leader _unit) exitWith {};

private _AIs = units _unit select {
    !isPlayer _x &&
    {vehicle _x == _aircraft} &&
    {(_aircraft getCargoIndex _x) > -1}
};
if (count _AIs == 0) exitWith {};

ffr_AIs = _AIs apply {_x};
// AI teammates eject
[{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_AIs", "_previousAI"];
    if (!isNull _previousAI) then { _previousAI setVelocity velocity _aircraft; };
    private _AI = _AIs # 0;
    _args set [2, _AI];
    moveOut _AI;
    _AIs deleteAt 0;
    if (count _AIs == 0) then {
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
    _args set [1, _AIs];
}, 0.5, [_aircraft, _AIs, objNull]] call CBA_fnc_addPerFrameHandler;

// AI teammates open chute
ffr_ai_playerEH = ["vehicle", {
    params ["_unit", "_newVehicle", "_oldVehicle"];
    if (_newVehicle isKindOf "ParachuteBase") then {
        ffr_ai_openingAlt = getPosASL player # 2;
        [{
            params ["", "_pfID"];
            _args params ["_aircraft", "_AIs", "_previousAI"];
            private _done = true;
            {
                if ((getPosASL _x # 2) > ffr_ai_openingAlt) then {
                    _done = false;
                } else {
                    if (vehicle _x == _x) then {
                        private _vel = velocity _x;
                        _chute = typeOf vehicle player createVehicle [0, 0, 100];
                        _chute setPosASL getPosASL _x;
                        _x moveInAny _chute;
                        _chute setVelocity _vel;
                    };
                };
            } forEach ffr_AIs;
            if (_done) then {
                ffr_AIs = nil;
                ffr_ai_openingAlt = nil;
                [_pfID] call CBA_fnc_removePerFrameHandler;
            };
        }, 0.1] call CBA_fnc_addPerFrameHandler;
        ["vehicle", ffr_ai_playerEH] call CBA_fnc_removePlayerEventHandler;
    };
}] call CBA_fnc_addPlayerEventHandler;
};
ffr_main_fnc_cleanUp = {


params ["_aircraft"];

{
    deleteVehicle (_aircraft getVariable [_x, objNull]);
    _aircraft setVariable [_x, nil];
} forEach ["ffr_dummy", "ffr_helper", "ffr_jumplight", "ffr_jumplight_dummy"];
};

ffr_main_fnc_planFlight = {


params ["_aircraft", "_unit"];

if (!isNil "ffr_ai_acMarker") then { deleteMarker ffr_ai_acMarker; };
private _markerName = format ["_USER_DEFINED #%1/ffr_ai_ac/%2", clientOwner, currentChannel];
private _pos = getPos _aircraft;
private _markerText = format ["%1", groupId group _aircraft];
private _markerType = switch (side _aircraft) do {
    //cases (insertable by snippet)
    case (west): {"b_plane"};
    case (east): {"o_plane"};
    case (independent): {"n_plane"};
    case (civ): {"c_plane"};
};
ffr_ai_acMarker = format [
    "|%1|%2|%3|ICON|[1,1]|0|Solid|Default|1|%4",
    _markerName,
    _pos,
    _markerType,
    _markerText
] call BIS_fnc_stringToMarkerLocal;
ffr_ai_acMarker setMarkerAlpha 1;

if (!isNil "ffr_ai_pfID") then {
    [ffr_ai_pfID] call CBA_fnc_removePerFrameHandler;
};
ffr_ai_pfID = [{
    params ["_aircraft", "_pfID"];
    _args params ["_aircraft"];
    ffr_ai_acMarker setMarkerPos _aircraft;
    if (!alive _aircraft) then {
        deleteMarker ffr_ai_acMarker;
        [_pfID] call CBA_fnc_removePerFrameHandler;
    };
}, 0.1, _aircraft] call CBA_fnc_addPerFrameHandler;

if (!isNil "ffr_ai_ipMarker") then { deleteMarker ffr_ai_ipMarker; };
if (!isNil "ffr_ai_rpMarker") then { deleteMarker ffr_ai_rpMarker; };
missionNamespace setVariable ["ffr_ai_ip", nil];
missionNamespace setVariable ["ffr_ai_rp", nil];
missionNamespace setVariable ["ffr_ai_ipMarker", nil];
missionNamespace setVariable ["ffr_ai_rpMarker", nil];

openMap true;
hint "Click to select Initial Point";
onMapSingleClick {
    missionNamespace setVariable ["ffr_ai_ip", _pos];
    private _markerName = format ["_USER_DEFINED #%1/ffr_ai_ip/%2", clientOwner, currentChannel];
    private _markerText = format ["IP - %1", groupId group player];
    private _ipMarker = format [
        "|%1|%2|mil_start|ICON|[1,1]|0|Solid|Default|1|%3",
        _markerName,
        _pos,
        _markerText
    ] call BIS_fnc_stringToMarkerLocal;
    _ipMarker setMarkerAlpha 1;
    missionNamespace setVariable ["ffr_ai_ipMarker", _ipMarker];

    hint "Click to select Release Point";
    onMapSingleClick {
        missionNamespace setVariable ["ffr_ai_rp", _pos];
        private _markerName = format ["_USER_DEFINED #%1/ffr_ai_rp/%2", clientOwner, currentChannel];
        private _markerText = format ["RP - %1", groupId group player];
        private _rpMarker = format [
            "|%1|%2|mil_end|ICON|[1,1]|0|Solid|Default|1|%3",
            _markerName,
            _pos,
            _markerText
        ] call BIS_fnc_stringToMarkerLocal; // Local marker commands
        _rpMarker setMarkerAlpha 1; // Global to send only completed marker
        missionNamespace setVariable ["ffr_ai_rpMarker", _rpMarker];
        onMapSingleClick {};
        if (ffr_altitude_menu) then {
            hint "Select the Release Altitude";
            createDialog "ffr_altitude_menu";
            private _okButton = (findDisplay 7777) displayCtrl 1;
            private _altFullForce = getNumber (configOf vehicle player >> "altFullForce");
            _okButton ctrlSetText (format ["Release Altitude %1 m", _altFullForce]);
            missionNamespace setVariable ["ffr_ai_alt", _altFullForce];
            private _slider = (findDisplay 7777) displayCtrl 1900;
            _slider sliderSetPosition _altFullForce;
            _slider ctrlAddEventHandler ["SliderPosChanged", {
                params ["_control", "_newValue"];
                private _okButton = (findDisplay 7777) displayCtrl 1;
                _okButton ctrlSetText format ["Release Altitude %1 m", _newValue];
                missionNamespace setVariable ["ffr_ai_alt", _newValue];
            }];
        } else {
            private _altFullForce = getNumber (configOf vehicle player >> "altFullForce");
            missionNamespace setVariable ["ffr_ai_alt", _altFullForce];
            private _mkr = (missionNamespace getVariable 'ffr_ai_rpMarker');
            _mkr setMarkerText format ['%1 - %2 m', markerText _mkr, _altFullForce];
            hint 'Flight plan set';
            ffr_aiFlightReady = true;
        };
    };
};
};
ffr_main_fnc_prepAircraft = {


params ["_aircraft"];

private _isHeli = _aircraft isKindOf "Helicopter";
if (!_isHeli) then {
    _aircraft addAction ["Plan AI Flight", {
        call ffr_main_fnc_planFlight;
    }, nil, 0, true, true, "", "!isNull driver _target && { !isPlayer driver _target } && { _this in _target } && {_this == leader _this}"];

    _aircraft addAction ["Begin AI Flight", {
        params ["_aircraft"];
        ffr_aiFlightReady = false;
        ["ffr_main_aiFlight", [_aircraft, ffr_ai_alt, ffr_ai_rp, ffr_ai_ip], _aircraft] call CBA_fnc_targetEvent;
    }, nil, 0, true, true, "", "ffr_aiFlightReady"];
};

_aircraft addAction ["Prep Ramp for Free Fall", {
    params ["_aircraft"];
    ["ffr_main_prepRamp", [_aircraft]] call CBA_fnc_serverEvent;
}, nil, 0, false, true, "", "isNull (_target getVariable ['ffr_dummy', objNull]) && {(getPos _target # 2) > 200 && {_this == driver _target || {!isNull driver _target && {!isPlayer driver _target} && {_this == leader _this}}}}"];

_aircraft addAction ["Stand Up", {
    call ffr_main_fnc_standUp;
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_dummy', objNull]) && {_this in _target} && {_this != driver _target}"];

_aircraft addAction ["<t color='#FF0000'>Jumplight Red</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "red"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull]) && {_this == leader _this || {_this in group driver _target}}}"];

_aircraft addAction ["<t color='#00FF00'>Jumplight Green</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "green"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull]) && {_this == leader _this || {_this in group driver _target}}}"];

_aircraft addAction ["<t color='#999999'>Jumplight Off</t>", {
    params ["_aircraft"];
    ["ffr_main_setJumplight", [_aircraft, "off"]] call CBA_fnc_globalEvent;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_jumplight', objNull]) && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull]) && {_this == leader _this || {_this in group driver _target}}}"];

_aircraft addAction ["<t color='#999999'>Secure Ramp from Free Fall</t>", {
    params ["_aircraft"];
    [_aircraft] call ffr_main_fnc_cleanUp;
}, nil, 0, false, false, "", "!isNull (_target getVariable ['ffr_dummy', objNull]) && {!isNull (_target getVariable ['ffr_jumplight', objNull])} && {!isNull (_target getVariable ['ffr_jumplight_dummy', objNull]) && {_this == leader _this || {_this in group driver _target}}}"];
};


ffr_main_fnc_prepDummy = {

if (!hasInterface) exitWith {};

_this addAction ["<t color='#999999'>Sit Down</t>", {
    params ["_dummy", "_unit"];
    private _aircraft = _dummy getVariable "ffr_aircraft";
    [{
        params ["_unit", "_aircraft"];
        _unit moveInCargo _aircraft;
        vehicle _unti == _aircraft
    }, {}, [_unit, _aircraft], 5] call CBA_fnc_waitUntilAndExecute;
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_aircraft', objNull])"];

};

ffr_main_fnc_prepRamp = {

params ["_aircraft", ["_openRamp", false]];

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

["ffr_main_prepDummy", _dummy] call CBA_fnc_globalEvent;

// Open ramp
private _jumpInfo = _aircraft getVariable "ffr_jumpInfo";
_jumpInfo params ["_animInfo", "_jumplightPos"];
_animInfo params ["_animType", "_anims", ["_animPhase", 1]];
{
    switch (_animType) do {
        case (""): {
            _aircraft animate [_x, _animPhase];
        };
        case ("source"): {
            _aircraft animateSource [_x, _animPhase];
        };
        case ("door"): {
            _aircraft animateDoor [_x, _animPhase];
        };
    };
} forEach _anims;

// Sync animations from aircraft to dummy
private _pfID = [{
    params ["_args", "_pfID"];
    _args params ["_aircraft", "_dummy", "_animInfo"];
    _animInfo params ["_animType", "_anims"];
    {
        [_dummy, [_x, 1]] call _fnc_animateRamp;
    } forEach _animations;
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
_jumplight attachTo [_aircraft, _jumplightPos vectorAdd [0, -0.015 * speed _aircraft, 0]]; // Light position is offset and flickers due to vehicle speed
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
};


ffr_main_fnc_standUp = {

params ["_aircraft", "_unit"];

// Move the unit to the static dummy
private _dummy = _aircraft getVariable ["ffr_dummy", objNull];
if (isNull _dummy) exitWith {};

private _relPos = _aircraft worldToModelVisual (ASLToAGL getPosWorldVisual _unit);
private _pos = AGLToASL (_dummy modelToWorldVisual _relPos);
_dir = _dummy vectorModelToWorldVisual (_aircraft vectorWorldToModelVisual (vectorDir _unit));
_dummy hideObject false;
_unit allowDamage false;
_unit setUnitFreefallHeight (((ASLToAGL _pos) select 2) + 5);
moveOut _unit;
_unit setPosASL _pos;
_unit setVelocity [0,0,0];
//if (ffr_testing) then { systemChat "TP to dummy"; };
_unit setVectorDir _dir;
_unit switchMove "";

[{ _this allowDamage true; }, _unit, 2] call CBA_fnc_waitAndExecute;

[{
    params ["_args", "_pfID"];
    _args params ["_unit", "_aircraft", "_dummy", "_height", "_timeStandSafe"];

    private _alt = getPosASL _unit # 2;

    if (vehicle _unit != _aircraft && {_alt > _height}) exitWith {}; // Safe

    [_pfID] call CBA_fnc_removePerFrameHandler;
    _unit setUnitFreefallHeight -1;

    // Unit got squeezed out
    if (CBA_missionTime < _timeStandSafe) exitWith {
        _unit moveInCargo _aircraft;
    };

    // Return to flying aircraft for free fall
    private _velAircraft = velocity _aircraft;
    _unit allowDamage false;
    private _pos = _aircraft modelToWorldVisualWorld (_dummy worldToModelVisual (ASLToAGL getPosWorldVisual _unit));
    private _dir = _aircraft vectorModelToWorldVisual (_dummy vectorWorldToModelVisual (vectorDir _unit));
    private _vel_unit = velocity _unit # 2;
    private _velRelease = (_velAircraft vectorMultiply 0.9) vectorAdd [0, 0, _vel_unit];

    _unit setPosASL _pos;
    _unit setVectorDir _dir;
    _unit setVelocity _velRelease;
    _dummy hideObject true;

    [_aircraft, _unit] call ffr_main_fnc_aiJump;

    [{_this allowDamage true;}, _unit, 0.5] call CBA_fnc_waitAndExecute;
}, 0, [_unit, _aircraft, _dummy, _pos # 2 - 2, CBA_missionTime + 5]] call CBA_fnc_addPerFrameHandler;
};

ffr_altitude_menu = isClass (configFile >> 'ffr_altitude_menu') || {isClass (missionConfigFile >> 'ffr_altitude_menu')};

["ffr_main_prepDummy", { call ffr_main_fnc_prepDummy; }] call CBA_fnc_addEventHandler;
["ffr_main_prepRamp", { call ffr_main_fnc_prepRamp; }] call CBA_fnc_addEventHandler;
["ffr_main_setJumplight", { call ffr_main_fnc_setJumplight; }] call CBA_fnc_addEventHandler;
["ffr_main_aiFlight", { call ffr_main_fnc_aiFlight; }] call CBA_fnc_addEventHandler;


// Aircraft specific inits
private _cfgVehicles = configFile >> "CfgVehicles";
private _class = "";

_class = "VTOL_01_infantry_base_F";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["door", ["Door_1_source"]], // _animInfo
            [0, -7.5, -3]                // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "USAF_C17";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["back_ramp_switch", "back_ramp", "back_ramp_st", "back_ramp_p", "back_ramp_p_2", "back_ramp_door_main"]],    // _animInfo
            [0, -6, 3]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "USAF_C130J";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -3.2, 3.87]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "RHS_C130J";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp", "jumplight"]],    // _animInfo
            [0, -3, -2]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "RHS_CH_47F";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_anim"]],    // _animInfo
            [0, -4.2, -0.75]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "ffaa_famet_ch47_mg";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ani_Rampa"]],    // _animInfo
            [0, -4.2, -0.75]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "ffaa_ea_hercules";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -3.2, 3.87]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "ffaa_ea_hercules_camo";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -3.2, 3.87]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "CUP_C130J_Base";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -5, -2.01]                  // _jumplightPos
        ]];
    }, true, ["CUP_C130J_VIV_Base"], true] call CBA_fnc_addClassEventHandler;
};

_class = "CUP_B_MV22_USMC";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["door", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -3, -0.6]                  // _jumplightPos
        ]];
    }, true, ["CUP_B_MV22_VIV_USMC"], true] call CBA_fnc_addClassEventHandler;
};

_class = "CUP_B_MV22_USMC";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["door", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -3, -0.6]                  // _jumplightPos
        ]];
    }, false, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "CUP_B_MV22_VIV_USMC";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["door", []],    // _animInfo
            [0, -3, -0.6]                  // _jumplightPos
        ]];
    }, false, [], true] call CBA_fnc_addClassEventHandler;
};

// CH47 with ramp gun doesn't let you run out
_class = "CUP_MH47E_base";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["source", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -5, -2.01]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "CUP_MI6T_Base";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_bottom2", "ramp_leftdoor", "ramp_rightdoor"]],    // _animInfo
            [0, -3.6, 0.95]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "UK3CB_BAF_Merlin_HC3_Unarmed_Base";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["door", ["CargoRamp_Open"]],    // _animInfo
            [0.21, -0.70, -0.45]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "TF373_SOAR_MH47G";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["Ramp"], 0],    // _animInfo
            [0.21, -0.70, -0.45]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "I_IBrasilAirForceLizard_C130_Hercules_01";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -4.6, -2]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "sab_C130_J";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, 0.3, -2]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "TFC_CC130_Base";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, 0.3, -2]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "AMF_PLANE_TRANSPORT_01_base_F";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_top"]],    // _animInfo
            [0, -2.8, 4.3]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

_class = "A400M_base_F";
if (isClass (configFile >> "CfgVehicles" >> _class)) then {
    [_class, "init", {
        params ["_aircraft"];
        [_aircraft] call ffr_main_fnc_prepAircraft;
        _aircraft setVariable ["ffr_jumpInfo", [
            ["", ["ramp_bottom", "ramp_bottom2", "ramp_top"]],    // _animInfo
            [0, -7.1, 5.5]                  // _jumplightPos
        ]];
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};
