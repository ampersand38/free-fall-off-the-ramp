import RscSlider;
import RscButtonMenuOK;
class ffr_altitude_menu {
    idd = 7777;
    class controls {
        class ffr_altitude_slider: RscSlider
        {
        	idc = 1900;
        	text = "Altitude"; //--- ToDo: Localize;
        	x = 0.296875 * safezoneW + safezoneX;
        	y = 0.4375 * safezoneH + safezoneY;
        	w = 0.41025 * safezoneW;
        	h = 0.055 * safezoneH;
            sliderPosition = 10000;
            sliderRange[] = {1000, 15000};
            sliderStep = 500;
        	deletable = 0;
        	fade = 0;
        	type = 3;
        	style = 1024;
        	color[] =
        	{
        		1,
        		1,
        		1,
        		0.8
        	};
        	colorActive[] =
        	{
        		1,
        		1,
        		1,
        		1
        	};
        	shadow = 0;
        };
        class ffr_altitude_ok: RscButtonMenuOK
        {
        	x = 0.296875 * safezoneW + safezoneX;
        	y = 0.510417 * safezoneH + safezoneY;
        	w = 0.41025 * safezoneW;
        	h = 0.055 * safezoneH;
        	idc = 1;
        	shortcuts[] =
        	{
        		"0x00050000 + 0",
        		28,
        		57,
        		156
        	};
        	default = 1;
        	text = "OK";
        	soundPush[] =
        	{
        		"\A3\ui_f\data\sound\RscButtonMenuOK\soundPush",
        		0.09,
        		1
        	};
            action = "private _mkr = (missionNamespace getVariable 'ffr_ai_rpMarker'); _mkr setMarkerText format ['%1 - %2 m', markerText _mkr, ffr_ai_alt]; hint 'Flight plan set'; ffr_aiFlightReady = true;";
        };
    };
};
