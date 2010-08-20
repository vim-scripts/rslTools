


" File:        rslTools.vim
" Description: main file of the RSL tool set plugin
" Maintainer:  Mostafa Ari <mostafa.ari@gmail.com>
" Last Change: 20 Aug 2010



source $VIMRUNTIME/plugin/RslToolsConfigure.vim

if v:version < 700
	finish
endif

"setting vim options
:set bufhidden=hide

if exists("rslt_loaded_rsltools")
  finish
endif
let rslt_loaded_rsltools = 1

let g:rslt_loadedRslFile = ""
let g:rslt_shaderDirectory = ""

if exists("*s:CompileShader")
  finish
endif

"command definitions
if !exists(':RslCompile')
	command! RslCompile 		:call s:CompileShader()
endif
if !exists(':Render')
	command! Render     		:call s:CompileAndRender()
endif
if !exists(':CloseOutWindows')
	command! CloseOutWindows	:call s:CloseOutWindows()
endif 
if !exists(':OpenCloseOptWin')
	command! OpenCloseOptWin	:call s:OpenCloseOptionWindow()
endif


"mappings
map <F5>  :RslCompile<CR><CR>
map <F6>  :Render<CR><CR>
map <F7>  :CloseOutWindows<CR><CR>
map <F8>  :OpenCloseOptWin<CR><CR>


"details
"diferent geometries using for rendering
function! s:Geometery()
	let geomstatement = []
	if g:rslt_render_Object ==? "sphere" && g:rslt_render_this == "" 
		let geomstatement += ["Sphere 1 -1 1 360"]
	elseif g:rslt_render_Object ==? "plane" && g:rslt_render_this == "" 
		let geomstatement += ["Rotate 45 0 1 0"]
		let geomstatement += ["Translate -0.5 -0.2 0.7"]
		let geomstatement += ["Rotate -28 1 0 0"]	
		let geomstatement += ["Polygon \"P\" [ 0 0 1  1 0 1  1 1 1  0 1 1 ]"]
	elseif g:rslt_render_Object ==? "cylinder" && g:rslt_render_this == ""  
		let geomstatement += ["Rotate 90 1 0 0"]
		let geomstatement += ["Rotate 30 -1 1 0"]
		let geomstatement += ["Cylinder 0.8 -0.8 0.8 360"]
	elseif g:rslt_render_Object ==? "torus" && g:rslt_render_this == "" 
		let geomstatement += ["Torus 1 .3 60 90 360"]
	elseif g:rslt_render_Object ==? "teapot" && g:rslt_render_this == "" 
		let geomstatement += ["Scale 0.4 0.4 0.4"]
		let geomstatement += ["Rotate -90 1 0 0"]
		let geomstatement += ["Rotate 20 0 0 1"]
		let geomstatement += ["Translate -0.5 -0.5 -0.5"] 
		let geomstatement += ["Geometry \"teapot\""]
	elseif  g:rslt_render_this != ""
	        let geomstatement += ["ReadArchive " .  g:rslt_render_this ]
	endif

	return geomstatement
endfunction

