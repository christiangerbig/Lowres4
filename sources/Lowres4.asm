; Requirements
; 68000+
; OCS PAL+
; 1.2+


; Code optimized for O.M.A. 2.0 Assembler


; V.1.0 beta
; - 1st release

; V.1.1 beta
; - code optimized
; - font colour now less brighter
; - 8xy command handler added
; - only used module fx commands code enabled
; - sprites movement synced with music

; V.1.2 beta
; - bugfix: colours counter now reset before logo is faded out
; - bugfix: wrong 8 fx command in module was not triggering a different speed

; V.1.3 beta
; - Optic's logo included
; - Optic's font included
; - Cursor colour changed
; - Ball's colours changed

; V.1.4 beta
; - Optic's updated logo included
; - Optic's updated font included
; - Cursor color changed
; - Optic's hearts included

; V.1.5 beta
; - background colour changed to dark blue

; V.1.6 beta
; - Image blind scroll effect for logo added
; - Code optimized for 68000
; - Sprites have now priority over playfield1 in viewport1

; V.1.7 beta
; - Image blind scroll speed slowed down
; - Copperlist1 branch improved

; V.1.8 beta
; Again image blind scroll speed slowed down

; V.1.9 beta
; - Sprites movements slowed down

; V.2.0 beta
; - Bugfix: 8xx command routine used the register a0 which lead to a guru 0003
; - Typewriter text changed
; - Typewriter text restart added
; - Clear delay increased to 8 seconds
; - Backspace delay increased to 3 frames
; - Seperator bar added
; - Bar fader added

; V.2.1 beta
; - Vertical blank height between vp1 and vp2 reduced to 10 lines
; - Bugfix: After scrolled out the sprites still appeared at the bottom of the
;   screen. BPL1DAT also opened the display window > $12b. vp2 visible lines
;   decreased by 1 for all bplxdat functions.
;   Last BPL1DAT write at $12b by CMOVE
; - Enabling of fader out routines improved at quit. Fader in routines are
;   forced to stop
; - WB start enabled
; - Fader inabled
; - LuNix' icon included

; V.2.2 beta
; - Code optimized
; - With LuNix´updated icon

; V.1.0
; - final version
; - nfo included
; - adf created


; 8xy command
; 810	scroll sprites bottom in
; 811	scroll sprites bottom out
; 82y	select sprite movement [0..3]


; Execution time 68000: 312 rasterlines


	MC68000


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"
	INCLUDE "intuition/screens.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


	INCDIR "custom-includes-ocs:"


PROTRACKER_VERSION_3		SET 1
START_SECOND_COPPERLIST		SET 1


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory    	EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled 	EQU TRUE
screen_fader_enabled		EQU TRUE
text_output_enabled     	EQU FALSE

; PT-Replay
pt_ciatiming_enabled		EQU TRUE
pt_usedfx			EQU %1111111100111100
pt_usedefx			EQU %0000001001000000
pt_mute_enabled			EQU FALSE
pt_music_fader_enabled		EQU TRUE
pt_fade_out_delay		EQU 2	; ticks
pt_split_module_enabled		EQU TRUE
pt_track_notes_played_enabled	EQU FALSE
pt_track_volumes_enabled	EQU FALSE
pt_track_periods_enabled	EQU FALSE
pt_track_data_enabled		EQU FALSE
	IFD PROTRACKER_VERSION_3
pt_metronome_enabled		EQU FALSE
pt_metrochanbits		EQU pt_metrochan1
pt_metrospeedbits		EQU pt_metrospeed4th
	ENDC

dma_bits			EQU DMAF_SPRITE|DMAF_COPPER|DMAF_BLITTER|DMAF_RASTER|DMAF_MASTER|DMAF_SETCLR

	IFEQ pt_ciatiming_enabled
intena_bits			EQU INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ELSE
intena_bits			EQU INTF_VERTB|INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ENDC

ciaa_icr_bits			EQU CIAICRF_SETCLR
	IFEQ pt_ciatiming_enabled
ciab_icr_bits			EQU CIAICRF_TA|CIAICRF_TB|CIAICRF_SETCLR
	ELSE
ciab_icr_bits			EQU CIAICRF_TB|CIAICRF_SETCLR
	ENDC

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
pf1_colors_number		EQU 0

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 2
; Viewport 1 
; Playfield 1 
extra_pf1_x_size		EQU 352
extra_pf1_y_size		EQU 70
extra_pf1_depth			EQU 4
; Viewport 2 
; Playfield 1 
extra_pf2_x_size		EQU 352
extra_pf2_y_size		EQU 176
extra_pf2_depth			EQU 3

spr_number			EQU 8
spr_x_size1			EQU 16
spr_x_size2			EQU 16
spr_depth			EQU 2
spr_colors_number		EQU 16
spr_used_number			EQU 8
spr_swap_number			EQU 8

	IFD PROTRACKER_VERSION_2 
audio_memory_size		EQU 0
	ENDC
	IFD PROTRACKER_VERSION_3
audio_memory_size		EQU 1*WORD_SIZE
	ENDC

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0

	IFEQ pt_ciatiming_enabled
ciab_cra_bits			EQU CIACRBF_LOAD
	ENDC
ciab_crb_bits			EQU CIACRBF_LOAD|CIACRBF_RUNMODE ; oneshot mode
ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
	IFEQ pt_ciatiming_enabled
ciab_ta_time			EQU 14187 ; = 0.709379 MHz * [20000 µs = 50 Hz duration for one frame on a PAL machine]
; ciab_ta_time			EQU 14318 ; = 0.715909 MHz * [20000 µs = 50 Hz duration for one frame on a NTSC machine]
	ELSE
ciab_ta_time			EQU 0
	ENDC
