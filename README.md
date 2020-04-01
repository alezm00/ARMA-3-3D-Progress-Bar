# ARMA-3-3D-Progress-Bar
3D progress bar for arma 3

## Docs

| Name  | Type  | Description  | Default value  | Optional  | example |
|---|---|---|---|---|---|
| Position  | ARRAY or OBJECT  | ATL Position or object (Static can't attach to a moving object)  |  getPosATL player |   |   |
| Timer  | NUMBER  |   | 15  |   |   |
| Text  | STRING  | Accept structured text  | ""  |   | "Hello World!"  |
| Condition  | CODE  | Executed on every frame  | {}  | X  | {alive player}  |
| onSuccess  | CODE  | Executed on end if success  | {}  | X  | {hint "Nice!"}  |
| onFail  | CODE  | Execute if condition goes FALSE  | {}  | X  | {hint "BAD!"}  |
| Arguments  | ARRAY  | Arguments passed to Condition,onSuccess and onFail [_this select 0]  | []  | X  |   |
| Color  | ARRAY  | RGBA if blank profile  | Profile color  | X  | [1,0,1,1]  |

## Condition, onSuccess  and onFail 
In these 3 parameters you have access to:
`_arguments` parameter
 `_passedTime` (time passed from start)
 `_endTime` (the time when the bar will complete)

## Example
Base example:
```sqf
[
	Player,
	30,
	"Hello World!!",
	{alive player},
	{hint "Completed"},
	{hint "Failed"},
	[],
	[1,0,1,1]
] call AZM_3DPBar;
```

Arguments example:
```sqf
[
	Player,
	30,
	"Hello World!!",
	{alive player},
	{hint (_this select 0 select 0)},
	{hint "Failed"},
	["Nice"]
] call AZM_3DPBar;
```
