


" File:        RslToolsConfigure.vim
" Description: option setting file of the RSL tool set plugin
" Maintainer:  Mostafa Ari <mostafa.ari@gmail.com>
" Last Change: 20 Aug 2010

if v:version < 700
	finish
endif



"tool options
let g:rslt_renderer = "DELIGHT"			"render engine for shader compiling and render use one of the DELIGHT,PRMAN,AQSIS,PIXIE
let g:rslt_use_abbriv = 1			"using abriviation
let g:rslt_use_mapping = 0			"using hot keys
let g:rslt_showCompilerMessage = 1		"use this to enable/disable compiling message show
let g:rslt_showStatistic = 0			"use this to enable/disable rendering statistics show

"rendering and compiling options
let g:rslt_display_driver = "framebuffer"	"use your desired display driver default:framebuffer
let g:rslt_display_name = "shader"		"use to save the result as file
let g:rslt_format = 300				"image resolusion
let g:rslt_pixel_samples = 3			"pixel samples
let g:rslt_shading_rate = 1			"shading rate
let g:rslt_include_address = ""			"add your include address for shader compiling here
let g:rslt_render_Object = "sphere"		"object to render use sphere,plane,disk,cube,cylinder,teapot
let g:rslt_render_this = ""			"address this to override the object rendering
let g:rslt_left_light = 1		   	"left light in rendering. use 0 to turn it off
let g:rslt_left_light_intensity = 8.00		"intensity of left light
let g:right_light = 1				"right light in rendering. use 0 to turn it off
let g:rsl_right_light_intensity = 4.00		"intensity of right light
let g:rslt_back_light = 1		   	"back light in rendering. use 0 to turn it off
let g:rslt_back_light_intensity = 4.00		"intensity of back light
let g:rslt_statistics_level = 1			"level of statistics. 
let g:rslt_color = "[1 1 1]"			"Color
let g:rslt_opacity = "[1 1 1]"			"Opacity
let g:rslt_surfaceShader = "compile"		" 1- use compile to assign the compiled shader 2- empty string to do nothing 3- shader name to use that 
let g:rslt_displaceShader = "dented"			" 1- use compile to assign the compiled shader 2- empty string to do nothing 3- shader name to use that
let g:rslt_displaceBound = 0.1			"displacement bound for displacement
let g:rslt_raytrace = 0				"turn raytracing on and off
let g:rslt_customAttribute1 = ""		"here you could add up to 4 different renderman attribute to object. 
let g:rslt_customAttribute2 = ""		"enter strings with scape characters.
let g:rslt_customAttribute3 = ""
let g:rslt_customAttribute4 = ""