"details
"make and write rib file
function! s:MakeTempRibFile(fn)
	
	let contents =  ["Orientation \"rh\""]
	let format = "Format " . g:rslt_format . " " . g:rslt_format . " 1"
	let contents += [format]
	let pixelsamples = "PixelSamples " . g:rslt_pixel_samples . " " . g:rslt_pixel_samples
	let contents += [pixelsamples]
	let displaystatement = "Display \"" . g:rslt_display_name . "\" \"" .  g:rslt_display_driver . "\" \"rgba\""
	let contents += [displaystatement]
	let contents += ["Projection \"perspective\" \"fov\" 54.43"]
	let contents += ["Transform [ 0.707107 -0.331295 -0.624695 0  0 0.883452 -0.468521 0  -0.707107 -0.331295 -0.624695 0 0 0 2.62019 1 ]"]
	let stat = "Option \"statistics\" \"int endofframe\" " . string(g:rslt_statistics_level)
	let contents += [stat]
	let contents += ["WorldBegin"]
	"raytracing
	if g:rslt_raytrace == 1 && g:rslt_renderer != "AQSIS"
 		let contents += ["Attribute \"visibility\" \"int diffuse\" [1]"]
		let contents += ["Attribute \"visibility\" \"int specular\" [1]"]
		let contents += ["Attribute \"visibility\" \"int transmission\" [1]"]
		let contents += ["Attribute \"trace\" \"int maxspeculardepth\" [4]"]
	endif
		
	"left light
	if g:rslt_left_light == 1
		let contents += ["TransformBegin"]
		let contents += ["Transform [ 1 0 -0 0  -0 0.707107 -0.707107 0  -0 -0.707107 -0.707107 0  -0.14976 5 5 1 ]"]
		let lightStatement = "LightSource \"spotlight\" \"leftlight\" \"intensity\" " . string(g:rslt_left_light_intensity * 10)		
		let contents += [lightStatement] 
		let contents += ["TransformEnd"]
	endif
	"right light
	if g:right_light == 1
		let contents += ["TransformBegin"]
		let contents += ["Transform [ 0 0 -1 0  -0.707107 0.707107 0 0  -0.707107 -0.707107 -0 0  5 5 0 1 ]"]
		let lightStatement =  "LightSource \"spotlight\" \"rightlight\" \"intensity\" " . string(g:rsl_right_light_intensity * 10)
		let contents += [lightStatement] 
		let contents += ["TransformEnd"]
	endif
	"backlight
	if g:rslt_back_light == 1
		let contents += ["TransformBegin"]
		let contents += ["Transform [ -0.707107 0 0.707107 0  0.696364 0.173648 0.696364 0  0.122788 -0.984808 0.122788 0  -1 6 -1 1] "]
		let lightStatement =  "LightSource \"spotlight\" \"backlight\" \"intensity\" " . string(g:rslt_back_light_intensity * 10)
		let contents += [lightStatement] 
		let contents += ["TransformEnd"]
	endif
	let contents += ["AttributeBegin"]
	let shadingrate = "ShadingRate " . string(g:rslt_shading_rate)
	let contents += [shadingrate]

	if g:rslt_customAttribute1 != ""
		let contents += [g:rslt_customAttribute1]
	endif
	if g:rslt_customAttribute2 != ""
		let contents += [g:rslt_customAttribute2]
	endif
	if g:rslt_customAttribute3 != ""
		let contents += [g:rslt_customAttribute3]
	endif
	if g:rslt_customAttribute4 != ""
		let contents += [g:rslt_customAttribute4]
	endif
	let contents += ["Color " . g:rslt_color]
	let contents += ["Opacity " . g:rslt_opacity]
		
	"surface shader
	if g:rslt_surfaceShader ==? "compile"
"fix me. use the function argumant
		let shaderFileName = expand("%:p:r")
		let shaderstatement = "Surface \"" . shaderFileName . "\""
		let shaderstatement = substitute(shaderstatement,"\\","/","g")
		let contents += [shaderstatement]

	elseif g:rslt_surfaceShader == ""
	
	else
		let contents += ["Surface \"" . g:rslt_surfaceShader . "\""]		
	endif

	"displacement shader
	if g:rslt_displaceShader ==? "compile"
"fix me. use the function argumant
		let shaderFileName = expand("%:p:r")
		let shaderstatement = "Displacement \"" . shaderFileName . "\""
		let shaderstatement = substitute(shaderstatement,"\\","/","g")
		let contents += [shaderstatement]
		let contents += ["Attribute \"displacementbound\" \"float sphere\"" . string(g:rslt_displaceBound)]
                     
	elseif g:rslt_displaceShader == ""
	
	else
		let contents += ["Displacement \"" . g:rslt_displaceShader . "\""]
		let contents += ["Attribute \"displacementbound\" \"float sphere\"" . string(g:rslt_displaceBound)]	
	endif	

	let contents += s:Geometery()
	let contents += ["AttributeEnd"]
	let contents += ["WorldEnd"]

	call writefile(contents,a:fn)

endfunction	

"details
"what is the shader compiler executable name
function! s:GetShaderCommand()
	let shadercommand = ""
	if g:rslt_renderer ==? "PRMAN"
		let shadercommand = "shader"
	elseif g:rslt_renderer ==? "DELIGHT"
		let shadercommand = "shaderdl"
	elseif g:rslt_renderer ==? "AQSIS"
		let shadercommand = "aqsl"
	elseif g:rslt_renderer ==? "PIXIE"
		let shadercommand = "sdrc"
	endif	
	
	return shadercommand