ciab_tb_time			EQU 362 ; = 0.709379 MHz * [511.43 µs = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
					; = 0.715909 MHz * [506.76 µs = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
	IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled	EQU TRUE
	ELSE
ciab_ta_continuous_enabled	EQU FALSE
	ENDC
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $12d

MINROW				EQU VSTART_256_LINES

; View
display_window_hstart		EQU HSTART_352_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_352_PIXEL
display_window_vstop		EQU VSTOP_256_lines

visible_pixels_number		EQU 352
visible_lines_number		EQU 256

; Viewport 1
vp1_pixel_per_line		EQU 336
vp1_visible_pixels_number	EQU 352
vp1_visible_lines_number	EQU 70

vp1_hstart			EQU display_window_hstop
vp1_vstart			EQU MINROW
vp1_vstop			EQU vp1_vstart+vp1_visible_lines_number

vp1_pf1_depth			EQU 4
vp1_pf_depth			EQU vp1_pf1_depth

vp1_pf1_colors_number		EQU 16
vp1_pf_colors_number		EQU vp1_pf1_colors_number

; Vertical Blank
vb_lines_number			EQU 10
vb_hstart			EQU 0
vb_vstart			EQU vp1_vstop
vb_vstop			EQU vb_vstart+vb_lines_number

vb_bar_height			EQU 6

; Viewport 2
vp2_pixel_per_line		EQU 336
vp2_visible_pixels_number	EQU 352
vp2_visible_lines_number	EQU 176

vp2_hstart			EQU 0
vp2_vstart			EQU vb_vstop
vp2_vstop			EQU vp2_vstart+vp2_visible_lines_number

vp2_pf1_depth			EQU 3
vp2_pf_depth			EQU vp2_pf1_depth

vp2_pf1_colors_number		EQU 8
vp2_pf_corors_number		EQU vp2_pf1_colors_number


; Viewport 1
; Playfield 1
extra_pf1_plane_width		EQU extra_pf1_x_size/8

; Viewport 2 
; Playfield 1 
extra_pf2_plane_width		EQU extra_pf2_x_size/8


; Viewport 1
; Playfield 1
vp1_data_fetch_width		EQU vp1_pixel_per_line/8
vp1_pf1_plane_moduli		EQU (extra_pf1_plane_width*(extra_pf1_depth-1))+extra_pf1_plane_width-vp1_data_fetch_width

; Viewport 2
; Playfield 1 
vp2_data_fetch_width		EQU vp2_pixel_per_line/8
vp2_pf1_plane_moduli		EQU (extra_pf2_plane_width*(extra_pf2_depth-1))+extra_pf2_plane_width-vp2_data_fetch_width


; View
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
bplcon0_bits			EQU BPLCON0F_COLOR|(pf_depth*BPLCON0F_BPU0)
color00_bits			EQU $102

; Viewport 1
vp1_ddfstrt_bits		EQU DDFSTRT_320_PIXEL
vp1_ddfstop_bits		EQU DDFSTOP_OVERSCAN_16_PIXEL
vp1_bplcon0_bits1		EQU BPLCON0F_COLOR|(extra_pf1_depth*BPLCON0F_BPU0)
vp1_bplcon0_bits2		EQU BPLCON0F_COLOR
vp1_bplcon1_bits		EQU 0
vp1_bplcon2_bits		EQU BPLCON2F_PF2P2 ; priority: sprites in front of playfield 1
vp1_color00_bits		EQU color00_bits

; Viewport 2
vp2_ddfstrt_bits		EQU DDFSTRT_320_PIXEL
vp2_ddfstop_bits		EQU DDFSTOP_OVERSCAN_16_PIXEL
vp2_bplcon0_bits1		EQU BPLCON0F_COLOR|(extra_pf2_depth*BPLCON0F_BPU0)
vp2_bplcon0_bits2		EQU BPLCON0F_COLOR
vp2_bplcon1_bits		EQU 0
vp2_bplcon2_bits		EQU 0	; priority: sprites behind playfield 1
vp2_color00_bits		EQU color00_bits


; Viewport 1
cl1_hstart1			EQU display_window_hstop
cl1_vstart1			EQU vp1_vstart-1
; Vertical-Blank
cl1_hstart2			EQU 0
cl1_vstart2			EQU vb_vstart
cl1_hstart3			EQU 12
cl1_vstart3			EQU vb_vstart
cl1_hstart4			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)
cl1_vstart4			EQU vb_vstart
; Viewport 2
cl1_hstart5			EQU 0
cl1_vstart5			EQU vp2_vstart
cl1_hstart6			EQU (vp2_ddfstrt_bits*2)-(extra_pf2_depth*CMOVE_SLOT_PERIOD)
cl1_vstart6			EQU vp2_vstart
; Copper Interrupt
cl1_hstart7			EQU 0
cl1_vstart7			EQU beam_position&CL_Y_WRAPPING

cl2_display_x_size		EQU 0
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU vp1_visible_lines_number
cl2_hstart1			EQU (vp1_ddfstrt_bits*2)-(12*CMOVE_SLOT_PERIOD)
cl2_vstart1			EQU vp1_vstart

; Logo
lg_image_x_size			EQU 352
lg_image_plane_width		EQU lg_image_x_size/8
lg_image_y_size			EQU 70
lg_image_depth			EQU 4

sine_table_length		EQU 512

; Textwriter
tw_image_x_size			EQU 320
tw_image_plane_width		EQU tw_image_x_size/8
tw_image_depth			EQU 2
tw_origin_char_x_size		EQU 16
tw_origin_char_y_size		EQU 15

tw_text_char_x_size		EQU 16
tw_text_char_width		EQU tw_text_char_x_size/8
tw_text_char_y_size		EQU tw_origin_char_y_size
tw_text_char_depth		EQU tw_image_depth

tw_max_x_position		EQU vp2_visible_pixels_number-tw_text_char_x_size

tw_text_cursor_x_size		EQU tw_text_char_x_size
tw_text_cursor_width		EQU tw_text_cursor_x_size/8
tw_text_cursor_y_size		EQU tw_text_char_y_size
tw_text_cursor_depth		EQU extra_pf2_depth

tw_delay			EQU 5	; frames

; Clear-Text
ct_delay			EQU 8*PAL_FPS ; 8s

ct_backspace_delay		EQU 3	; frames

; Sine-Sprites
ss_image_x_size			EQU 7
ss_image_y_size			EQU 7
ss_image_depth			EQU 2

ss_used_sprites_number		EQU 8
ss_reused_sprites_number	EQU 72

ss_x_center			EQU display_window_hstart+((visible_pixels_number-ss_image_x_size)/2)
ss_x_radius			EQU (visible_pixels_number-ss_image_x_size)/2
ss_x_radius_angle_step		EQU 10
ss_x_radius_angle_speed		EQU 1
ss_x_angle_speed		EQU 2
ss_x_distance			EQU 14
ss_y_center			EQU display_window_vstart+((visible_lines_number-ss_image_y_size)/2)
ss_y_radius			EQU (visible_lines_number-ss_image_y_size)/2
ss_y_angle_speed		EQU 3
ss_y_distance			EQU 14

ss_objects_per_sprite_number	EQU ss_reused_sprites_number/ss_used_sprites_number
ss_objects_number		EQU ss_objects_per_sprite_number*ss_used_sprites_number

; Image-Blind-Scroll
ibs_image_x_size		EQU vp1_visible_pixels_number
ibs_image_width			EQU ibs_image_x_size/8
ibs_image_y_size		EQU vp1_visible_lines_number
ibs_image_depth			EQU vp1_pf1_depth

ibs_lamella_height_min		EQU 6
ibs_lamella_height_max		EQU 12
ibs_lamellas_number		EQU cl2_display_y_size/ibs_lamella_height_min
ibs_lamella_radius		EQU ((ibs_lamella_height_max-ibs_lamella_height_min)/2)
ibs_lamella_center		EQU ((ibs_lamella_height_max-ibs_lamella_height_min)/2)+ibs_lamella_height_min
ibs_lamella_angle_speed		EQU 4
ibs_lamella_angle_step		EQU 4
ibs_step1			EQU 1
ibs_step2			EQU 5
ibs_speed			EQU 1

; Logo-Fader
lf_rgb4_start_color		EQU 1
lf_rgb4_color_table_offset	EQU 1
lf_rgb4_colors_number		EQU vp1_pf1_colors_number-1

; Logo-Fader-In
lfi_rgb4_fader_speed		EQU 1
lfi_delay			EQU 4

; Logo-Fader-Out
lfo_rgb4_fader_speed		EQU 1
lfo_delay			EQU 4

; Bar-Fader 
bf_rgb4_color_table_offset	EQU 0
bf_rgb4_colors_number		EQU vb_bar_height

; Bar-Fader-In 
bfi_rgb4_fader_speed		EQU 1
bfi_delay			EQU 3

; Bar-Fader-Out 
bfo_rgb4_fader_speed		EQU 1
bfo_delay			EQU 4

; Textwriter-Fader
tf_rgb4_start_color		EQU 1
tf_rgb4_color_table_offset	EQU 1
tf_rgb4_colors_number		EQU vp2_pf1_colors_number-1

; Textwriter-Fader-Out
tfo_rgb4_fader_speed		EQU 1
tfo_delay			EQU 2

; Scroll-Sprites-Bottom
ssb_y_radius			EQU visible_lines_number
ssb_y_center			EQU visible_lines_number

; Scroll-Sprites-Bottom-In
ssbi_y_angle_speed		EQU 4

; Scroll-Sprites-Bottom-Out
ssbo_y_angle_speed		EQU 2


vp1_pf1_plane_x_offset		EQU 16
vp1_pf1_bpl1dat_x_offset	EQU 0

vp2_pf1_plane_x_offset		EQU 16
vp2_pf1_bpl1dat_x_offset	EQU 0


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; PT-Replay
	INCLUDE "music-tracker/pt-song.i"

	INCLUDE "music-tracker/pt-temp-channel.i"


	RSRESET

cl1_extension1			RS.B 0

cl1_ext1_DDFSTRT		RS.L 1
cl1_ext1_DDFSTOP		RS.L 1
cl1_ext1_BPLCON1		RS.L 1
cl1_ext1_BPLCON2		RS.L 1
cl1_ext1_BPL1MOD		RS.L 1
cl1_ext1_BPL2MOD		RS.L 1
cl1_ext1_COLOR00		RS.L 1
cl1_ext1_COLOR01		RS.L 1
cl1_ext1_COLOR02		RS.L 1
cl1_ext1_COLOR03		RS.L 1
cl1_ext1_COLOR04		RS.L 1
cl1_ext1_COLOR05		RS.L 1
cl1_ext1_COLOR06		RS.L 1
cl1_ext1_COLOR07		RS.L 1
cl1_ext1_COLOR08		RS.L 1
cl1_ext1_COLOR09		RS.L 1
cl1_ext1_COLOR10		RS.L 1
cl1_ext1_COLOR11		RS.L 1
cl1_ext1_COLOR12		RS.L 1
cl1_ext1_COLOR13		RS.L 1
cl1_ext1_COLOR14		RS.L 1
cl1_ext1_COLOR15		RS.L 1
cl1_ext1_BPL1PTH		RS.L 1
cl1_ext1_BPL1PTL		RS.L 1
cl1_ext1_BPL2PTH		RS.L 1
cl1_ext1_BPL2PTL		RS.L 1
cl1_ext1_BPL3PTH		RS.L 1
cl1_ext1_BPL3PTL		RS.L 1
cl1_ext1_BPL4PTH		RS.L 1
cl1_ext1_BPL4PTL		RS.L 1
cl1_ext1_COP1LCH		RS.L 1
cl1_ext1_COP1LCL		RS.l 1
cl1_ext1_WAIT			RS.L 1
cl1_ext1_BPLCON0		RS.L 1
cl1_ext1_COPJMP2		RS.L 1

cl1_extension1_size		RS.B 0


	RSRESET

cl1_extension2			RS.B 0

cl1_ext2_WAIT			RS.L 1
cl1_ext2_BPLCON0		RS.L 1

cl1_extension2_size		RS.B 0


	RSRESET

cl1_extension3			RS.B 0

cl1_ext3_WAIT1			RS.L 1
cl1_ext3_COLOR00		RS.L 1
cl1_ext3_WAIT2			RS.L 1
cl1_ext3_BPL1DAT		RS.L 1

cl1_extension3_size		RS.B 0


	RSRESET

cl1_extension4			RS.B 0

cl1_ext4_DDFSTRT		RS.L 1
cl1_ext4_DDFSTOP		RS.L 1
cl1_ext4_BPLCON1		RS.L 1
cl1_ext4_BPLCON2		RS.L 1
cl1_ext4_BPL1MOD		RS.L 1
cl1_ext4_BPL2MOD		RS.L 1
cl1_ext4_COLOR00		RS.L 1
cl1_ext4_COLOR01		RS.L 1
cl1_ext4_COLOR02		RS.L 1
cl1_ext4_COLOR03		RS.L 1
cl1_ext4_COLOR04		RS.L 1
cl1_ext4_COLOR05		RS.L 1
cl1_ext4_COLOR06		RS.L 1
cl1_ext4_COLOR07		RS.L 1
cl1_ext4_BPL1PTH		RS.L 1
cl1_ext4_BPL1PTL		RS.L 1
cl1_ext4_BPL2PTH		RS.L 1
cl1_ext4_BPL2PTL		RS.L 1
cl1_ext4_BPL3PTH		RS.L 1
cl1_ext4_BPL3PTL		RS.L 1
cl1_ext4_WAIT			RS.L 1
cl1_ext4_BPLCON0		RS.L 1

cl1_extension4_size		RS.B 0


	RSRESET

cl1_extension5			RS.B 0

cl1_ext5_WAIT			RS.L 1
cl1_ext5_BPL3DAT		RS.L 1
cl1_ext5_BPL2DAT		RS.L 1
cl1_ext5_BPL1DAT		RS.L 1
cl1_ext5_NOOP			RS.L 1

cl1_extension5_size		RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

; Viewport 1
cl1_extension1_entry		RS.B cl1_extension1_size
; Vertical Blank
cl1_extension2_entry		RS.B cl1_extension2_size
cl1_extension3_entry		RS.B cl1_extension3_size*vb_lines_number
; Viewport 2
cl1_extension4_entry		RS.B cl1_extension4_size
cl1_extension5_entry		RS.B cl1_extension5_size*(vp2_visible_lines_number-1)
; Copper Interrupt
cl1_WAIT			RS.L 1
cl1_INTREQ			RS.L 1
; Reset pointer for vertical blanc
cl1_COP1LCH			RS.L 1
cl1_COP1LCL			RS.l 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAIT			RS.L 1
cl2_ext1_BPL4PTH		RS.L 1
cl2_ext1_BPL4PTL		RS.L 1
cl2_ext1_BPL4DAT		RS.L 1
cl2_ext1_BPL3PTH		RS.L 1
cl2_ext1_BPL3PTL		RS.L 1
cl2_ext1_BPL3DAT		RS.L 1
cl2_ext1_BPL2PTH		RS.L 1
cl2_ext1_BPL2PTL		RS.L 1
cl2_ext1_BPL2DAT		RS.L 1
cl2_ext1_BPL1PTH		RS.L 1
cl2_ext1_BPL1PTL		RS.L 1
cl2_ext1_BPL1DAT		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size*cl2_display_y_size

cl2_COPJMP1			RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size

cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
cl2_size3			EQU copperlist2_size


; Sprite0 additional structure
	RSRESET

spr0_extension1			RS.B 0

spr0_ext1_header		RS.L 1
spr0_ext1_planedata		RS.L ss_image_y_size

spr0_extension1_size		RS.B 0

; Sprite0 main structure
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry		RS.B spr0_extension1_size*ss_objects_per_sprite_number

spr0_end			RS.L 1

sprite0_size			RS.B 0

; Sprite1 additional structure
	RSRESET

spr1_extension1			RS.B 0

spr1_ext1_header		RS.L 1
spr1_ext1_planedata		RS.L ss_image_y_size

spr1_extension1_size		RS.B 0

; Sprite1 main structure
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size*ss_objects_per_sprite_number

spr1_end			RS.L 1

sprite1_size			RS.B 0

; Sprite2 additional structure
	RSRESET

spr2_extension1			RS.B 0

spr2_ext1_header		RS.L 1
spr2_ext1_planedata		RS.L ss_image_y_size

spr2_extension1_size		RS.B 0

; Sprite2 main structure
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size*ss_objects_per_sprite_number

spr2_end			RS.L 1

sprite2_size			RS.B 0

; Sprite3 additional structure
	RSRESET

spr3_extension1			RS.B 0

spr3_ext1_header		RS.L 1
spr3_ext1_planedata		RS.L ss_image_y_size

spr3_extension1_size		RS.B 0

; Sprite3 main structure
	RSRESET

spr3_begin			RS.B 0

spr3_extension1_entry		RS.B spr3_extension1_size*ss_objects_per_sprite_number

spr3_end			RS.L 1

sprite3_size			RS.B 0

; Sprite4 additional structure
	RSRESET

spr4_extension1			RS.B 0

spr4_ext1_header		RS.L 1
spr4_ext1_planedata		RS.L ss_image_y_size

spr4_extension1_size		RS.B 0

; Sprite4 main structure
	RSRESET

spr4_begin			RS.B 0

spr4_extension1_entry		RS.B spr4_extension1_size*ss_objects_per_sprite_number

spr4_end			RS.L 1

sprite4_size			RS.B 0

; Sprite5 additional structure
	RSRESET

spr5_extension1			RS.B 0

spr5_ext1_header		RS.L 1
spr5_ext1_planedata		RS.L ss_image_y_size

spr5_extension1_size		RS.B 0

; Sprite5 main structure
	RSRESET

spr5_begin			RS.B 0

spr5_extension1_entry		RS.B spr5_extension1_size*ss_objects_per_sprite_number

spr5_end			RS.L 1

sprite5_size			RS.B 0

; Sprite6 additional structure
	RSRESET

spr6_extension1			RS.B 0

spr6_ext1_header		RS.L 1
spr6_ext1_planedata		RS.L ss_image_y_size

spr6_extension1_size		RS.B 0

; Sprite6 main structure
	RSRESET

spr6_begin			RS.B 0

spr6_extension1_entry		RS.B spr6_extension1_size*ss_objects_per_sprite_number

spr6_end			RS.L 1

sprite6_size			RS.B 0

; Sprite7 additional structure
	RSRESET

spr7_extension1			RS.B 0

spr7_ext1_header		RS.L 1
spr7_ext1_planedata		RS.L ss_image_y_size

spr7_extension1_size		RS.B 0

; Sprite7 main structure
	RSRESET

spr7_begin			RS.B 0

spr7_extension1_entry		RS.B spr7_extension1_size*ss_objects_per_sprite_number

spr7_end			RS.L 1

sprite7_size			RS.B 0


spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU sprite0_size/4
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU sprite1_size/4
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU sprite2_size/4
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU sprite3_size/4
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU sprite4_size/4
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU sprite5_size/4
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU sprite6_size/4
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU sprite7_size/4

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU sprite0_size/4
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/4
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/4
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/4
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/4
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/4
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/4
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/4


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; PT-Replay
	IFD PROTRACKER_VERSION_2
		INCLUDE "music-tracker/pt2-variables.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-variables.i"
	ENDC

pt_effects_handler_active	RS.W 1

; Textwriter
tw_active			RS.W 1
	RS_ALIGN_LONGWORD
tw_image			RS.L 1
tw_text_table_start		RS.W 1
tw_text_char_x_position		RS.W 1
tw_text_char_y_position		RS.W 1
tw_delay_counter		RS.W 1

tw_cursor_active		RS.W 1
tw_cursor_x_position		RS.W 1
tw_cursor_y_position		RS.W 1

; Clear-Text
ct_delay_counter		RS.W 1

ct_backspace_active		RS.W 1
ct_backspace_delay_counter	RS.W 1

; Sine-Sprites
ss_sprites_visible		RS.W 1
ss_variable_y_center		RS.W 1
ss_x_radius_angle		RS.W 1
ss_x_angle			RS.W 1
ss_y_angle			RS.W 1
ss_variable_y_speed		RS.W 1

; Image-Blind-Scroll
ibs_image_start			RS.W 1
ibs_lamella_angle		RS.W 1

; Logo-Fader
lf_rgb4_colors_counter		RS.W 1
lf_rgb4_copy_colors_active	RS.W 1

; Logo-Fader-In
lfi_rgb4_active			RS.W 1
lfi_delay_counter		RS.W 1

; Logo-Fader-Out
lfo_rgb4_active			RS.W 1
lfo_delay_counter		RS.W 1

; Bar-Fader 
bf_rgb4_colors_counter		RS.W 1
bf_rgb4_copy_colors_active	RS.W 1

; Bar-Fader-In 
bfi_rgb4_active			RS.W 1
bfi_delay_counter		RS.W 1

; Bar-Fader-Out 
bfo_rgb4_active			RS.W 1
bfo_delay_counter		RS.W 1

; Textwriter-Fader
tf_rgb4_colors_counter		RS.W 1
tf_rgb4_copy_colors_active	RS.W 1

; Textwriter-Fader-Out
tfo_rgb4_active			RS.W 1
tfo_delay_counter		RS.W 1

; Scroll-Sprites-Bottom-In
ssbi_active			RS.W 1
ssbi_y_angle			RS.W 1

; Scroll-Sprites-Bottom-Out
ssbo_active			RS.W 1
ssbo_y_angle			RS.W 1

; Main 
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; PT-Replay
	IFD PROTRACKER_VERSION_2
		PT2_INIT_VARIABLES
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_INIT_VARIABLES
	ENDC

	moveq	#TRUE,d0
	move.w	d0,pt_effects_handler_active(a3)

; Textwriter
	moveq	#FALSE,d1
	move.w	d1,tw_active(a3)
	lea	tw_image_data,a0
	move.l	a0,tw_image(a3)
	move.w	d0,tw_text_table_start(a3)
	move.w	d0,tw_text_char_x_position(a3)
	move.w	d0,tw_text_char_y_position(a3)
	move.w	d1,tw_delay_counter(a3) ; disable counter

	move.w	d1,tw_cursor_active(a3)
	move.w	d0,tw_cursor_x_position(a3)
	move.w	d0,tw_cursor_y_position(a3)

; Clear-Text
	move.w	d1,ct_delay_counter(a3) ; disable counter

	move.w	d1,ct_backspace_delay_counter(a3)

; Sine-Sprites
	move.w	d1,ss_sprites_visible(a3)
	move.w	#ss_y_center+ssb_y_radius,ss_variable_y_center(a3)
	move.w	#(sine_table_length/4)*WORD_SIZE,ss_x_radius_angle(a3) ; 90°
	move.w	#(sine_table_length/4)*WORD_SIZE,ss_x_angle(a3) ; 90°
	move.w	d0,ss_y_angle(a3)	; 0°
	move.w	d0,ss_variable_y_speed(a3)

; Image-Blind-Scroll
	move.w	d0,ibs_image_start(a3)
	move.w	d0,ibs_lamella_angle(a3) ; 0°

; Logo-Fader
	move.w	#lf_rgb4_colors_number*3,lf_rgb4_colors_counter(a3)
	move.w	d0,lf_rgb4_copy_colors_active(a3)

; Logo-Fader-In
	move.w	d0,lfi_rgb4_active(a3)
	move.w	#lfi_delay,lfi_delay_counter(a3)

; Logo-Fader-Out
	move.w	d1,lfo_rgb4_active(a3)
	move.w	#lfo_delay,lfo_delay_counter(a3)

; Bar-Fader 
	move.w	#bf_rgb4_colors_number*3,bf_rgb4_colors_counter(a3)
	move.w	d0,bf_rgb4_copy_colors_active(a3)

; Bar-Fader-In 
	move.w	d0,bfi_rgb4_active(a3)
	move.w	#bfi_delay,bfi_delay_counter(a3)

; Bar-Fader-Out 
	move.w	d1,bfo_rgb4_active(a3)
	move.w	#bfo_delay,bfo_delay_counter(a3)

; Textwriter-Fader
	move.w	#tf_rgb4_colors_number*3,tf_rgb4_colors_counter(a3)
	move.w	d1,tf_rgb4_copy_colors_active(a3)

; Textwriter-Fader-Out
	move.w	d1,tfo_rgb4_active(a3)
	move.w	#tfo_delay,tfo_delay_counter(a3)

; Scroll-Sprites-Bottom-In
	move.w	d1,ssbi_active(a3)
	move.w	d0,ssbi_y_angle(a3)	; 0°

; Scroll-Sprites-Bottom-Out
	move.w	d1,ssbo_active(a3)
	move.w	#(sine_table_length/4)*WORD_SIZE,ssbo_y_angle(a3) ; 90°

; Main 
	move.w	d1,stop_fx_active(a3)

	rts


	CNOP 0,4
init_main
	bsr.s	pt_DetectSysFrequ
	bsr	pt_InitRegisters
	bsr	pt_InitAudTempStrucs
	bsr	pt_ExamineSongStruc
	bsr	pt_InitFtuPeriodTableStarts
	bsr	init_CIA_timers
	bsr	init_colors
	bsr	lg_copy_image_to_playfield
	bsr	tw_init_chars_offsets
	bsr	ss_init_xy_starts
	bsr	init_sprites
	bsr	cl1_init_copperlist
	bsr	cl2_init_copperlist
	rts


	PT_DETECT_SYS_FREQUENCY


	PT_INIT_REGISTERS


	PT_INIT_AUDIO_TEMP_STRUCTURES


	PT_EXAMINE_SONG_STRUCTURE


	PT_INIT_FINETUNE_TABLE_STARTS


	CNOP 0,4
init_colors
	CPU_INIT_COLOR COLOR00,1,pf1_rgb4_color_table
	rts


	CNOP 0,4
init_CIA_timers

; PT-Replay
	PT_INIT_TIMERS
	rts


; Logo
	CNOP 0,4
lg_copy_image_to_playfield
	move.l	a4,-(a7)
	move.l	#lg_image_data,a1	; source
	move.l	extra_pf1(a3),a4	; destination
	bsr.s	lg_copy_image_data
	ADDF.W	lg_image_plane_width,a1 ; next bitplane in source
	ADDF.W	extra_pf1_plane_width,a4 ; next bitplane in destination
	bsr.s	lg_copy_image_data
	ADDF.W	lg_image_plane_width,a1
	ADDF.W	extra_pf1_plane_width,a4
	bsr.s	lg_copy_image_data
	ADDF.W	lg_image_plane_width,a1
	ADDF.W	extra_pf1_plane_width,a4
	bsr.s	lg_copy_image_data
	move.l	(a7)+,a4
	rts


; Input
; a1.l	Source: image
; a4.l	Destination: bitplane
; Result
	CNOP 0,4
lg_copy_image_data
	move.l	a1,a0			; source
	move.l	a4,a2			; destination
	MOVEF.W lg_image_y_size-1,d7
lg_copy_image_data_loop
	REPT lg_image_x_size/WORD_BITS
	move.w	(a0)+,(a2)+		; copy 44 bytes
	ENDR
	ADDF.W	lg_image_plane_width*(lg_image_depth-1),a0 ; next line in source
	ADDF.W	extra_pf1_plane_width*(extra_pf1_depth-1),a2 ; next line in destination
	dbf	d7,lg_copy_image_data_loop
	rts


; Textwriter
	INIT_CHARS_OFFSETS.W tw


; Sine-Sprites
	CNOP 0,4
ss_init_xy_starts
	moveq	#0,d0			; 1st xy start
	lea	ss_xy_starts(pc),a0
	moveq	#ss_reused_sprites_number-1,d7
ss_init_xy_starts_loop
	move.w	d0,(a0)+		; xy start
	addq.w	#2*WORD_SIZE,d0		; next xy start
	dbf	d7,ss_init_xy_starts_loop
	rts


	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bsr	ss_init_sprites_bitmaps
	bsr	spr_copy_structures
	rts


	INIT_SPRITE_POINTERS_TABLE


	CNOP 0,4
ss_init_sprites_bitmaps
	movem.l a4-a6,-(a7)
	lea	spr_pointers_construction(pc),a2
	lea	ss_image_data,a4
	moveq	#ss_used_sprites_number-1,d7
ss_init_sprites_bitmaps_loop1
	move.l	(a2)+,a0		; 1st sprite structure
	moveq	#ss_objects_per_sprite_number-1,d6
ss_init_sprites_bitmaps_loop2
	addq.w	#LONGWORD_SIZE,a0 	; skip header
	move.l	a4,a1			; image data
	moveq	#ss_image_y_size-1,d5
ss_init_sprites_bitmaps_loop3
	move.l	(a1)+,(a0)+		; copy 1 word plane1 & plane2
	dbf	d5,ss_init_sprites_bitmaps_loop3
	dbf	d6,ss_init_sprites_bitmaps_loop2
	dbf	d7,ss_init_sprites_bitmaps_loop1
	movem.l (a7)+,a4-a6
	rts


	COPY_SPRITE_STRUCTURES


	CNOP 0,4
cl1_init_copperlist
	move.l	cl1_display(a3),a0
; View
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_sprite_pointers
	bsr	cl1_init_colors
; Viewport 1
	bsr	cl1_vp1_init_playfield_props
	bsr	cl1_vp1_init_colors
	bsr	cl1_vp1_init_bitplane_pointers
	bsr	cl1_vp1_init_branch
	bsr	cl1_vp1_start_display
; Vertical-Blank
	bsr	cl1_vb_start_blank
	bsr	cl1_vb_init_bpldat
; Viewport 2
	bsr	cl1_vp2_init_playfield_props
	bsr	cl1_vp2_init_colors
	bsr	cl1_vp2_init_bitplane_pointers
	bsr	cl1_vp2_start_display
	bsr	cl1_vp2_init_bpldat
; Copper-Interrupt
	bsr	cl1_init_copper_interrupt
	bsr	cl1_reset_copperlist_pointer
	COP_LISTEND
	bsr	cl1_vp1_set_bitplane_pointers
	bsr	cl1_vp2_set_bitplane_pointers
	rts


; View
	COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES

	COP_INIT_SPRITE_POINTERS cl1

	CNOP 0,4
cl1_init_colors
	COP_INIT_COLOR COLOR16,16,spr_rgb4_color_table
	rts


	COP_SET_SPRITE_POINTERS cl1,display,spr_number


; Viewport 1
	COP_INIT_PLAYFIELD_REGISTERS cl1,,vp1

	CNOP 0,4
cl1_vp1_init_colors
	COP_INIT_COLOR COLOR00,16,vp1_pf1_rgb4_color_table
	rts

	CNOP 0,4
cl1_vp1_init_bitplane_pointers
	move.w #BPL1PTH,d0
	moveq	#(extra_pf1_depth*2)-1,d7
cl1_vp1_init_bitplane_pointers_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0
	addq.w	#LONGWORD_SIZE,a0
	dbf	d7,cl1_vp1_init_bitplane_pointers_loop
	rts


	CNOP 0,4
cl1_vp1_init_branch
	move.l	cl1_display(a3),d0
	add.l	#cl1_extension2_entry,d0
	swap	d0
	move.w	#COP1LCH,(a0)+
	move.w	d0,(a0)+
	swap	d0
	move.w	#COP1LCL,(a0)+
	move.w	d0,(a0)+
	rts


	CNOP 0,4
cl1_vp1_start_display
	COP_WAIT cl1_hstart1,cl1_vstart1
	COP_MOVEQ vp1_bplcon0_bits1,BPLCON0
	COP_MOVEQ 0,COPJMP2
	rts


; Vertical Blank
	CNOP 0,4
cl1_vb_start_blank
	COP_WAIT cl1_hstart2,cl1_vstart2
	COP_MOVEQ vp1_bplcon0_bits2,BPLCON0
	rts

	CNOP 0,4
cl1_vb_init_bpldat
	move.l	#(((cl1_VSTART3<<24)|(((cl1_HSTART3/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#(((cl1_VSTART4<<24)|(((cl1_HSTART4/4)*2)<<16))|$10000)|$fffe,d1 ; CWAIT
	move.l	#(COLOR00<<16)|color00_bits,d2
	move.l	#BPL1DAT<<16,d3
	move.l	#1<<24,d4		; next line
	MOVEF.W vb_lines_number-1,d7
cl1_vb_init_bpldat_loop
	move.l	d0,(a0)+		; CWAIT
	add.l	d4,d0			; next line
	move.l	d2,(a0)+		; COLOR00
	move.l	d1,(a0)+		; CWAIT
	add.l	d4,d1			; next line
	move.l	d3,(a0)+		; BPL1DAT
	dbf	d7,cl1_vb_init_bpldat_loop
	rts


; Viewport 2
	COP_INIT_PLAYFIELD_REGISTERS cl1,,vp2

	CNOP 0,4
cl1_vp2_init_colors
	COP_INIT_COLOR COLOR00,8,vp2_pf1_rgb4_color_table
	rts

	CNOP 0,4
cl1_vp2_init_bitplane_pointers
	move.w	#BPL1PTH,d0
	moveq	#(extra_pf2_depth*2)-1,d7
cl1_vp2_init_bitplane_pointers_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0
	addq.w	#LONGWORD_SIZE,a0
	dbf	d7,cl1_vp2_init_bitplane_pointers_loop
	rts

	CNOP 0,4
cl1_vp2_start_display
	COP_WAIT cl1_hstart5,cl1_vstart5
	COP_MOVEQ vp2_bplcon0_bits1,BPLCON0
	rts

	CNOP 0,4
cl1_vp2_init_bpldat
	move.l	extra_pf2(a3),a1
	ADDF.W	vp2_pf1_BPL1DAT_x_offset/8,a1 ; bitplane 1
	move.l	#(((cl1_vstart6<<24)|(((cl1_hstart6/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#BPL1DAT<<16,d1
	move.l	#BPL2DAT<<16,d2
	move.l	#BPL3DAT<<16,d3
	move.l	#(((CL_Y_WRAPPING<<24)|(((cl1_hstart6/4)*2)<<16))|$10000)|$fffe,d4 ; CWAIT
	move.l	#1<<24,d5
	MOVEF.W (vp2_visible_lines_number-1)-1,d7
cl1_vp2_init_bpldat_loop
	move.l	d0,(a0)+		; CWAIT
	move.l	d3,(a0)+		; BPL3DAT
	move.l	d2,(a0)+		; BPL2DAT
	move.l	d1,(a0)+		; BPL1DAT
	ADDF.W	extra_pf2_plane_width*extra_pf2_depth,a1 ; next line in source
	COP_MOVEQ 0,NOOP
	cmp.l	d4,d0			; y wrapping ?
	bne.s	cl1_vp2_init_bpldat_skip
	subq.w	#LONGWORD_SIZE,a0
	COP_WAIT CL_X_WRAPPING,CL_Y_WRAPPING ; patch cl
cl1_vp2_init_bpldat_skip
	add.l	d5,d0			; next line
	dbf	d7,cl1_vp2_init_bpldat_loop
	rts


	COP_INIT_COPINT cl1,cl1_hstart7,cl1_vstart7


	CNOP 0,4
cl1_reset_copperlist_pointer
	move.l	cl1_display(a3),d0
	swap	d0
	move.w	#COP1LCH,(a0)+
	move.w	d0,(a0)+
	swap	d0
	move.w	#COP1LCL,(a0)+
	move.w	d0,(a0)+
	rts


	CNOP 0,4
cl1_vp1_set_bitplane_pointers
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1PTH+WORD_SIZE,a0
	move.l	extra_pf1(a3),d0
	moveq	#extra_pf1_plane_width,d1
	moveq	#extra_pf1_depth-1,d7
cl1_vp1_set_bitplane_pointers_loop
	swap	d0
	move.w	d0,(a0) 		; BPLxPTH
	addq.w	#QUADWORD_SIZE,a0
	swap	d0
	move.w	d0,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
	add.l	d1,d0			; next bitplane
	dbf	d7,cl1_vp1_set_bitplane_pointers_loop
	rts


	CNOP 0,4
cl1_vp2_set_bitplane_pointers
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_extension4_entry+cl1_ext4_BPL1PTH+WORD_SIZE,a0
	move.l	extra_pf2(a3),d0
	addq.l	#WORD_SIZE,d0
	moveq	#extra_pf2_plane_width,d1
	moveq	#extra_pf2_depth-1,d7
cl1_vp2_set_bitplane_pointers_loop
	swap	d0
	move.w	d0,(a0) 		; BPLxPTH
	addq.w	#QUADWORD_SIZE,a0
	swap	d0
	move.w	d0,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
	add.l	d1,d0			; next bitplane
	dbf	d7,cl1_vp2_set_bitplane_pointers_loop
	rts


	CNOP 0,4
cl2_init_copperlist
	move.l	cl2_construction2(a3),a0 
	bsr.s	cl2_init_bpl_registers
	COP_MOVEQ 0,COPJMP1
	bsr	copy_second_copperlist

	bsr	swap_second_copperlist
	bsr	image_blind_scroll
	bsr	swap_second_copperlist
	bsr	image_blind_scroll
	rts


	CNOP 0,4
cl2_init_bpl_registers
	move.l	#(((cl2_vstart1<<24)|(((cl2_hstart1/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#1<<24,d1 		; next line
	MOVEF.W	cl2_display_y_size-1,d7
cl2_init_bpl_registers_loop
	move.l	d0,(a0)+		; CWAIT
	COP_MOVEQ 0,BPL4PTH
	COP_MOVEQ 0,BPL4PTL
	COP_MOVEQ 0,BPL4DAT
	COP_MOVEQ 0,BPL3PTH
	COP_MOVEQ 0,BPL3PTL
	COP_MOVEQ 0,BPL3DAT
	COP_MOVEQ 0,BPL2PTH
	COP_MOVEQ 0,BPL2PTL
	COP_MOVEQ 0,BPL2DAT
	COP_MOVEQ 0,BPL1PTH
	COP_MOVEQ 0,BPL1PTL
	add.l	d1,d0			; next line
	COP_MOVEQ 0,BPL1DAT
	dbf	d7,cl2_init_bpl_registers_loop
	rts


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bsr	beam_routines
	rts


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr.s	swap_sprite_structures
	bsr	set_sprite_pointers
	bsr	lf_rgb4_copy_color_table
	bsr	tf_rgb4_copy_color_table
	bsr	bf_rgb4_copy_color_table
	bsr	textwriter
	bsr	clear_text
	bsr	tw_display_cursor
	bsr	cl1_update_bpl1dat
	bsr	ss_calculate_xy_coordinates
	movem.l a4-a6,-(a7)
	bsr	ss_sort_y_coordinates
	movem.l (a7)+,a4-a6
	bsr	ss_move_sprites
	bsr	image_blind_scroll
	bsr	rgb4_logo_fader_in
	bsr	rgb4_logo_fader_out
	bsr	rgb4_textwriter_fader_out
	bsr	rgb4_bar_fader_in
	bsr	rgb4_bar_fader_out
	bsr	scroll_sprites_bottom_in
	bsr	scroll_sprites_bottom_out
	bsr	mouse_handler
	bsr	control_counters
	tst.w	stop_fx_active(a3)
	bne	beam_routines
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	SWAP_SPRITES spr_swap_number


	SET_SPRITES spr_swap_number


; Input
; Result
	CNOP 0,4
textwriter
	movem.l	a4-a5,-(a7)
	tst.w	tw_active(a3)
	bne.s	textwriter_quit
	bsr.s	tw_get_new_char_image
	move.l	d0,a0			; store character image address
	moveq	#0,d0
	move.w	tw_text_char_x_position(a3),d0
	move.w	d0,d3			; store x
	lsr.w	#3,d0			; byte offset
	move.w	tw_text_char_y_position(a3),d1
	move.w	d1,d4			; store y
	MULUF.W extra_pf2_plane_width*extra_pf2_depth,d1,d2 ; y offset in playfield
	add.w	d1,d0			; x offset + y offset
	move.l	extra_pf2(a3),a1
	add.l	d0,a1			; add playfield address
	bsr	tw_clear_cursor_data
	move.w	#extra_pf2_plane_width,a2
	move.w	#tw_image_plane_width,a4
	bsr	tw_copy_character_data
	ADDF.W	tw_text_char_x_size,d3	; next text column
	cmp.w	#tw_max_x_position,d3
	ble.s	textwriter_skip
	ADDF.W	tw_text_char_y_size+1,d4 ; next text line
	moveq	#0,d3			; reset x in text line
textwriter_skip
	move.w	d3,tw_text_char_x_position(a3)
	move.w	d4,tw_text_char_y_position(a3)
	move.w	d3,tw_cursor_x_position(a3)
	move.w	d4,tw_cursor_y_position(a3)
	move.w	#FALSE,tw_active(a3)
textwriter_quit
	movem.l	(a7)+,a4-a5
	rts


	GET_NEW_CHAR_IMAGE.W tw,tw_check_control_codes

; Input
; d0.b	ASCII-Code
; Result
; d0.l	Return code
	CNOP 0,4
tw_check_control_codes
	cmp.b	#ASCII_CTRL_M,d0
	beq.s	tw_line_break
	cmp.b	#ASCII_CTRL_S,d0
	beq.s	tw_stop_textwriter
	rts
	CNOP 0,4
tw_line_break
	move.w	#tw_delay,tw_delay_counter(a3)
	bsr	tw_clear_cursor
	moveq	#tw_text_char_y_size+1,d0
	add.w	d0,tw_text_char_y_position(a3) ; next text line
	add.w	d0,tw_cursor_y_position(a3)
	moveq	#0,d0
	move.w	d0,tw_text_char_x_position(a3) ; reset x
	move.w	d0,tw_cursor_x_position(a3)
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
tw_stop_textwriter
	bsr	tw_clear_cursor
	moveq	#FALSE,d0
	move.w	d0,tw_delay_counter(a3)	; disable counter
	move.w	d0,tw_cursor_active(a3)
 	move.w	#ct_delay,ct_delay_counter(a3) ; start counter
	moveq	#RETURN_OK,d0
	rts


; Input
; a0.l	character image
; a1.l	bitplane 1
; a2.l	Plane width
; a4.l	Plane width character image
; Result
	CNOP 0,4
tw_copy_character_data
	move.l	a2,a5
	MULUF.L	2,a5,d0
	WAITBLIT		; necessary if cpu runs with a cache
	REPT tw_text_char_y_size
	move.w	(a0),(a1)	; copy 16 pixel into bitplane 1
	add.l	a4,a0		; next line in character
	add.l	a2,a1		; next line in playfield
	move.w	(a0),(a1)	; copy 16 pixel into bitplane 2
	add.l	a4,a0		; next line in character
	add.l	a5,a1		; next line & skip bitplane 3 in playfield
	ENDR
	rts


; Input
; Result
	CNOP 0,4
tw_clear_cursor
	moveq	#0,d0
	move.w	tw_cursor_x_position(a3),d0
	lsr.w	#3,d0			; byte offset
	move.w	tw_cursor_y_position(a3),d3
	MULUF.W extra_pf2_plane_width*extra_pf2_depth,d3,d2 ; y offset in playfield
	add.w	d3,d0			; x offset + y offset
	move.l	extra_pf2(a3),a1
	add.l	d0,a1			; add playfield address
	bsr.s	tw_clear_cursor_data
	rts


; Input
; a1.l	 bitplane 1
; Result
	CNOP 0,4
tw_clear_cursor_data
	WAITBLIT
	move.l	#BC0F_DEST<<16,BLTCON0-DMACONR(a6) ; minterm clear
	move.l	a1,BLTDPT-DMACONR(a6)
	move.w	#extra_pf2_plane_width-tw_text_cursor_width,BLTDMOD-DMACONR(a6)
	move.w	#((tw_text_cursor_y_size*tw_text_cursor_depth)<<6)|(tw_text_cursor_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	rts


; Input
; Result
	CNOP 0,4
tw_display_cursor
	tst.w	tw_cursor_active(a3)
	bne.s	tw_display_cursor_quit
	moveq	#0,d0
	move.w	tw_cursor_x_position(a3),d0
	lsr.w	#3,d0			; byte offset
	move.w	tw_cursor_y_position(a3),d1
	MULUF.W extra_pf2_plane_width*extra_pf2_depth,d1,d2 ; y offset in playfield
	add.w	d1,d0			; x offset + y offset
 	bne.s	tw_display_cursor_skip
 	moveq	#FALSE,d1
	move.w	d1,ct_backspace_active(a3)
	move.w	d1,ct_backspace_delay_counter(a3)
	move.w	#1,tw_delay_counter(a3)	; enable counter
	clr.w	tw_active(a3)
tw_display_cursor_skip
	move.l	extra_pf2(a3),a1
	add.l	d0,a1			; add playfield address
	WAITBLIT
	move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
	moveq	#-1,d0			; no mask
	move.l	d0,BLTAFWM-DMACONR(a6)
	move.w	#%1111111111111100,BLTADAT-DMACONR(a6)	; cursor bitplane data
	move.l	a1,BLTDPT-DMACONR(a6)
	move.w	#extra_pf2_plane_width-tw_text_cursor_width,BLTDMOD-DMACONR(a6)
	move.w	#((tw_text_cursor_y_size*tw_text_cursor_depth)<<6)|(tw_text_cursor_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
tw_display_cursor_quit
	rts


; Input
; Result
	CNOP 0,4
clear_text
	move.l	a4,-(a7)
	tst.w	ct_backspace_active(a3)
	bne.s	clear_text_quit
	moveq	#0,d0
	move.w	tw_text_char_x_position(a3),d0
	move.w	d0,d3			; store x
	lsr.w	#3,d0			; byte offset
	move.w	tw_text_char_y_position(a3),d1
	move.w	d1,d4			; store y
	MULUF.W extra_pf2_plane_width*extra_pf2_depth,d1,d2 ; y offset in playfield
	add.w	d1,d0			; x offset + y offset
	move.l	extra_pf2(a3),a1
	add.l	d0,a1			; add playfield address
	bsr	tw_clear_cursor_data
	move.w	#extra_pf2_plane_width,a2
	move.w	#tw_image_plane_width,a4
	SUBF.W	tw_text_char_x_size,d3	; previous text column
	bpl.s	clear_text_skip2
	SUBF.W	tw_text_char_y_size+1,d4 ; previous text line
	bpl.s	clear_text_skip1
	moveq	#0,d4
clear_text_skip1
	MOVEF.W	visible_pixels_number-tw_text_char_x_size,d3 ; reset x in text line
clear_text_skip2
	move.w	d3,tw_text_char_x_position(a3)
	move.w	d4,tw_text_char_y_position(a3)
	move.w	d3,tw_cursor_x_position(a3)
	move.w	d4,tw_cursor_y_position(a3)
	move.w	#FALSE,ct_backspace_active(a3)
clear_text_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
cl1_update_bpl1dat
	WAITBLIT			; necessary if the cpu runs with a chache
	MOVEF.L	extra_pf2_plane_width*extra_pf2_depth,d1
	MOVEF.L cl1_extension5_size,d2
	move.l	extra_pf2(a3),a0
	ADDF.W	vp2_pf1_bpl1dat_x_offset/8,a0
	move.l	cl1_display(a3),a1
	ADDF.W	cl1_extension5_entry+cl1_ext5_BPL1DAT+WORD_SIZE,a1
	REPT vp2_visible_lines_number-1
	move.w	extra_pf2_plane_width*2(a0),cl1_ext5_BPL3DAT-cl1_ext5_BPL1DAT(a1) ; 1st word bitplane 3
	move.w	(a0),(a1)		; 1st word bitplane 1
	add.l	d1,a0			; next line in playfield
	move.w	(extra_pf2_plane_width*1)-(extra_pf2_plane_width*extra_pf2_depth)(a0),cl1_ext5_BPL2DAT-cl1_ext5_BPL1DAT(a1) ; 1st word bitplane 2
	add.l	d2,a1			; next line
	ENDR
	rts


	CNOP 0,4
ss_calculate_xy_coordinates
	movem.l a3-a6,-(a7)
	MOVEF.W	ss_x_radius*2*2,d1
	MOVEF.W	ss_y_radius*2,d2
	move.w	ss_x_radius_angle(a3),d3
	move.w	d3,d0		
	MOVEF.W (sine_table_length-1)*WORD_SIZE,d6 ; overflow 360°
	addq.w	#ss_x_radius_angle_speed*WORD_SIZE,d0
	and.w	d6,d0			; remove overflow
	move.w	d0,ss_x_radius_angle(a3) 
	move.w	ss_x_angle(a3),d4
	move.w	d4,d0
	addq.w	#ss_x_angle_speed*WORD_SIZE,d0
	and.w	d6,d0			; remove overflow
	move.w	d0,ss_x_angle(a3)	
	move.w	ss_y_angle(a3),d5
	move.w	d5,d0
	add.w	ss_variable_y_speed(a3),d0
	and.w	d6,d0			; remove overflow
	move.w	d0,ss_y_angle(a3)	
	lea	sine_table(pc),a0
	lea	ss_xy_coordinates(pc),a1
	move.w	#ss_x_center,a2
	move.w	ss_variable_y_center(a3),a4
	move.w	#ss_x_distance*WORD_SIZE,a3
	move.w	#ss_x_radius_angle_step*WORD_SIZE,a5
	move.w	#ss_y_distance*WORD_SIZE,a6
	REPT ss_reused_sprites_number
	move.w	(a0,d3.w),d0		; cos(w)
	add.w	a5,d3			; next x radius angle
	muls.w	d1,d0			; xr'=(xr*cos(w))/2^15
	swap	d0
	and.w	d6,d3			; remove overflow
	muls.w	(a0,d4.w),d0		; x'=(xr'*cos(w))/2^15
	swap	d0
	add.w	a3,d4			; next x angle
	add.w	a2,d0			; x' + x center
	move.w	d0,(a1)+		; x position
	and.w	d6,d4			; remove overflow
	move.w	(a0,d5.w),d0
	muls.w	d2,d0			; y'=(yr*sin(w))/2^15
	add.w	a6,d5			; next y angle
	swap	d0
	and.w	d6,d5			; remove overflow
	add.w	a4,d0			; y' + y center
	move.w	d0,(a1)+		; y position
	ENDR
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
ss_sort_y_coordinates
	moveq	#-2,d2			; mask to clear bit 0
	lea	ss_xy_starts(pc),a0
	move.l	a0,a1			; store pointer
	lea	(ss_reused_sprites_number-1)*WORD_SIZE(a0),a2 ; last entry
	move.l	a2,a5
	lea	ss_xy_coordinates(pc),a6
