//#include "script_component.hpp"
/*
Author: Ampers
Handles Dropping of vehicles in cargo for aircraft

* Arguments:
* 0: aircraft <OBJECT>
*
* Return Value:
* -

* Example:
* _aircraft call ffr_main_fnc_dropcargo = {
*/

if (!hasInterface) exitWith {};

private _dummy = _this getVariable ["ffr_dummy", objNull];
private _vehichles = getVehicleCargo _this;

if (count _vehichles == 0) exitWith {
    hint "No cargo to drop.";
};

{
    private _vicType = typeOf _x;
    private _velAircraft = velocity _this;
    _x allowDamage false;
    private _pos = getPos _x;
    createMarker ["boat", _pos];
    private _dir = _this vectorModelToWorldVisual (_dummy vectorWorldToModelVisual (vectorDir _x));
    private _vel_unit = velocity _x # 2;
    private _velRelease = (_velAircraft vectorMultiply 0.5) vectorAdd [0, 0, _vel_unit];

    private _vic =  createVehicle [_vicType, _pos, [], 0, "FLY"];
    // _x setPosASL _pos;
    _vic setVectorDir _dir;
    _vic setVelocity _velRelease;

    [{
        (getPos _this) select 2 < 1000;
    }, {
        private _pos = getPosASL _this;
        private _strobe = createVehicle ["O_IRStrobe", _pos, [], 0, "CAN_COLLIDE"];
        private _para = createVehicle ["B_Parachute_02_F", _pos, [], 0, "FLY"];
        _para setPosASL _pos;
        _strobe attachTo [_this, [0,0,1]];
        _this attachTo [_para, [0,0,2]];
    }, _vic] call CBA_fnc_waitUntilAndExecute;

} forEach _vehichles;
