//#include "script_component.hpp"
/*
Author: Ampers
Creates local actions for  dummy

* Arguments:
* 0: Dummy <OBJECT>
*
* Return Value:
* -

* Example:
* _dummy call ffr_main_fnc_prepDummy = {
*/

// Helper function to add drop vehicle action on clients
ffr_main_fnc_addCargoAction = {
    params ["_cargoVic"];

    // Wait for vehicle to exist on this client
    waitUntil {
        !isNull _cargoVic
    };

    _cargoVic setPhysicsCollisionFlag false;


    _cargoVic addAction ["Drop Vehicle", {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _oldVic = _target getVariable ["ffr_cargo_original", objNull];
        if (isNull _oldVic) exitWith {};


        objNull setVehicleCargo _oldVic;
        private _strobe = createVehicle ["O_IRStrobe", getPos _oldVic, [], 0, "CAN_COLLIDE"];
        _strobe attachTo [_oldVic, [0,0,1]];

        // Get the dummy aircraft from the dummy vehicle's variable
        private _dummyAircraft = _target getVariable ["ffr_dummy_aircraft", objNull];

        if (!isNull _dummyAircraft) then {
            // Run animation on all clients for visibility, then delete on server
            [_dummyAircraft, _target] remoteExec ["ffr_main_fnc_animateVic", 0];
        } else {
            // Fallback: delete immediately if we can't find dummy aircraft
            deleteVehicle _target;
        };
    }, nil, 0, true, true, "", "!isNull (isVehicleCargo _target)"];
};

//prep actions for dropping cargo (server only)
if (isServer) then {
    private _aircraft = _dummy getVariable "ffr_aircraft";
    private _vics = getVehicleCargo _aircraft;

    {
        private _newVic = createVehicle [typeOf _x, position _x, [], 0, "CAN_COLLIDE"];
        _newVic setPhysicsCollisionFlag false;
        _newVic allowDamage false;
        _newVic setVariable ["ffr_cargo_original", _x, true];
        _newVic setVariable ["ffr_dummy_aircraft", _dummy, true]; // Store dummy aircraft reference
        _dummy setVehicleCargo _newVic;

        // Tell all clients to add the drop action to this vehicle
        [_newVic] remoteExec ["ffr_main_fnc_addCargoAction", 0];
    } forEach _vics;
};

if (!hasInterface) exitWith {};

_this addAction ["<t color='#999999'>Sit Down</t>", {
    params ["_dummy", "_unit"];
    private _aircraft = _dummy getVariable "ffr_aircraft";
    _unit setVariable ['ffr_in_aircraft_bay', false, true];
    _unit setVariable ['ffr_static_line_hooked', false, true];
    [{
        params ["_unit", "_aircraft"];
        _unit moveInCargo _aircraft;
        vehicle _unit == _aircraft
    }, {}, [_unit, _aircraft], 5] call CBA_fnc_waitUntilAndExecute;
}, nil, 0, true, true, "", "!isNull (_target getVariable ['ffr_aircraft', objNull])"];