ss_quicks
	move.l	a5,d0			; pointer last entry
	add.l	a0,d0			; pointer first entry + last entry
	lsr.l	#1,d0			; middle of table
	and.b	d2,d0			; only even
	move.l	d0,a4			; store middle of table
	move.w	(a4),d1			; xy start
	move.w	WORD_SIZE(a6,d1.w),d0	; y
ss_quick
	move.w	(a1)+,d1		; xy start
	cmp.w	WORD_SIZE(a6,d1.w),d0	; 1st y < middle y ?
	bgt.s	ss_quick
	subq.w	#WORD_SIZE,a1		; reset pointer
	addq.w	#WORD_SIZE,a2		; next xy start
ss_quick2
	move.w	-(a2),d1		; xy start
	cmp.w	WORD_SIZE(a6,d1.w),d0	; penultimate y > middle y ?
	blt.s	ss_quick2
ss_quick3
	cmp.l	a2,a1			; pointer end of table > pointer table beginning ?
	bgt.s	ss_quick4
	move.w	(a2),d1			; last start
	move.w	(a1),(a2)		; 1st start -> last start
	subq.w	#WORD_SIZE,a2		; penultimate start
	move.w	d1,(a1)+		; last start -> 1st start
ss_quick4
	cmp.l	a2,a1			; pointer beginning of table <= pointer end of table ?
	ble.s	ss_quick
	cmp.l	a2,a0			; pointer beginning of table >= pointer end of table ?
	bge.s	ss_quick5
	move.l	a5,-(a7)
	move.l	a2,a5			; store pointer end of table
	move.l	a0,a1
	bsr.s	ss_quicks
	move.l	(a7)+,a5