endfunction

"details
"what is the renderer executable name
function! s:GetRenderCommand()
	let rendercommand = ""
	if g:rslt_renderer ==? "PRMAN"
		let rendercommand = "prman"
	elseif g:rslt_renderer ==? "DELIGHT"
		let rendercommand = "renderdl"
	elseif g:rslt_renderer ==? "AQSIS"
		let rendercommand = "aqsis"
	elseif g:rslt_renderer ==? "PIXIE"
		let rendercommand = "rndr"
	endif	
	
	return rendercommand
endfunction

"details
"what is the shader extention
function! s:GetShaderPostfix()
	let postfix = ""
	if g:rslt_renderer ==? "PRMAN"
		let postfix = ".slo"
	elseif g:rslt_renderer ==? "DELIGHT"
		let postfix = ".sdl"
	elseif g:rslt_renderer ==? "AQSIS"
		let postfix = ".slx"
	elseif g:rslt_renderer ==? "PIXIE"
		let postfix = ".sdr"
	endif	
	
	return postfix
endfunction

"details
"close statistics and compile_output windows
function! s:CloseOutWindows()
	
	if bufexists('compile_output')
		bw! compile_output
		"delete the file
		let fileN = g:rslt_shaderDirectory ."compile_output" 
		call delete(fileN) 
	endif
	if bufexists('statistics')
		bw! statistics
		let fileN = g:rslt_shaderDirectory ."statistics" 
		call delete(fileN) 	
	endif
endfunction

"details
"open and close options window
function! s:OpenCloseOptionWindow()
	
	if bufexists($VIMRUNTIME . "/plugin/RslToolsConfigure.vim")
		w!
		bw! RslToolsConfigure.vim
		source $VIMRUNTIME/plugin/RslToolsConfigure.vim	
	else
		bel 50 vs $VIMRUNTIME/plugin/RslToolsConfigure.vim
	endif
endfunction

"details:
"compiling the shader and show compiling messages in a new buffer
function! s:CompileShader()

	"check the extention of the file
	if expand("%:p:e") != "sl"
		echoerr "This is not a shader file.\n"	
		return
	endif
		
	"save sl file before continue
	:write!
	
	"if output buffer exist delete it
	if bufexists('compile_output')
		bw! compile_output
	endif
	
	"creating compiling command and execute it
	let shaderFileName = expand("%:p:r")
	let g:rslt_loadedRslFile = shaderFileName . "sl"		
	let g:rslt_shaderDirectory = expand("%:p:h")
	let includeAddress = ""
	if strlen(g:rslt_include_address) > 0
		let includeAddress = "-I". g:rslt_include_address
	endif
	let shadercompiler = s:GetShaderCommand()
	let shaderPostfix =  s:GetShaderPostfix()
	let commandStr = ":r ! " . shadercompiler . " " . includeAddress . " -o " . shaderFileName . shaderPostfix . " " . shaderFileName . ".sl"
	botright 14 split compile_output
		
	execute commandStr
	if g:rslt_showCompilerMessage == 0
		call s:CloseOutWindows()
	endif
	
endfunction

"details
"compile the shader and render a sample file with this shader as hero object
function! s:CompileAndRender()

	"save sl file before continue
	:write!

	"if statistics buffer exist delete it
	if bufexists('statistics')
		bw! statistics
	endif

	"creating compiling command and execute it
	let shaderFileName = expand("%:p:r")
	let g:rslt_loadedRslFile = shaderFileName 

	call s:CompileShader()

	if bufexists('compile_output')
		bw! compile_output
	endif		

	"creating compiling command and execute it
	
	let filename = shaderFileName . ".rib"
	call s:MakeTempRibFile(filename)
		
	let rendercommand = s:GetRenderCommand()
	let commandStr = ":r ! " . rendercommand . " \"" . filename . "\""
	botright 14 split statistics
	echo commandStr
	execute commandStr

	if g:rslt_showStatistic == 0
		call s:CloseOutWindows()
	endif
endfunction
