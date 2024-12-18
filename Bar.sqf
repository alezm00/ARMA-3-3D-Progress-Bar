/*
Function: AZM_3DPBar
Author:
	Alezm
Description:
    3D progress bar for arma 3
Parameters:
    _position		- ATL Position or object (this is static can't attach to a moving object) <ARRAY or OBJECT>
    _counter  		- Time for the progress bar to complete <NUMBER>
    _text  			- Text displayed in the bat (Accept structured text) <STRING>
    _condition  	- Execute every frame. If reports false, close the progress bar <CODE>
    _onSuccess  	- Script to execute if the progress bar completed (optional, default: {}) <CODE>
    _onFailure  	- Script to execute if the progress bar was aborted prematurely (optional, default: {}) <CODE>
	_arguments		- Arguments passed to the scripts (optional, default: []) <ANY>
    _color 			- Progress bar color (optional, default: Profile color) <ARRAY>
Arguments:
    _this:
        #0 - same as _arguments <ANY>
        #1 - _passedTime <NUMBER>
        #2 - _endTime <NUMBER>
        #3 - _isOutOfArea <BOOLEAN>
Returns:
    Nothing
Examples:
    https://github.com/alezm00/ARMA-3-3D-Progress-Bar#example
*/



AZM_3DPBar = {
	// if (!hasInterface) exitWith {};
	params [
		["_position",getPosATL player,[[],objNull]],
		["_counter",15,[0]],
		["_text","",[""]],
		["_condition",{true},[{true}]],
		["_onSuccess",{},[{true}]],
		["_onFailure",{},[{true}]],
		["_arguments", []],
		["_color","",[[],""]]
	];
    _posisOBJ = false;
	if (_position isEqualType objNull) then {
        _posisOBJ = true;
	};
	if (_color isEqualType []) then {
		_color = _color;
	} else {
		_color = [(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843]),(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019]),(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862]),1]
	};
	if (isLocalized _text) then {
		_text = localize _text;
	};
	private _background = findDisplay 46 ctrlCreate ["RscText", -1];
	_background ctrlSetPosition [-10,0,0.3 * safezoneW,0.03 * safezoneH];
	_background ctrlSetBackgroundColor [0,0,0,0.3];


	private _progressBar = findDisplay 46 ctrlCreate ["RscProgress", -1];
	_progressBar ctrlSetPosition [0,-10,0.3 * safezoneW,0.03 * safezoneH];
	_progressBar progressSetPosition 0;
	_progressBar ctrlSetTextColor _color;
	_progressBar ctrlSetBackgroundColor [0,0,0,1];


	private _textBar = findDisplay 46 ctrlCreate ["RscStructuredText", -1];
	_textBar ctrlSetPosition [0,-10,0.3 * safezoneW,0.03 * safezoneH];

	private _array = [_background,_progressBar,_textBar];
	{
		_x ctrlSetFade 1;
		_x ctrlCommit 0;
		_x ctrlSetFade 0;
		_x ctrlCommit .5;
	} count _array;


	_count = missionNamespace getVariable ["AZM_3DPBar_progressbar_counter",0];
	missionNamespace setVariable ["AZM_3DPBar_progressbar_counter",(_count + 1)];
	[format["AZM_3DPBar_event_%1",_count + 1], "onEachFrame", {
		params[ "_startTime", "_endTime","_text","_position","_posisOBJ","_controls","_count","_code"];
		_controls params ["_background","_progressBar","_textBar"];
		_code params ["_condition","_onSuccess","_onFailure","_arguments"];


		private _passedTime = time - _startTime;
		_isOutOfArea = (player distance _position) > 15;
		// call condition
		private _conditionCheck = [_arguments, _passedTime, _endTime, _isOutOfArea] call _condition;

		// if condition is false then delete the bar and the event and call _onFailure
		if (!_conditionCheck) exitWith {

			{
				_x ctrlSetFade 1;
				_x ctrlCommit 0.5;
				ctrlDelete _x;
			} count _controls;
			[_arguments, _passedTime, _endTime] call _onFailure;
			[format["AZM_3DPBar_event_%1",(_count + 1)],"onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		};
		private _progress = linearConversion[ _startTime, _endTime, time, 0, 1 ];
		_progressBar progressSetPosition _progress;


		//hide out of screen
		{_x ctrlSetPosition [0,-30];} count _controls;

		//set text
		_textBar ctrlSetStructuredText parseText format["<t align='center'>%1</t>",_text];

		//gen variables
		_hide = false;
		//positions
        _positionCoords = [];
        if (_posisOBJ) then {
            _positionCoords = _position modelToWorldVisual [0,0,0];
        } else {
            _positionCoords = _position
        };
		_pos = (worldToScreen _positionCoords);
		_pos params ["_posx","_posy"];

		//calculate scall and x translation to center
		private _scale = linearConversion [0,15,(player distance _positionCoords),1,0.75];
		_divisore = linearConversion [1,0.75,_scale,2,2.50];
		_newpos = [_posx - ((0.3 * safezoneW)/_divisore),_posy];

		// check if is visible and if there is nothing between player and progress bar pos
		if (!(_newpos select 0 > 25 || _newpos select 0 < -25) && !(_newpos select 1 > 15 || _newpos select 1 < -15)) then {
			// update position of hte bar
			{_x ctrlSetPosition _newpos;} count _controls;
		} else {
			_hide = true;
		};
		{
			_x ctrlSetScale _scale;
			_x ctrlSetFade 0;
			// hide bar if scale <0.8 or _hide is true
			if (_scale < 0.8 || _hide) then {
				_x ctrlSetFade 1;
			};
			_x ctrlCommit 0;
		} count _controls;
		//execute only on finish
		if (_progress >= 1) then {
			//remove event
			//hide and delete bar
			{
				_x ctrlSetFade 1;
				_x ctrlCommit 0.5;
				ctrlDelete _x;
			} count _controls;
			//call _onSuccess code passing parameters
			[_arguments, _passedTime, _endTime] call _onSuccess;
			[format["AZM_3DPBar_event_%1",(_count + 1)],"onEachFrame"] call BIS_fnc_removeStackedEventHandler;
		};

	}, [ time, time + _counter,_text,_position,_posisOBJ,_array,_count,[_condition,_onSuccess,_onFailure,_arguments]] ] call BIS_fnc_addStackedEventHandler;
	missionNamespace setVariable ["AZM_3DPBar_controls",_array];
};