ss_quick5
	cmp.l	a5,a1			; pointer beginning of table >= pointer end of table ?
	bge.s	ss_quick6
	move.l	a0,-(a7)
	move.l	a1,a0
	move.l	a5,a2
	bsr.s	ss_quicks
	move.l	(a7)+,a0
ss_quick6
	rts


	CNOP 0,4
ss_move_sprites
	movem.l a3-a6,-(a7)
	lea	spr_pointers_construction(pc),a2
	sub.l	a3,a3
	move.w	#spr0_extension1_size,a4
	lea	ss_xy_starts(pc),a5
	lea	ss_xy_coordinates(pc),a6
	moveq	#ss_objects_per_sprite_number-1,d7
ss_move_sprites_loop
	move.l	a2,a1			; pointer sprite structures

	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL
	move.l	(a1)+,a0		; pointer sprite structure
	add.l	a3,a0			; + offset current sprite
	move.w	(a5)+,d0		; xy start
	moveq	#ss_image_y_size,d2
	move.w	WORD_SIZE(a6,d0.w),d1	; y
	add.w	d1,d2			; VSTOP
	move.w	(a6,d0.w),d0		; x
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)+		; SPRxPOS
	move.w	d2,(a0)			; SPRxCTL

	add.l	a4,a3			; next sprite structure
	dbf	d7,ss_move_sprites_loop
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
image_blind_scroll
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	moveq	#0,d5
	move.w	ibs_image_start(a3),d5
	move.l	d5,d0			; store startline
	addq.w	#ibs_speed,d0		; increase startline
	cmp.w	#ibs_image_y_size,d0	; end of playfield ?
	blt.s	image_blind_scroll_skip1
	sub.w	#ibs_image_y_size,d0	; restart
