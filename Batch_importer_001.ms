rollout ImporterRollout "FBX Batch Importer" width:250 height:295
(
	---------------
	-- UI PANELS --
	---------------

	group "Path Setting"
	(
		label lab_path "Path:" across:3 align:#left width:24 height:16 
		editText edit_path align:#left width:180 height:18 offset:[-45,0] text:(Getdir #Export)
		button btn_past width:18 height:18 align:#Right offset:[8,0] toolTip:"Past Path From ClipBoard"
	)
	group "Import Setting"
	(
		label lab_upaxis "Up Axis" across:2 align:#left offset:[0,5]
		dropdownlist drop_upaxis items:#("Z - Up", "Y - Up") align:#Right width:104 height:16
		
		label lab_pivot "Pivot placement" across:2 align:#left offset:[0,5]
		dropdownlist drop_pivot items:#("None", "Bottom Left", "Bottom Center", "Bottom Right") align:#Right width:104 height:16	
		
		checkbox cbScaleConv "Scale conversion" across:2 align:#left offset:[0,0]		
		spinner spinScale "Scale" range:[0,100000000,1] type:#float	

		checkbox cb000 "Place at 0,0,0" across:1 align:#left offset:[0,0]
		checkbox cbXform "Reset XFORM" across:1 align:#left offset:[0,0]


	)
	group "Import"
	(
		button btn_convert "Batch Import / Convert" width:200 height:24 align:#center
	)

	---------------
	-- FUNCTIONS --
	---------------
	
	
	on btn_past pressed do --PATH from clipboard
	(
		edit_path.text = getclipboardText()
	)

	fn axisoption = --UP axis option
	(
		if drop_upaxis.selection == 1 then 
			(
				FBXImporterSetParam "UpAxis" "Z"
			)
			else
			(
				FBXImporterSetParam "UpAxis" "Y"
			)
	)

	fn pivotPlacement NEWOBJECT = --Pivot position option
	(
		if drop_pivot.selection == 2 then
			(
				select NEWOBJECT
				$.pivot = [$.min.x,$.center.y,$.min.z]
			)
		else if drop_pivot.selection == 3 then
			(
				select NEWOBJECT
				$.pivot = [$.center.x,$.center.y,$.min.z]
			)
		else if drop_pivot.selection == 4 then
			(
				select NEWOBJECT
				$.pivot = [$.max.x,$.center.y,$.min.z]
			)
	)

	fn place000 NEWOBJECT =
	(
		select NEWOBJECT
		$.position = [0,0,0]
	)
	
	fn scaleConv = --Scale conversion
	(			
	FBXImporterSetParam "ScaleConversion" cbScaleConv.checked
	FBXImporterSetParam "ScaleFactor" spinScale.value
	)

	fn f_resetXform FILE =
	(
		ResetXForm FILE
		convertTo FILE PolyMeshObject
	)

	fn importgo = --Final import
	(
		tempPath = edit_path.text
		toImport = getFiles (tempPath+"\\*.fbx")
		oldObj = objects as array
		for file in toImport do 
			(
				importFile file #noprompt --import file
				newObj = for o in objects where findItem oldObj o == 0 collect o --select new object in scene
				pivotPlacement newObj --pivot placement check
				if cb000.checked then 
					(
						place000 newObj
					)	
				if cbXform.checked then --Reset XFORM check
				(
					f_resetXform newObj
				)	
			)
	)
	
	------------
	-- IMPORT --
	------------
	
	on btn_convert pressed do
	(
	axisoption()
	scaleConv()
	importgo()
	)
)

pluginManager.loadClass FBXIMPORTER --FBX plugin load
CreateDialog ImporterRollout --Create UI