//#include "script_component.hpp"
/*
Author: Ampers
Move unit out of aicraft seat to standing in ViV space

* Arguments:
* 0: Unit <OBJECT>
*
* Return Value:
* -

* Example:
* [_aircraft, _unit] call ffr_main_fnc_planFlight = {
*/

params ["_aircraft", "_unit"];

if (!isNil "ffr_ai_acMarker") then { deleteMarker ffr_ai_acMarker; };
private _markerName = format ["_USER_DEFINED #%1/ffr_ai_ac/%2", clientOwner, currentChannel];
private _pos = getPos _aircraft;
private _markerText = format ["%1", groupId group _aircraft];
private _markerType = switch (side _aircraft) do {
    //cases (insertable by snippet)
    case (west): {"b_plane"};
    case (east): {"o_plane"};
    case (guer): {"n_plane"};
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