image_blind_scroll_skip1
	move.w	d0,ibs_image_start(a3)
	move.w	ibs_lamella_angle(a3),d1
	move.w	d1,d0	
	addq.w	#ibs_lamella_angle_speed*WORD_SIZE,d0
	and.w	#(sine_table_length*WORD_SIZE)-1,d0 ; remove overflow
	move.w	d0,ibs_lamella_angle(a3)
	MOVEF.W cl2_display_y_size,d4	; lines counter
	move.l	extra_pf1(a3),a1
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1PTH+WORD_SIZE,a2
	move.w	#ibs_image_y_size,a3	; number of lines
	lea	sine_table(pc),a4
	move.w	#ibs_lamella_center,a5
	move.w	#extra_pf1_plane_width-WORD_SIZE,a6
	move.w	#LONGWORD_SIZE*3,a7
	MOVEF.W	ibs_lamellas_number-1,d7
image_blind_scroll_loop1
	move.l	d5,d3			; startline
	move.w	(a4,d1.w),d6		; sin(w)
	MULSF.W ibs_lamella_radius*2,d6,d0 ; y' = (yr*sin(w))/2^15
	swap	d6
	add.w	a5,d6			; y' + y center = lamella height
image_blind_scroll_loop2
	move.l	a1,a0			; bitplanes
	move.l	d3,d2			; startline
	MULUF.L extra_pf1_plane_width*extra_pf1_depth,d2,d0 ; y offset in playfield
	add.l	d2,a0			; add y offset
	REPT extra_pf1_depth
	move.w	(a0)+,QUADWORD_SIZE(a2)	; BPLxDAT
	move.l	a0,d0			; bitplane
	move.w	d0,LONGWORD_SIZE(a2)	; BPLxPTL
	swap	d0
	add.l	a6,a0			; next bitplane
	move.w	d0,(a2)			; BPLxPTH
	sub.l	a7,a2			; previous cl section
	ENDR
	ADDF.W	LONGWORD_SIZE*25,a2	; skip CWAIT + 24 x CMOVE
	subq.w	#1,d4			; decrease lines counter
	beq.s	image_blind_scroll_skip4
	addq.w	#ibs_step1,d3		; increase startline
	cmp.w	a3,d3			; end of playfield ?
	blt.s	image_blind_scroll_skip2
	sub.w	a3,d3			; restart
