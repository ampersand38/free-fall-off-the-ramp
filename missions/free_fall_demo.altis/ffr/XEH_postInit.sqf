ffr_altitude_menu = isClass (configFile >> 'ffr_altitude_menu') || {isClass (missionConfigFile >> 'ffr_altitude_menu')};

["ffr_main_prepRamp", { call ffr_main_fnc_prepRamp; }] call CBA_fnc_addEventHandler;
["ffr_main_setJumplight", { call ffr_main_fnc_setJumplight; }] call CBA_fnc_addEventHandler;
["ffr_main_aiFlight", { call ffr_main_fnc_aiFlight; }] call CBA_fnc_addEventHandler;
["ffr_main_aiVehicleChat", {
    params ["_aircraft", "_msg"];
    _aircraft vehicleChat _msg;
}] call CBA_fnc_addEventHandler;

if (hasInterface) then {
    private _class = "";

    _class = "VTOL_01_infantry_base_F";
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        [_class, "init", {
            params ["_aircraft"];
            [_aircraft] call ffr_main_fnc_prepAircraft;
            _aircraft setVariable ["ffr_jumpInfo", [
                ["door", ["Door_1_source"]], // _animInfo
                [0, -7.5, -3]                // _jumplightPos
            ], true];
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
            ], true];
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
            ], true];
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
            ], true];
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
            ], true];
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
            ], true];
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
            ], true];
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
            ], true];
        }, true, [], true] call CBA_fnc_addClassEventHandler;
    };
};
