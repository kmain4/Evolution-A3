[{
<<<<<<< HEAD
	titleCut ["","BLACK IN", 0];
=======
>>>>>>> origin/altis
	currentSideMission = "aaHunt";
	publicVariable "currentSideMission";
	if (isServer) then {
	//server
		_vehicle = aaHuntTarget;
		currentSideMissionMarker = format ["sidemission_%1", markerCounter];
		_aaMarker = createMarker [currentSideMissionMarker, position _vehicle ];
		currentTargetMarkerName setMarkerShape "ELLIPSE";
		currentTargetMarkerName setMarkerBrush "Border";
		currentSideMissionMarker setMarkerSize [200, 200];
		currentSideMissionMarker setMarkerColor "ColorEAST";
		currentSideMissionMarker setMarkerPos (GetPos _vehicle);
		markerCounter = markerCounter + 1;
		publicVariable "currentSideMissionMarker";
		for "_i" from 1 to 2 do {
			_spawnPos = [getPos _vehicle, 10, 300, 10, 0, 2, 0] call BIS_fnc_findSafePos;
			_grp = [_spawnPos, EAST, (configFile >> "CfgGroups" >> "EAST" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam")] call BIS_fnc_spawnGroup;
			if (HCconnected) then {
				{
					handle = [_x] call EVO_fnc_sendToHC;
				} forEach units _grp;
			};
			{
				_x addEventHandler ["Killed", {_this spawn EVO_fnc_onUnitKilled}];
			}  forEach units _grp;
			_null = [(leader _grp), currentSideMissionMarker, "RANDOM", "NOSMOKE", "DELETE:", 80, "SHOWMARKER"] execVM "scripts\UPSMON.sqf";
		};
		handle = [] spawn {
			waitUntil {!alive aaHuntTarget};
			sleep (random 15);
			currentSideMission = "none";
			publicVariable "currentSideMission";
			handle = [] spawn EVO_fnc_buildSideMissionArray;
			deleteMarker currentSideMissionMarker;
		};
	};
	if (!isServer || !isMultiplayer) then {
	//client
		aaTask = player createSimpleTask ["Destroy AAA Battery"];
		aaTask setTaskState "Created";
		aaTask setSimpleTaskDestination (getMarkerPos currentSideMissionMarker);
		["TaskAssigned",["","Destroy AAA Battery"]] call BIS_fnc_showNotification;
		handle = [] spawn {
			waitUntil {!alive aaHuntTarget};
			if (player distance aaHuntTarget < 1000) then {
				playsound "goodjob";
				_score = player getVariable "EVO_score";
				_score = _score + 10;
				player setVariable ["EVO_score", _score, true];
				["PointsAdded",["BLUFOR completed a sidemission.", 10]] call BIS_fnc_showNotification;
			};
			sleep (random 15);
			aaTask setTaskState "Succeeded";
			["TaskSucceeded",["","AAA Battery Destroyed"]] call BIS_fnc_showNotification;
			currentSideMission = "none";
			publicVariable "currentSideMission";
		};
	};
},"BIS_fnc_spawn",true,true] call BIS_fnc_MP;