image_blind_scroll_skip2
	dbf	d6,image_blind_scroll_loop2
	addq.w	#ibs_step2,d5		; increase startline
	cmp.w	a3,d5			; end of playfield ?
	blt.s	image_blind_scroll_skip3
	sub.w	a3,d5			; restart
image_blind_scroll_skip3
	addq.w	#ibs_lamella_angle_step*WORD_SIZE,d1
	and.w	#(sine_table_length*WORD_SIZE)-1,d1 ; remove overflow
	dbf	d7,image_blind_scroll_loop1
image_blind_scroll_skip4
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
rgb4_logo_fader_in
	movem.l a4-a5,-(a7)
	tst.w	lfi_rgb4_active(a3)
	bne.s	rgb4_logo_fader_in_quit
	subq.w	#1,lfi_delay_counter(a3)
	bne.s	rgb4_logo_fader_in_quit
	move.w	#lfi_delay,lfi_delay_counter(a3)
	MOVEF.W lf_rgb4_colors_number*3,d6 ; RGB counter
	lea	vp1_pf1_rgb4_color_table+(lf_rgb4_color_table_offset*WORD_SIZE)(pc),a0 ; colors buffer
	lea	lfi_rgb4_color_table+(lf_rgb4_color_table_offset*WORD_SIZE)(pc),a1 ; destination colors
	move.w	#lfi_rgb4_fader_speed<<8,a2 ; increase/decrease red
	move.w	#lfi_rgb4_fader_speed<<4,a4 ; increase/decrease green
	move.w	#lfi_rgb4_fader_speed,a5 ; increase/decrease blue
	MOVEF.W lf_rgb4_colors_number-1,d7
	bsr.s	if_rgb4_fader_loop
	move.w	d6,lf_rgb4_colors_counter(a3) ; fading finished ?
	bne.s	rgb4_logo_fader_in_quit
	move.w	#FALSE,lfi_rgb4_active(a3)
	move.w	#1,tw_delay_counter(a3)	; enable counter
	clr.w	tw_cursor_active(a3)
rgb4_logo_fader_in_quit
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
rgb4_logo_fader_out
	movem.l a4-a5,-(a7)
	tst.w	lfo_rgb4_active(a3)
	bne.s	rgb4_logo_fader_out_quit
	subq.w	#1,lfo_delay_counter(a3)
	bne.s	rgb4_logo_fader_out_quit
	move.w	#lfo_delay,lfo_delay_counter(a3)
	MOVEF.W lf_rgb4_colors_number*3,d6 ; RGB counter
	lea	vp1_pf1_rgb4_color_table+(lf_rgb4_color_table_offset*WORD_SIZE)(pc),a0 ; colors buffer
	lea	lfo_rgb4_color_table+(lf_rgb4_color_table_offset*WORD_SIZE)(pc),a1 ; destination colors
	move.w	#lfo_rgb4_fader_speed<<8,a2 ; increase/decrease red
	move.w	#lfo_rgb4_fader_speed<<4,a4 ; increase/decrease green
	move.w	#lfo_rgb4_fader_speed,a5 ; increase/decrease blue
	MOVEF.W lf_rgb4_colors_number-1,d7
	bsr.s	if_rgb4_fader_loop
	move.w	d6,lf_rgb4_colors_counter(a3) ; fading finished ?
	bne.s	rgb4_logo_fader_out_quit
	move.w	#FALSE,lfo_rgb4_active(a3)
rgb4_logo_fader_out_quit
	movem.l (a7)+,a4-a5
	rts


	RGB4_COLOR_FADER if


	COPY_RGB4_COLORS_TO_COPPERLIST lf,vp1_pf1,cl1,cl1_extension1_entry+cl1_ext1_COLOR00


	CNOP 0,4
rgb4_bar_fader_in
	movem.l a4-a6,-(a7)
	tst.w	bfi_rgb4_active(a3)
	bne.s	rgb4_bar_fader_in_quit
	subq.w	#1,bfi_delay_counter(a3)
	bne.s	rgb4_bar_fader_in_quit
	move.w	#bfi_delay,bfi_delay_counter(a3)
	MOVEF.W bf_rgb4_colors_number*3,d6 ; RGB counter
	lea	bf_rgb4_color_cache+(bf_rgb4_color_table_offset*WORD_SIZE)(pc),a0 ; colors buffer
	lea	bfi_rgb4_color_table+(bf_rgb4_color_table_offset*WORD_SIZE)(pc),a1 ; destination colors
	move.w	#bfi_rgb4_fader_speed<<8,a2 ; increase/decrease red
	move.w	#bfi_rgb4_fader_speed<<4,a4 ; increase/decrease green
	move.w	#bfi_rgb4_fader_speed,a5 ; increase/decrease blue
	MOVEF.W bf_rgb4_colors_number-1,d7
	bsr	if_rgb4_fader_loop
	move.w	d6,bf_rgb4_colors_counter(a3) ; fader finished ?
	bne.s	rgb4_bar_fader_in_quit
	move.w	#FALSE,bfi_rgb4_active(a3)
rgb4_bar_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
rgb4_bar_fader_out
	movem.l a4-a6,-(a7)
	tst.w	bfo_rgb4_active(a3)
	bne.s	rgb4_bar_fader_out_quit
	subq.w	#1,bfo_delay_counter(a3)
	bne.s	rgb4_bar_fader_out_quit
	move.w	#bfo_delay,bfo_delay_counter(a3)
	MOVEF.W bf_rgb4_colors_number*3,d6 ; RGB counter
	lea	bf_rgb4_color_cache+(bf_rgb4_color_table_offset*WORD_SIZE)(pc),a0 ; colors buffer
	lea	bfo_rgb4_color_table+(bf_rgb4_color_table_offset*WORD_SIZE)(pc),a1 ; destination colors
	move.w	#bfo_rgb4_fader_speed<<8,a2 ; increase/decrease red
	move.w	#bfo_rgb4_fader_speed<<4,a4 ; increase/decrease green
	move.w	#bfo_rgb4_fader_speed,a5 ; increase/decrease blue
	MOVEF.W bf_rgb4_colors_number-1,d7
	bsr	if_rgb4_fader_loop
	move.w	d6,bf_rgb4_colors_counter(a3) ; fader finished ?
	bne.s	rgb4_bar_fader_out_quit
	move.w	#FALSE,bfo_rgb4_active(a3)
rgb4_bar_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
bf_rgb4_copy_color_table
	tst.w	bf_rgb4_copy_colors_active(a3)
	bne.s	bf_rgb4_copy_color_table_quit
	lea	bf_rgb4_color_cache(pc),a0 ; source: colors buffer
	move.l	cl1_display(a3),a1	; destination: cl
	ADDF.W	cl1_extension3_entry+cl1_ext3_COLOR00+WORD_SIZE,a1
	move.w	#cl1_extension3_size,a2
	REPT bf_rgb4_colors_number
	move.w	(a0)+,(a1)		; copy RGB4 value
	add.l	a2,a1			; next section
	ENDR
	tst.w	bf_rgb4_colors_counter(a3)
	bne.s	bf_rgb4_copy_color_table_quit
	move.w	#FALSE,bf_rgb4_copy_colors_active(a3)
bf_rgb4_copy_color_table_quit
	rts


	CNOP 0,4
rgb4_textwriter_fader_out
	movem.l a4-a5,-(a7)
	tst.w	tfo_rgb4_active(a3)
	bne.s	rgb4_textwriter_fader_out_quit
	subq.w	#1,tfo_delay_counter(a3)
	bne.s	rgb4_textwriter_fader_out_quit
	move.w	#tfo_delay,tfo_delay_counter(a3)
	MOVEF.W tf_rgb4_colors_number*3,d6 ; RGB counter
	lea	vp2_pf1_rgb4_color_table+(tf_rgb4_color_table_offset*WORD_SIZE)(pc),a0 ; colors buffer
	lea	tfo_rgb4_color_table+(tf_rgb4_color_table_offset*WORD_SIZE)(pc),a1 ; destination colors
	move.w	#tfo_rgb4_fader_speed<<8,a2 ; increase/decrease red
	move.w	#tfo_rgb4_fader_speed<<4,a4 ; increase/decrease green
	move.w	#tfo_rgb4_fader_speed,a5 ; increase/decrease blue
	MOVEF.W tf_rgb4_colors_number-1,d7
	bsr	if_rgb4_fader_loop
	move.w	d6,tf_rgb4_colors_counter(a3) ; fading finished ?
	bne.s	rgb4_textwriter_fader_out_quit
	move.w	#FALSE,tfo_rgb4_active(a3)
rgb4_textwriter_fader_out_quit
	movem.l (a7)+,a4-a5
	rts


	COPY_RGB4_COLORS_TO_COPPERLIST tf,vp2_pf1,cl1,cl1_extension4_entry+cl1_ext4_COLOR00


	CNOP 0,4
scroll_sprites_bottom_in
	move.l	a4,-(a7)
	tst.w	ssbi_active(a3)
	bne.s	scroll_sprites_bottom_in_quit
	move.w	ssbi_y_angle(a3),d2
	cmp.w	#(sine_table_length/4)*WORD_SIZE,d2 ; 90° ?
	ble.s	scroll_sprites_bottom_in_skip
	move.w	#FALSE,ssbi_active(a3)
	clr.w	ss_sprites_visible(a3)
	bra.s	scroll_sprites_bottom_in_quit
	CNOP 0,4
scroll_sprites_bottom_in_skip
	lea	sine_table(pc),a0
	move.w	(a0,d2.w),d0		; sin(w)
	MULSF.W	ssb_y_radius*2,d0,d1	; y'=yr*cos(w)/2^16
	swap	d0
	add.w	#ssb_y_center,d0
	add.w	#ss_y_center,d0		; vertical centering
	move.w	d0,ss_variable_y_center(a3)
	addq.w	#ssbi_y_angle_speed*WORD_SIZE,d2
	move.w	d2,ssbi_y_angle(a3)
scroll_sprites_bottom_in_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
scroll_sprites_bottom_out
	move.l	a4,-(a7)
	tst.w	ssbo_active(a3)
	bne.s	scroll_sprites_bottom_out_quit
	move.w	ssbo_y_angle(a3),d2
	cmp.w	#(sine_table_length/2)*WORD_SIZE,d2 ; 180° ?
	ble.s	scroll_sprites_bottom_out_skip
	moveq	#FALSE,d0
	move.w	d0,ssbo_active(a3)
	move.w	d0,ss_sprites_visible(a3)
	bra.s	scroll_sprites_bottom_out_quit
	CNOP 0,4
scroll_sprites_bottom_out_skip
	lea	sine_table(pc),a0
	move.w	(a0,d2.w),d0		; sin(w)
	MULSF.W	ssb_y_radius*2,d0,d1	; y'=yr*cos(w)/2^16
	swap	d0
	add.w	#ssb_y_center,d0
	add.w	#ss_y_center,d0		; vertical centering
	move.w	d0,ss_variable_y_center(a3)
	addq.w	#ssbi_y_angle_speed*WORD_SIZE,d2
	move.w	d2,ssbo_y_angle(a3)
scroll_sprites_bottom_out_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
mouse_handler
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	bne.s	mouse_handler_quit
; Module-Fader
	moveq	#TRUE,d0
	move.w	d0,pt_music_fader_active(a3)
; Logo-Fader
	move.w	d0,lfo_rgb4_active(a3)
	tst.w	lfi_rgb4_active(a3)	; fader in still active ?
	bne.s	mouse_handler_skip1
	move.w	#FALSE,lfi_rgb4_active(a3) ; force stop
mouse_handler_skip1
	move.w	d0,lf_rgb4_copy_colors_active(a3)
	move.w	#lf_rgb4_colors_number*3,lf_rgb4_colors_counter(a3)
; Text-Fader
	move.w	d0,tfo_rgb4_active(a3)
	move.w	d0,tf_rgb4_copy_colors_active(a3)
	move.w	#tf_rgb4_colors_number*3,tf_rgb4_colors_counter(a3)
; Bar-Fader
	tst.w	bfi_rgb4_active(a3)	; fader still active ?
	bne.s	mouse_handler_skip2
	move.w	#FALSE,bfi_rgb4_active(a3) ; force fader stop
mouse_handler_skip2
	move.w	d0,bfo_rgb4_active(a3)
	move.w	#bf_rgb4_colors_number*3,bf_rgb4_colors_counter(a3)
	move.w	d0,bf_rgb4_copy_colors_active(a3)
; Scroll-Sprites-Bottom
	move.w	ssbo_y_angle(a3),d1
	tst.w	ss_sprites_visible(a3)
	bne.s	mouse_handler_quit
	tst.w	ssbi_active(a3)		; fader still active ?
	bne.s	mouse_handler_skip3
	move.w	#FALSE,ssbi_active(a3)	; force fader stop
mouse_handler_skip3
	move.w	d0,ssbo_active(a3)
	move.w	#(sine_table_length/4)*WORD_SIZE,ssbo_y_angle(a3) ; 90°
mouse_handler_quit
	rts


; Input
; Result
	CNOP 0,4
control_counters
; Textwriter
	move.w	tw_delay_counter(a3),d0
	bmi.s	control_counters_skip2
	subq.w	#1,d0
	bne.s	control_counters_skip1
	MOVEF.W	tw_delay,d0		; reset counter
	clr.w	tw_active(a3)
control_counters_skip1
	move.w	d0,tw_delay_counter(a3)
control_counters_skip2
; Clear-Text
	move.w	ct_delay_counter(a3),d0
	bmi.s	control_counters_skip4
	subq.w	#1,d0
	bne.s	control_counters_skip3
	move.w	#ct_backspace_delay,ct_backspace_delay_counter(a3)
	clr.w	tw_cursor_active(a3)
control_counters_skip3
	move.w	d0,ct_delay_counter(a3)
control_counters_skip4
; Backspace
	move.w	ct_backspace_delay_counter(a3),d0
	bmi.s	control_counters_skip6
	subq.w	#1,d0
	bne.s	control_counters_skip5
	MOVEF.W	ct_backspace_delay,d0	; continuous counter
	clr.w	ct_backspace_active(a3)
control_counters_skip5
	move.w	d0,ct_backspace_delay_counter(a3)
control_counters_skip6
	rts


	INCLUDE "int-autovectors-handlers.i"

	IFEQ pt_ciatiming_enabled
		CNOP 0,4
ciab_ta_interrupt_server
	ELSE
		CNOP 0,4
vertb_interrupt_server
	ENDC


; PT-Replay
	IFEQ pt_music_fader_enabled
		bsr.s	pt_music_fader
		bsr.s	pt_PlayMusic
		rts

		PT_FADE_OUT_VOLUME stop_fx_active

		CNOP 0,4
	ENDC

	IFD PROTRACKER_VERSION_2 
		PT2_REPLAY pt_effects_handler
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_REPLAY pt_effects_handler
	ENDC

	CNOP 0,4
pt_effects_handler
	tst.w	pt_effects_handler_active(a3)
	bne.s	pt_effects_handler_quit
	move.b	n_cmdlo(a2),d0
	cmp.b	#$10,d0
	beq.s	pt_scroll_sprites_bottom_in
	cmp.b	#$11,d0
	beq.s	pt_scroll_sprites_bottom_out
	and.b	#NIBBLE_MASK_HIGH,d0
	cmp.b	#$20,d0
	beq.s	pt_select_sprite_movement
pt_effects_handler_quit
	rts
	CNOP 0,4
pt_scroll_sprites_bottom_in
	moveq	#TRUE,d0
	move.w	d0,ssbi_active(a3)
	move.w	d0,ssbi_y_angle(a3)	; 0°
	rts
	CNOP 0,4
pt_scroll_sprites_bottom_out
	clr.w	ssbo_active(a3)
	move.w	#(sine_table_length/4)*WORD_SIZE,ssbo_y_angle(a3) ; 90°
	rts
	CNOP 0,4
pt_select_sprite_movement
	move.l	a0,-(a7)
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0
	MULUF.W	WORD_SIZE,d0,d7
	lea	ss_movements(pc),a0
	move.w	(a0,d0.w),ss_variable_y_speed(a3)
	move.l	(a7)+,a0
	rts


	CNOP 0,4
ciab_tb_interrupt_server
	PT_TIMER_INTERRUPT_SERVER

	CNOP 0,4
exter_interrupt_server
	rts

	CNOP 0,4
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,2
pf1_rgb4_color_table
	DC.W color00_bits

	CNOP 0,2
vp1_pf1_rgb4_color_table
	REPT vp1_pf1_colors_number
	DC.W color00_bits
	ENDR

	CNOP 0,2
vp2_pf1_rgb4_color_table
	INCLUDE "Lowres4:colorpalettes/16x15x4-Font.ct"
	DC.W color00_bits,color00_bits,color00_bits
	DC.W $59b			; cursor color

	CNOP 0,2
spr_rgb4_color_table
	INCLUDE "Lowres4:colorpalettes/7x7x4-Heart.ct"
	INCLUDE "Lowres4:colorpalettes/7x7x4-Heart.ct"
	INCLUDE "Lowres4:colorpalettes/7x7x4-Heart.ct"
	INCLUDE "Lowres4:colorpalettes/7x7x4-Heart.ct"


	CNOP 0,4
spr_pointers_construction
	DS.L spr_number

	CNOP 0,4
spr_pointers_display
	DS.L spr_number


	CNOP 0,2
sine_table
	DC.W $0000,$FE72,$FCE3,$FB54,$F9C5,$F837
	DC.W $F6A9,$F51B,$F38E,$F201,$F075,$EEE9
	DC.W $ED5E,$EBD4,$EA4A,$E8C2,$E73A,$E5B3
	DC.W $E42D,$E2A8,$E125,$DFA2,$DE21,$DCA1
	DC.W $DB23,$D9A6,$D82A,$D6B0,$D538,$D3C1
	DC.W $D24C,$D0D8,$CF67,$CDF7,$CC89,$CB1E
	DC.W $C9B4,$C84C,$C6E7,$C583,$C422,$C2C4
	DC.W $C167,$C00D,$BEB6,$BD61,$BC0F,$BABF
	DC.W $B972,$B827,$B6E0,$B59B,$B459,$B31A
	DC.W $B1DE,$B0A5,$AF6F,$AE3C,$AD0D,$ABE0
	DC.W $AAB7,$A991,$A86E,$A74F,$A633,$A51B
	DC.W $A406,$A2F4,$A1E7,$A0DD,$9FD6,$9ED3
	DC.W $9DD4,$9CD9,$9BE2,$9AEE,$99FF,$9913
	DC.W $982B,$9747,$9668,$958C,$94B5,$93E1
	DC.W $9312,$9247,$9180,$90BE,$8FFF,$8F46
	DC.W $8E90,$8DDF,$8D32,$8C8A,$8BE6,$8B46
	DC.W $8AAB,$8A15,$8983,$88F6,$886D,$87E9
	DC.W $8769,$86EF,$8678,$8607,$859A,$8532
	DC.W $84CF,$8470,$8416,$83C1,$8371,$8326
	DC.W $82DF,$829D,$8260,$8228,$81F5,$81C7
	DC.W $819D,$8178,$8159,$813E,$8128,$8117
	DC.W $810A,$8103,$8100,$8103,$810A,$8117
	DC.W $8128,$813E,$8159,$8178,$819D,$81C7
	DC.W $81F5,$8228,$8260,$829D,$82DF,$8326
	DC.W $8371,$83C1,$8416,$8470,$84CF,$8532
	DC.W $859A,$8607,$8678,$86EF,$8769,$87E9
	DC.W $886D,$88F6,$8983,$8A15,$8AAB,$8B46
	DC.W $8BE6,$8C8A,$8D32,$8DDF,$8E90,$8F46
	DC.W $9000,$90BE,$9180,$9247,$9312,$93E1
	DC.W $94B5,$958C,$9668,$9747,$982B,$9913
	DC.W $99FF,$9AEE,$9BE2,$9CD9,$9DD4,$9ED3
	DC.W $9FD6,$A0DD,$A1E7,$A2F5,$A406,$A51B
	DC.W $A633,$A74F,$A86E,$A991,$AAB7,$ABE0
	DC.W $AD0D,$AE3C,$AF6F,$B0A5,$B1DE,$B31A
	DC.W $B459,$B59B,$B6E0,$B828,$B972,$BABF
	DC.W $BC0F,$BD61,$BEB6,$C00E,$C167,$C2C4
	DC.W $C423,$C584,$C6E7,$C84C,$C9B4,$CB1E
	DC.W $CC89,$CDF7,$CF67,$D0D8,$D24C,$D3C1
	DC.W $D538,$D6B0,$D82A,$D9A6,$DB23,$DCA1
	DC.W $DE21,$DFA2,$E125,$E2A8,$E42D,$E5B3
	DC.W $E73A,$E8C2,$EA4A,$EBD4,$ED5E,$EEE9
	DC.W $F075,$F201,$F38E,$F51B,$F6A9,$F837
	DC.W $F9C5,$FB54,$FCE3,$FE72,$0000,$018F
	DC.W $031E,$04AC,$063B,$07C9,$0957,$0AE5
	DC.W $0C72,$0DFF,$0F8B,$1117,$12A2,$142C
	DC.W $15B6,$173F,$18C6,$1A4D,$1BD3,$1D58
	DC.W $1EDB,$205E,$21DF,$235F,$24DD,$265B
	DC.W $27D6,$2950,$2AC9,$2C3F,$2DB5,$2F28
	DC.W $3099,$3209,$3377,$34E3,$364C,$37B4
	DC.W $3919,$3A7D,$3BDE,$3D3C,$3E99,$3FF3
	DC.W $414A,$429F,$43F2,$4541,$468E,$47D9
	DC.W $4920,$4A65,$4BA7,$4CE6,$4E22,$4F5B
	DC.W $5091,$51C4,$52F4,$5420,$5549,$566F
	DC.W $5792,$58B1,$59CD,$5AE6,$5BFA,$5D0C
	DC.W $5E19,$5F24,$602A,$612D,$622C,$6327
	DC.W $641E,$6512,$6602,$66ED,$67D5,$68B9
	DC.W $6998,$6A74,$6B4C,$6C1F,$6CEE,$6DB9
	DC.W $6E80,$6F42,$7001,$70BB,$7170,$7221
	DC.W $72CE,$7376,$741A,$74BA,$7555,$75EB
	DC.W $767D,$770A,$7793,$7817,$7897,$7911
	DC.W $7988,$79F9,$7A66,$7ACE,$7B31,$7B90
	DC.W $7BEA,$7C3F,$7C8F,$7CDA,$7D21,$7D63
	DC.W $7DA0,$7DD8,$7E0B,$7E39,$7E63,$7E88
	DC.W $7EA7,$7EC2,$7ED8,$7EE9,$7EF6,$7EFD
	DC.W $7F00,$7EFD,$7EF6,$7EE9,$7ED8,$7EC2
	DC.W $7EA7,$7E88,$7E63,$7E39,$7E0B,$7DD8
	DC.W $7DA0,$7D63,$7D21,$7CDA,$7C8F,$7C3E
	DC.W $7BE9,$7B90,$7B31,$7ACE,$7A66,$79F9
	DC.W $7987,$7911,$7896,$7817,$7793,$770A
	DC.W $767D,$75EB,$7555,$74BA,$741A,$7376
	DC.W $72CE,$7221,$7170,$70BA,$7000,$6F42
	DC.W $6E80,$6DB9,$6CEE,$6C1F,$6B4B,$6A74
	DC.W $6998,$68B8,$67D5,$66ED,$6601,$6512
	DC.W $641E,$6327,$622B,$612C,$602A,$5F23
	DC.W $5E19,$5D0B,$5BFA,$5AE5,$59CD,$58B1
	DC.W $5792,$566F,$5549,$5420,$52F3,$51C3
	DC.W $5091,$4F5B,$4E22,$4CE6,$4BA7,$4A65
	DC.W $4920,$47D8,$468E,$4541,$43F1,$429F
	DC.W $414A,$3FF2,$3E98,$3D3C,$3BDD,$3A7C
	DC.W $3919,$37B3,$364C,$34E2,$3376,$3209
	DC.W $3099,$2F27,$2DB4,$2C3F,$2AC8,$2950
	DC.W $27D6,$265A,$24DD,$235E,$21DE,$205D
	DC.W $1EDB,$1D57,$1BD2,$1A4D,$18C6,$173E
	DC.W $15B5,$142C,$12A2,$1117,$0F8B,$0DFF
	DC.W $0C72,$0AE4,$0957,$07C9,$063A,$04AC
	DC.W $031D,$018E


; PT-Replay
	INCLUDE "music-tracker/pt-invert-table.i"

	INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

	IFD PROTRACKER_VERSION_2
		INCLUDE "music-tracker/pt2-period-table.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-period-table.i"
	ENDC

	INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

	INCLUDE "music-tracker/pt-sample-starts-table.i"

	INCLUDE "music-tracker/pt-finetune-starts-table.i"


; Textwriter
tw_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/&<>#*°¹²³³@+ "
tw_ascii_end
	EVEN

	CNOP 0,2
tw_chars_offsets
	DS.W tw_ascii_end-tw_ascii


; Sine-Sprites
	CNOP 0,2
ss_xy_starts
	DS.W ss_objects_number

	CNOP 0,2
ss_xy_coordinates
	DS.W ss_objects_number*2

	CNOP 0,2
ss_movements
	DC.W 1*WORD_SIZE
	DC.W 4*WORD_SIZE
	DC.W 6*WORD_SIZE
	DC.W 7*WORD_SIZE


; Logo-Fader-In
	CNOP 0,2
lfi_rgb4_color_table
	INCLUDE "Lowres4:colorpalettes/352x70x16-Title.ct"


; Logo-Fader-Out
	CNOP 0,2
lfo_rgb4_color_table
	REPT vp1_pf1_colors_number
	DC.W color00_bits
	ENDR


; Bar-Fader 
	CNOP 0,2
bfi_rgb4_color_table
	INCLUDE "Lowres4:colorpalettes/6-Colorgradient.ct"

	CNOP 0,2
bfo_rgb4_color_table
	REPT vb_bar_height
	DC.W color00_bits
	ENDR

	CNOP 0,2
bf_rgb4_color_cache
	REPT vb_bar_height
	DC.W color00_bits
	ENDR


; Textwriter-Fader-Out
	CNOP 0,2
tfo_rgb4_color_table
	REPT vp2_pf1_colors_number
	DC.W color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


	DC.B "$VER: "
	DC.B "Lowres4Intro "
	DC.B "1.0 "
	DC.B "(7.2.26) "
	DC.B "© 2026 by Resistance",0
	EVEN


; Textwriter
tw_text
; Page 1
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "WELCOME #"
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "AND ENJOY"
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "THE LOW RESOLUTION."
	DC.B ASCII_CTRL_S," "

; Page 2
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "INSERT DISK."
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "FLIP THE SWITCH."
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "WAIT FOR THE MAGIC."
	DC.B ASCII_CTRL_S," "

; Page 3
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "RETRO COMPUTERS."
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "REAL HARDWARE."
	DC.B ASCII_CTRL_M
	DC.B ASCII_CTRL_M
	DC.B "PURE CREATIVITY."
	DC.B ASCII_CTRL_S," "

	DC.B FALSE
	EVEN


; Audio data

; PT-Replay
	IFEQ pt_split_module_enabled
pt_auddata			SECTION pt_audio,DATA
		INCBIN "Lowres4:trackermodules/MOD.beats'n'bits.song"
pt_audsmps			SECTION pt_audio2,DATA_C
		INCBIN "Lowres4:trackermodules/MOD.beats'n'bits.smps"
	ELSE
pt_auddata			SECTION pt_audio,DATA_C
		INCBIN "Lowres4:trackermodules/MOD.beats'n'bits"
	ENDC


; Gfx data

; Logo
lg_image_data			SECTION lg_gfx,DATA
	INCBIN "Lowres4:graphics/352x70x16-Title.rawblit"

; Textwriter
tw_image_data			SECTION tw_gfx,DATA
	INCBIN "Lowres4:fonts/16x15x4-Font.rawblit"

; Sine-Sprites
ss_image_data			SECTION ss_gfx,DATA
	INCBIN "Lowres4:graphics/7x7x4-Heart.rawblit"

	END
