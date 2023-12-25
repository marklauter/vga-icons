	page	132,66
	TITLE	VGACON.ASM - SCREEN BIOS CALLS
;/************************************************/
;/*  Commercial Demand Management System	 */
;/*  (CDMS)					 */
;/*  (c)Copyright 1994 Tampa Electric Co., Inc.  */
;/*  written by Gary E. Speegle 		 */
;/*	       & Robert D. Howerton		 */
;/*		 26-May-1994			 */
;/************************************************/

	extrn	_norm_attrib:byte
	extrn	_rev_attrib:byte
	extrn	_bold_attrib:byte
	extrn	_clear_attrib:byte
	extrn	_hb_fields:word
	extrn	_mouse_buttons:word
	extrn	_malloc:far
	extrn	_free:far

	PUBLIC	_kbchar
	PUBLIC	_unkbchar
	PUBLIC	_clear
	PUBLIC	_position
	PUBLIC	_lclear2end
	PUBLIC	_lclearline
	PUBLIC	_rev
	PUBLIC	_norm
	PUBLIC	_bold
	PUBLIC	_text
	PUBLIC	_ptext
	PUBLIC	_printer1
	PUBLIC	_printerstat
	PUBLIC	_scroll_window_up
	PUBLIC	_scroll_window_down
	PUBLIC	_kb_stat
	PUBLIC	_get_cursor
	PUBLIC	_set_cursor
	PUBLIC	_get_window
	PUBLIC	_put_window
	PUBLIC	_get_screen
	PUBLIC	_put_screen
	PUBLIC	_attrib
	PUBLIC	_send_com
	PUBLIC	_com_input
	PUBLIC	_get_font_loc
	PUBLIC	_show_logo
	PUBLIC	_area_clear
	PUBLIC	_hline
	PUBLIC	_vline
	PUBLIC	_pline
	PUBLIC	_line
	PUBLIC	_up_arrow
	PUBLIC	_down_arrow
	PUBLIC	_find_mouse
	PUBLIC	_mouse_on
	PUBLIC	_mouse_off
	PUBLIC	_hide_mouse
	PUBLIC	_unhide_mouse
	PUBLIC	_mouse_pressed
	PUBLIC	_mouse_field
	PUBLIC	_mouse_data
	PUBLIC	_position_mouse
	PUBLIC	_vga_pallet

	assume	cs:con_text, ds:nothing
CON_TEXT segment PUBLIC BYTE 'CODE'

mouse_found	dw  0
mouse_hidden	dw 0

_find_mouse proc far
	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, 3533h	; get mouse interrupt vector
	int	21h		;
	mov	ax, es
	xor	cx, cx		; no mouse
	or	ax, bx		;
	jz	fm_exit 	; no mouse driver loaded

	cmp	byte ptr es:[bx], 0CFh
	je	fm_exit 	; int 33 is an IRET -- no mouse driver

	mov	ax, 00H 	; init mouse
	int	33H
	xor	ah, ah
	mov	cx, ax

fm_exit:
	mov	ax, cx
	mov	mouse_found, ax
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_find_mouse endp

_mouse_on proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	mon_exit

	mov	ax, mouse_hidden
	or	ax, ax
	jnz	mon_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, 01H 	; show mouse
	int	33H

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
mon_exit:
	ret
_mouse_on endp

_mouse_off proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	moff_exit

	mov	ax, mouse_hidden
	or	ax, ax
	jnz	moff_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, 02H 	; hide mouse
	int	33H

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
moff_exit:
	ret
_mouse_off endp

_unhide_mouse proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	uhm_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	xor	ax, ax
	mov	mouse_hidden, ax

	mov	ax, 01H 	; show mouse
	int	33H

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
uhm_exit:
	ret
_unhide_mouse endp

_hide_mouse proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	hm_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, 0FFh
	mov	mouse_hidden, ax

	mov	ax, 02H 	; hide mouse
	int	33H

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
hm_exit:
	ret
_hide_mouse endp

mouse_x 	dw  0
mouse_y 	dw  0
mouse_buttons	dw 0

_mouse_pressed proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	mp_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, 03H 	; button status & position
	int	33H

	mov	mouse_x, cx
	mov	mouse_y, dx
	mov	ax, bx
	and	bx, 2
	mov	mouse_buttons, bx

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
mp_exit:
	ret
_mouse_pressed endp


_mouse_data proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	md_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es


	mov	ax, 03H 	; button status & position
	int	33H

	mov	ax, [bp+8]
	mov	es, ax
	mov	ax, [bp+6]
	mov	di, ax

	mov	es:[di+4], cx	; mouse X
	mov	es:[di+2], dx	; mouse y
	mov	es:[di+0], bx	; buttons

	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
md_exit:
	ret
_mouse_data endp


_mouse_field proc far
	mov	ax, mouse_found
	or	ax, ax
	jz	mf_exit

	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, seg _mouse_buttons
	mov	ds, ax
	mov	ax, offset _mouse_buttons
	mov	di, ax
	mov	ax, mouse_buttons
	mov	ds:[di], ax
	mov	ax, [bp+8]
	mov	ds, ax
	mov	si, [bp+6]	    ; get field list into DS:SI

	mov	cx, mouse_x
	mov	dx, mouse_y
	mov	di, 1		    ; field number
mf_loop:
	cmp	word ptr [si], -1   ; end of list
	je	mf_not_found

	cmp	dx, [si]	    ; low row value
	jc	mf_next

	cmp	[si+4], dx	    ; high row value
	jc	mf_next

	cmp	cx, [si+2]	    ; low col value
	jc	mf_next

	cmp	[si+6], cx
	jc	mf_next

mf_found:
	mov	ax, di
	neg	ax
	jmp	mf_exit

mf_next:
	add	si, 8
	inc	di
	jmp	mf_loop


mf_not_found:			; one last check... look for help button...
	mov	ax, seg _hb_fields
	mov	ds, ax
	mov	si, offset _hb_fields	   ; get field list into DS:SI
	cmp	dx, [si]	    ; low row value
	jc	mf_return_false

	cmp	[si+4], dx	    ; high row value
	jc	mf_return_false

	cmp	cx, [si+2]	    ; low col value
	jc	mf_return_false

	cmp	[si+6], cx
	jc	mf_return_false

	mov	ax, -200
	jmp	short mf_exit

mf_return_false:
	xor	ax, ax
	jmp	short mf_exit
mf_exit:
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_mouse_field endp


_position_mouse proc far
	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, mouse_found
	or	ax, ax
	jz	pm_exit

	mov	cx, [bp+8]	; column
	mov	dx, [bp+6]	; row
	mov	ax, 04H 	; set mouse position
	int	33H


pm_exit:
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_position_mouse endp


font_loc    dd	0

_get_font_loc proc    far
	push	bp
	mov	bp,sp
	push	es
; end of initialization

	xor	ax, ax
	mov	es, ax
	mov	bx, 010cH
;	mov	ax, es:[bx]
;	mov	dx, es:[bx+2]
	mov	ax, [bp+6]
	mov	dx, [bp+8]
	mov	word ptr font_loc, ax
	mov	word ptr font_loc+2, dx

; exit code
	pop	es
	mov	sp,bp
	pop	bp
	ret
_get_font_loc endp

;	    Red,Grn,Blu
vga_pallet:
	db   00, 00, 00  ; color 0
	db   00, 00, 32  ; color 1
	db   00, 32, 00  ; color 2
	db   00, 32, 32  ; color 3
	db   32, 00, 00  ; color 4
	db   32, 00, 32  ; color 5
	db   32, 32, 00  ; color 6
	db   48, 48, 48  ; color 7
	db   32, 32, 32  ; color 8
	db   00, 00, 63  ; color 9
	db   00, 63, 00  ; color A
	db   00, 63, 63  ; color B
	db   63, 00, 00  ; color C
	db   63, 00, 63  ; color D
	db   63, 63, 00  ; color E
	db   63, 63, 63  ; color F

vga_pallet_norm:
	db   00, 00, 00  ; color 0
	db   00, 00, 32  ; color 1  was: 00, 00, 42
	db   00, 42, 00  ; color 2
	db   00, 42, 42  ; color 3
	db   42, 00, 00  ; color 4
	db   42, 00, 42  ; color 5
	db   42, 21, 00  ; color 6
	db   42, 42, 42  ; color 7
	db   21, 21, 21  ; color 8
	db   00, 00, 63  ; color 9  was: 21, 21, 63
	db   21, 63, 21  ; color A
	db   21, 63, 63  ; color B
	db   63, 21, 21  ; color C
	db   63, 21, 63  ; color D
	db   63, 63, 21  ; color E
	db   63, 63, 63  ; color F


_vga_pallet proc far
	push	bp
	mov	bp,sp
	push	es
	push	ds
	push	si
	push	di
; end of initialization

	push	cs
	pop	ax
	mov	es,ax
	mov	ax, [bp+6]
	or	ax, ax
	jnz	norm_pallet

our_pallet:
	mov	dx, offset vga_pallet
	jmp	pallet_common

norm_pallet:
	mov	dx, offset vga_pallet_norm
pallet_common:
	mov	cx, 16
	xor	bx, bx
	mov	ax, 1012H
	int	10H

; exit code
	pop	di
	pop	si
	pop	ds
	pop	es
	mov	sp,bp
	pop	bp
	ret
_vga_pallet endp

;show_logo(95, 72/8, 62, 160, logo_area);
_show_logo proc    far
	push	bp
	mov	bp,sp
	push	es
	push	ds
	push	si
	push	di
; end of initialization
	call	_mouse_off


; setup addresses
	mov	ax, 0A000h
	mov	es, ax
	mov	ax, [bp+16]
	mov	ds, ax
	mov	si, [bp+14]

; calculate beginning offset
	mov	ax, [bp + 6]	    ; beginning row
	mov	bx, 80
	mul	bx
	add	ax, [bp + 8]	    ; beginning BYTE column
	mov	dx, ax

	mov	bx, [bp+12]	    ; height
	mov	ah, 1
	call	select_plane
	mov	di, dx
sl_1:
	mov	cx, [bp+10]	    ; width in bytes
	push	di
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	sl_1

	mov	bx, [bp+12]
	mov	ah, 2
	call	select_plane
	mov	di, dx
sl_2:
	mov	cx, [bp+10]
	push	di
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	sl_2

	mov	bx, [bp+12]
	mov	ah, 4
	call	select_plane
	mov	di, dx
sl_3:
	mov	cx, [bp+10]
	push	di
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	sl_3

	mov	bx, [bp+12]
	mov	ah, 8
	call	select_plane
	mov	di, dx
sl_4:
	mov	cx, [bp+10]
	push	di
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	sl_4

	mov	ah, 0Fh
	call	select_plane

; exit code
	call	_mouse_on
	pop	di
	pop	si
	pop	ds
	pop	es
	mov	sp,bp
	pop	bp
	ret
_show_logo endp

select_plane proc near
	push	dx
	mov	dx, 3C4h
	mov	al, 2		; Map Mask Register
	out	dx, al
	inc	dx
	mov	al, ah
	out	dx, al
	pop	dx
	ret
select_plane endp

extra_char  db	0

_unkbchar proc	  far
	push	bp
	mov	bp,sp
; end of initialization

	mov	ax,[bp+6]
	mov	cs:extra_char, al

; exit code
	mov	sp,bp
	pop	bp
	ret
_unkbchar endp

_kbchar	proc	far
	push	bp
	mov	bp,sp
; end of initialization

	xor	ah,ah
	mov	al,cs:extra_char
	or	al,al
	mov	cs:extra_char, ah
	jnz	kbc_exit

	mov	ah,7
	int	21h
	mov	ah,0

kbc_exit:
	mov	sp,bp
	pop	bp
	ret
_kbchar	endp

_clear	proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
; end of initialization
	call	_mouse_off

; select write mode 2 = same color to all 8 pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; do the clearing
	mov	al, _clear_attrib
	mov	cl, 4
	shr	al, cl
	mov	bx, 0A000H
	mov	es, bx
	xor	di, di
	mov	cx, 80*480		; ega = 28000
	rep stosb

; return mode to expected mode
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; exit code
	call	_mouse_on
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_clear	endp

_position proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization

	mov	bx,[bp+6]	;get row
	dec	bx
	mov	dx,[bp+8]	;get col
	dec	dx
	mov	dh,bl
	mov	bh,0
	mov	ah,2h
	int	10h		;locate cursor position

; exit code
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_position endp

_lclear2end proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization
	call	_mouse_off

	mov	bx,[bp+6]	;get row
	dec	bx
	mov	dx,[bp+8]	;get col
	dec	dx
	push	bx	;save row in stack
	push	dx	;save col in stack
	mov	dh,bl
	mov	bh,0
	mov	ah,2h
	int	10h		;locate cursor position
	mov	ax,160
	pop	bx	;get new column
	sub	ax,bx	; characters in this line
	mov	si,ax	;save in si
	mov	ax,24
	pop	bx
	sub	ax,bx
	mov	bl,160
	imul	bl		;rows left, times 160
	add	ax,si
	mov	cx,ax
	mov	ax,920h
	mov	bl,_clear_attrib	;character's attribute
	mov	bh,0
	int	10h		;write next character & attribute

; exit code
	call	_mouse_on
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_lclear2end endp

_lclearline proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization
	call	_mouse_off

	mov	bx,[bp+6]	;get row
	dec	bx
	mov	dx,[bp+8]	;get col
	dec	dx
	push	dx	;save col in stack
	mov	dh,bl
	mov	bh,0
	mov	ah,2h
	int	10h		;locate cursor position
	mov	ax,160
	pop	bx	;get new column
	sub	ax,bx	; characters in this line
	mov	cx,ax
	mov	ax,920h
	mov	bl,_clear_attrib	;character's attribute
	mov	bh,0
	int	10h		;write next character & attribute

; exit code
	call	_mouse_on
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_lclearline endp

_rev proc	far
	push	bp
	mov	bp,sp
	sub	sp, 6
	push	di
	push	si
	push	es
        push    ds
; end of initialization

	mov	ah, _rev_attrib
	call	disp_string

        pop     ds
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_rev endp

pdisp_string proc near
	push	ax
	call	_mouse_off
	pop	ax
	mov	[bp-2], ax	    ; save attribute

; calculate offset to store output to
	mov	ax, [bp+10]	    ; work with row first
	mov	bx, 80
	mul	bx		    ; row times 80*14
	mov	cx, 3
	mov	bx, [bp+12]	    ; get column
	shr	bx, cl
	add	ax, bx
	mov	bx, [bp+12]	    ; get column
	and	bx, 7		    ; get bit position
	mov	[bp-6], bx
	mov	di, ax
	mov	ax, 0a000h
	mov	es, ax		    ; Address of display memory

; select write mode 2 = same color to all 8 pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; do the displaying
        mov     ax, [bp+8]
        mov     ds, ax
	mov	ax, [bp - 2]	; get attribute of character
	mov	bx,[bp+6]	;get address of string

pdisp_again:
	mov	al,[bx]
	or	al,al		;test for end of string
	jz	pdisp_exit	; exit if it is

	push	bx
	call	pchar_out	; save DS:BX, AH, character in AL

pdispnext:
	pop	bx
	inc	bx
	jmp	short pdisp_again

; exit code
pdisp_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al
	call	_mouse_on
	ret
pdisp_string endp

disp_string proc near
	push	ax
	call	_mouse_off
	pop	ax
	mov	[bp-2], ax	    ; save attribute
; get current cursor position
	xor	ax, ax
	mov	es, ax
	mov	bx, 0450h
	mov	ax, es:[bx]
	mov	[bp-4], ax
; calculate offset to store output to
	mov	cl, 8
	shr	ax, cl		    ; work with row first
	mov	cx, 80*14
	mul	cx		    ; row times 80*14
	mov	cx, [bp-4]	    ;
	xor	ch, ch		    ; get column
	add	ax, cx
	mov	di, ax
	mov	ax, 0a000h
	mov	es, ax		    ; Address of display memory

; select write mode 2 = same color to all 8 pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; do the displaying
        mov     ax, [bp+8]
        mov     ds, ax
	mov	ax, [bp - 2]	; get attribute of character
	mov	bx,[bp+6]	;get address of string

disp_again:
	mov	al,[bx]
	or	al,al		;test for end of string
	jz	disp_exit	; exit if it is

	push	bx
	cmp	al,0ah		;test for newline
	jnz	disp_do 	;if not, display it.

	mov	dx, [bp-4]
	inc	dh		; go to next line
	xor	dl, dl		; 1st column
	mov	[bp-4], dx
	mov	ax, dx
	mov	cl, 8
	shr	ax, cl		    ; work with row first
	mov	cx, 80*14
	mul	cx		    ; row times 80*14
	mov	di, ax
	mov	ax, [bp-2]	    ; get attribute to use
	jmp	short	dispnext

disp_do:
	call	char_out	    ; save DS:BX, AH, character in AL

	mov	dx, [bp-4]
	inc	dl		; go to next column
	mov	[bp-4], dx
dispnext:
	pop	bx
	inc	bx
	jmp	short disp_again

; exit code
disp_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al
	call	_mouse_on
	mov	ah, 2		; set cursor to new location
	mov	bh, 0		; display page zero
	mov	dx, [bp-4]	; cursor coordinates
	int	10H
	ret
disp_string    endp

;
; pchar_out called with character to send in al, attribute in ah
;   & rotate in [bp-6]
pchar_out proc near
	mov	cx, [bp-6]
;	 or	 cx, cx
;	 jz	 char_out

	push	ds
	push	bx
	push	ax
	push	di
	push	ax

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register

	mov	bx, 0FF00h
	shr	bx, cl
	mov	cl, 4
	shr	ah, cl			; bg attrib in AH
	cmp	ah, 6			; transparent color
	je	p_no_bg

	push	di
	push	ax
	mov	al, bh
	out	dx, al			; bit mask register
	mov	al, ah
	mov	cx, 14
pbg_loop_left:
	mov	ah, es:[di]
	mov	es:[di], al
	add	di, 80
	loop	pbg_loop_left		; sets whole cell to bg color

	pop	ax
	pop	di
	mov	al, bl
	or	al, al
	jz	p_no_bg

	out	dx, al			; bit mask register
	mov	al, ah
	mov	cx, 14
pbg_loop_right:
	mov	ah, es:[di+1]
	mov	es:[di+1], al
	add	di, 80
	loop	pbg_loop_right		; sets whole cell to bg color

p_no_bg:
	mov	cx, [bp-6]
	pop	ax			; attrib + character
	pop	di			; cell location
	push	di			; ... still saved

	mov	ch, ah			; attribute to CH
	mov	bl, 14
	mul	bl
	lds	si, font_loc
	add	si, ax			; points DS:SI to char desc
	mov	byte ptr [bp-8], 14
pfg_loop:
	xor	bx, bx
	lodsb		    ; the mask for this character
	mov	bh, al
	shr	bx, cl
	mov	al, bh
	out	dx, al
	mov	al, es:[di]
	mov	es:[di], ch
	or	cl, cl
	jz	p_on_boundary

	mov	al, bl
	out	dx, al
	mov	al, es:[di+1]
	mov	es:[di+1], ch
p_on_boundary:
	add	di, 80
	dec	byte ptr [bp-8]
	jnz	pfg_loop

pcout_end:
	mov	al,  0ffH
	out	dx, al	    ; select all bits

	pop	di
	inc	di
	pop	ax
	pop	bx
	pop	ds
	ret
pchar_out endp

;
; char_out called with character to send in al, attribute in ah
;
char_out proc near
	push	ds
	push	bx
	push	ax
	push	di

	push	ax
	mov	cl, 4
	shr	ah, cl			; bg attrib in AH

	mov	al, ah
	mov	cx, 14
bg_loop:
	mov	ah, es:[di]
	mov	es:[di], al
	add	di, 80
	loop	bg_loop 		; sets whole cell to bg color

	pop	ax			; attrib + character
	pop	di			; cell location
	push	di			; ... still saved
	mov	bh, ah			; attribute to BH
	mov	bl, 14
	mul	bl
	lds	si, font_loc
	add	si, ax			; points DS:SI to char desc
; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	cx, 14	    ; 14 rows high
fg_loop:
	lodsb		    ; the mask for this character
	out	dx, al
	mov	al, es:[di]
	mov	es:[di], bh
	add	di, 80
	loop	fg_loop

	mov	al,  0ffH
	out	dx, al	    ; select all bits

	pop	di
	inc	di
	pop	ax
	pop	bx
	pop	ds
	ret
char_out endp


_ptext proc	  far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push	si
	push	es
        push    ds
; end of initialization

	mov	ax, [bp+14]
	mov	ah, al
	call	pdisp_string

        pop     ds
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_ptext endp


_text proc	 far
	push	bp
	mov	bp,sp
	sub	sp, 6
	push	di
	push	si
	push	es
        push    ds
; end of initialization

	mov	ax, [bp+10]
	mov	ah, al
	call	disp_string

        pop     ds
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_text endp

_norm proc	far
	push	bp
	mov	bp,sp
	sub	sp, 6
	push	di
	push	si
	push	es
        push    ds
; end of initialization

	mov	ah, _norm_attrib
	call	disp_string

; exit code
        pop     ds
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_norm endp



_bold proc	far
	push	bp
	mov	bp,sp
	sub	sp, 6
	push	di
	push	si
	push	es
        push    ds
; end of initialization

	mov	ah, _bold_attrib
	call	disp_string

; exit code
        pop     ds
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_bold endp

_printer1 proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization

	mov	ax,[bp + 6]	;get character to send into al
	xor	ah,ah
	mov	dx,0		;select printer to send to 1 == LPT2:
	int	17h

; exit code
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_printer1 endp

_printerstat proc  far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization

	mov	dx,[bp + 6]	;get printer to check
	mov	ah,2		; request status
	int	17h
	mov	al, ah
	xor	ah, ah

; exit code
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_printerstat endp

_kb_stat proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization
	mov	ah, 1	;get status
	int	16h
	mov	ax, 0
	jz	kbs_exit ; no keystroke
	mov	ax, 1	; .... character waiting
; exit code
kbs_exit:
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_kb_stat endp

_get_cursor proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization

	mov	bh,0
	mov	ah,3h
	int	10h		;locate cursor position
	mov	ax,dx

; exit code
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_get_cursor endp

_set_cursor proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
; end of initialization

	mov	dx,[bp+6]	;get position to set
	mov	bh,0
	mov	ah,2h
	int	10h		;locate cursor position

; exit code
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_set_cursor endp

; sample call:
;	scroll_window_up(top_row, left_col, bottom_row, right_col);
;
;	trow	[bp + 6]
;	lcol	[bp + 8]
;	brow	[bp + 10]
;	rcol	[bp + 12]
;
_scroll_window_up proc far
	push	bp
	mov	bp,sp
	push	di
        push    si
        push    ds
	push	es
; end of initialization
	call	_mouse_off

; put EGA in write mode 1 == 32 bit internal transfer
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	mov	al,1		    ; Write mode 1
	out	dx,al

	mov	ax, 0A000h
	mov	ds, ax
	mov	es, ax

	mov	ax, [bp + 6]	    ; top_row
	dec	ax
	mov	bx, 80*14
	mul	bx
	add	ax, [bp + 8]	    ; left col
	dec	ax		    ; make offset 0
	mov	di, ax		    ; destination
	add	ax, 80*14
	mov	si, ax		    ; source
	mov	ax, [bp + 10]
	sub	ax, [bp + 6]	    ; lines to move up
	jbe	swu_exit	    ; invalid scroll

	mov	dl, 14
	mul	dl
	mov	dx, ax		    ; pixel lines to scroll
	mov	ax, [bp + 12]	    ; right side
	sub	ax, [bp + 8]	    ; left side -> Leaves width in ax
	inc	ax
	mov	bx, 80
swu_loop:
	mov	cx, ax
	push	di
	push	si
	rep movsb		    ; character cell
	pop	si
	add	si, bx
	pop	di
	add	di, bx
	dec	dx
	jnz	swu_loop

; exit code
swu_exit:
; put EGA in write mode 0 == Standard mode
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	xor	al, al		    ; mode 0
	out	dx,al

	call	_mouse_on
	pop	es
        pop     ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_scroll_window_up endp

; sample call:
;	scroll_window_down(top_row, left_col, bottom_row, right_col);
;
;	trow	[bp + 6]
;	lcol	[bp + 8]
;	brow	[bp + 10]
;	rcol	[bp + 12]
;
_scroll_window_down proc far
	push	bp
	mov	bp,sp
	push	di
        push    si
        push    ds
	push	es
; end of initialization
	call	_mouse_off

; put EGA in write mode 1 == 32 bit internal transfer
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	mov	al,1		    ; Write mode 1
	out	dx,al

	mov	ax, 0A000h
	mov	ds, ax
	mov	es, ax

	mov	ax, [bp + 6]	    ; top_row
	dec	ax
	mov	bx, 80*14
	mul	bx
	add	ax, [bp + 8]	    ; left col
	dec	ax		    ; make offset 0
	mov	si, ax		    ; source - almost
	add	ax, 14*80
	mov	di, ax		    ; destination - almost
	mov	ax, [bp + 10]
	sub	ax, [bp + 6]	    ; lines to move up
	jbe	swd_exit	    ; invalid scroll

	push	ax
	mov	dl, 14
	mul	dl
	mov	dx, ax		    ; pixel lines to scroll
	pop	ax		    ; character lines to scroll

	push	dx
	mul	bx		    ; still contains 80*14
	pop	dx
	sub	ax, 80
	add	si, ax
	add	di, ax
swd_ok:
	mov	ax, [bp + 12]	    ; right side
	sub	ax, [bp + 8]	    ; left side
	inc	ax
	jbe	swd_exit
	mov	bx, 80
swd_loop:
	mov	cx, ax
	push	di
	push	si
	rep movsb		    ;
	pop	si
	sub	si, bx		    ;
	pop	di
	sub	di, bx		    ;
	dec	dx
	jnz	swd_loop

; exit code
swd_exit:
; put EGA in write mode 0 == Standard mode
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	xor	al, al		    ; mode 0
	out	dx,al

	call	_mouse_on
	pop	es
        pop     ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_scroll_window_down endp

; sample call:
;	saved_window = get_window(dline + 1, 29, 33, 1);
;
;	row	[bp + 6]
;	col	[bp + 8]
;	hlen	[bp + 10]
;	vlen	[bp + 12]
;	save area [bp + 14]
;

gw_row	equ [bp+6]
gw_col	equ [bp+8]
gw_hlen equ [bp+10]
gw_vlen equ [bp+12]

local1	 equ	[bp-2]
local2	 equ	[bp-4]
local3	 equ	[bp-6]
local4	 equ	[bp-8]
local5	 equ	[bp-10]
local6	 equ	[bp-12]
local7	 equ	[bp-14]
local8	 equ	[bp-16]
local9	 equ	[bp-18]
local10  equ	[bp-20]
local11  equ	[bp-22]
local12  equ	[bp-24]

_get_window proc	far
	push	bp
	mov	bp,sp
	sub	sp,10
	push	di
        push    si
        push    ds
	push	es
; end of initialization
	call	_mouse_off

; calculate size of save area & allocate memory for it.
	mov	bx,gw_vlen
	mov	ax,14		; 14 rows / cell
	mul	bx
	mov	bx, gw_hlen
	shl	bx, 1
	shl	bx, 1		; times 4 (for 4 planes)
	mul	bx
	or	dx, dx
	jnz	gw_errorx

	add	ax, 6
	jc	gw_errorx

	push	ax
	call	_malloc
	add	sp, 2

	mov	bx, ax
	or	bx, dx
	jnz	gw_ok

gw_errorx:
	jmp	gw_error

gw_ok:
;	 mov	 di, [bp+14]	 ;get address of string
;	 mov	 ax, [bp+16]
;	 mov	 es, ax
	mov	di, ax
	mov	local4, ax
	mov	es, dx
	mov	local5, dx

	dec	word ptr gw_row   ;go from row # in english to biosese
	dec	word ptr gw_col   ;go from col # in english to biosese
	mov	ax, gw_row
	mov	bx, 80*14
	mul	bx
	mov	bx, gw_col
	add	ax, bx
	mov	si, ax
	stosw			; save offset in savearea
	mov	local1, ax
	mov	ax, 0a000h
	mov	ds, ax
	mov	ax, gw_vlen	; save vertical len in savearea
	mov	bx, 14
	mul	bx
	mov	local2, ax
	stosw
	mov	ax, gw_hlen	; save horizontal len in savearea
	stosw

; select plane 0
	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx
	xor	al, al
	out	dx, al
	mov	ax, local2
	mov	local3, ax
gwagain0:
	mov	cx, gw_hlen
	push	si
	rep movsb
	pop	si
	add	si, 80		; next line
	dec	word ptr local3
	jnz	gwagain0

; select plane 1
	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx
	mov	al, 1
	out	dx, al
	mov	ax, local2
	mov	local3, ax
	mov	si, local1
gwagain1:
	mov	cx, gw_hlen
	push	si
	rep movsb
	pop	si
	add	si, 80		; next line
	dec	word ptr local3
	jnz	gwagain1

; select plane 2
	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx
	mov	al, 2
	out	dx, al
	mov	ax, local2
	mov	local3, ax
	mov	si, local1
gwagain2:
	mov	cx, gw_hlen
	push	si
	rep movsb
	pop	si
	add	si, 80		; next line
	dec	word ptr local3
	jnz	gwagain2

; select plane 3
	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx
	mov	al, 3
	out	dx, al
	mov	ax, local2
	mov	local3, ax
	mov	si, local1
gwagain3:
	mov	cx, gw_hlen
	push	si
	rep movsb
	pop	si
	add	si, 80		; next line
	dec	word ptr local3
	jnz	gwagain3

	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx
	mov	al, 0
	out	dx, al
	call	_mouse_on
	mov	dx, local5
	mov	ax, local4
	jmp	short gw_exit

gw_error:
	call	_mouse_on
	xor	ax, ax
	mov	dx, ax

; exit code
gw_exit:
	pop	es
        pop     ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_get_window endp

; sample call:
;	put_window(saved_window);
;
;	word 0	    = screen address
;	word 1	    = height
;	word 2	    = width
;	bytes 6+   = saved screen info
;
_put_window proc	far
	push	bp
	mov	bp,sp
	sub	sp, 10
	push	di
        push    si
        push    ds
	push	es
; end of initialization
	call	_mouse_off

	mov	si, [bp+6]	;get address of string
        mov     ax, [bp+8]      ; get segment of string
	mov	ds, ax
	or	ax, si
	jnz	pw_ok
	jmp	pw_exit 	; null pointer

pw_ok:
	mov	ax, 0a000h
	mov	es, ax
	lodsw			; get screen offset
	mov	di, ax
	mov	local1, ax
	lodsw			; get vertical height
	mov	bx, ax
	mov	local2, ax
	lodsw			; get width
	mov	dx, ax

; select plane 0
	mov	ah, 1
	call	select_plane
	mov	bx, local2
pwagain0:
	push	di
	mov	cx, dx		; width
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	pwagain0

; select plane 1
	mov	ah, 2
	call	select_plane
	mov	di, local1
	mov	bx, local2
pwagain1:
	push	di
	mov	cx, dx		; width
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	pwagain1

; select plane 2
	mov	ah, 4
	call	select_plane
	mov	di, local1
	mov	bx, local2
pwagain2:
	push	di
	mov	cx, dx		; width
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	pwagain2

; select plane 3
	mov	ah, 8
	call	select_plane
	mov	di, local1
	mov	bx, local2
pwagain3:
	push	di
	mov	cx, dx		; width
	rep movsb
	pop	di
	add	di, 80
	dec	bx
	jnz	pwagain3

	mov	ah, 0fh
	call	select_plane
	mov	ax, [bp+8]	; get segment of string
	push	ax
	mov	ax, [bp+6]	;get address of string
	push	ax
	call	_free
	add	sp,4

; exit code
pw_exit:
	call	_mouse_on
	pop	es
        pop     ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_put_window endp

_get_screen proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
; end of initialization
	call	_mouse_off
	mov	dx, 3CEh
	mov	al, 4		; Read Map Select register
	out	dx, al
	inc	dx

	mov	di, [bp+6]	;get address of string
	mov	ax, [bp+8]	; get segment of string
; we don't want to cross a segment boundary...
	mov	bx, di
	mov	cl,4
	shr	bx, cl
	add	ax, bx
	mov	es, ax
	mov	bx, di
	and	bx, 0fh


; let's get on with it...
	mov	ax, 0A000h
	mov	ds, ax
	xor	ax, ax		; start with plane zero
gs_loop:
	mov	al, ah		; select plane to read
	out	dx, al
	inc	ah		; next plane, next time.
	xor	si, si
	mov	di, bx
	mov	cx, 28000
	rep movsb
	mov	cx, 6d6H	; bump segment pointer to next location
	mov	di, es
	add	di, cx
	mov	es, di
	cmp	ah, 4		; did we just do the last plane?
	jne	gs_loop 	; if not, continue

	xor	al, al
	out	dx, al		; go back to plane zero
; exit code
	call	_mouse_on
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_get_screen endp

_put_screen proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
; end of initialization
	call	_mouse_off
	mov	dx, 3C4h
	mov	al, 2		; Map Mask Register
	out	dx, al
	inc	dx

        mov     si, [bp+6]      ;get address of string
	mov	ax, [bp+8]	; get segment of string
; we don't want to cross a segment boundary...
	mov	bx, si
	mov	cl,4
	shr	bx, cl
	add	ax, bx
	mov	ds, ax
	mov	bx, si
	and	bx, 0fh

; let's get on with it...
	mov	ax, 0A000h
	mov	es, ax
	mov	ah, 1		; start with plane 1
ps_loop:
	mov	al, ah		; select plane to read
	out	dx, al
	shl	ah, 1		; next plane next time
	xor	di, di
	mov	si, bx
	mov	cx, 28000
	rep movsb
	mov	cx, 6d6H	; bump segment pointer to next location
	mov	si, ds
	add	si, cx
	mov	ds, si
	cmp	ah, 10H 	; did we just do the last plane?
	jne	ps_loop 	; if not, continue

	mov	al, 0fH 	; select all planes
	out	dx, al

	call	_mouse_on
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_put_screen endp


_attrib  proc	 far
	push	bp
	mov	bp,sp
	sub	sp, 4
	push	di
	push	si
	push	es
; end of initialization
	call	_mouse_off

; put ega in: write mode 2 (all planes simultaneously)
;	      and XOR display memory with latches (rotate count = 0)
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	mov	al,2		    ; Write mode 2
	out	dx,al
	mov	dx,3ceh
	mov	al,3		    ; Data Rotate register
	out	dx,al
	inc	dx
	mov	al,18h		    ; xor data with latches, don't rotate
	out	dx,al
; calculate offset to store output to
IF 0
	mov	ax, [bp+6]	    ; get row
	dec	ax
	mov	cx, 80*14
	mul	cx		    ; row times 160
	mov	cx, [bp+8]	    ; get col
	dec	cx
	add	ax, cx
	mov	di, ax
ELSE
	mov	ax, [bp+6]	    ; get col+ row*256
	xor	cx, cx
	mov	cl, al
	mov	di, cx
	mov	cl, 8
	shr	ax, cl
	mov	cx, 80*14
	mul	cx		    ; row times 160
	add	di, ax
ENDIF
	mov	ax, 0a000h
	mov	es, ax		    ; address of display memory
	mov	ax, [bp+10]	    ; get attribute
	mov	cx, 14
	mov	bl, 0ffh
att_row:
	push	cx
	push	di
	mov	cx, [bp+12]	    ; get count
	mov	cx, 1
att_loop:
	mov	al, es:[di]	    ; latch data
;	 not	 al
	mov	es:[di], bl
IF 0
	inc	di
	loop	att_loop
ENDIF

	pop	di
	add	di, 80
	pop	cx
	loop	att_row

; exit code
; put ega in: write mode 0 (normal mode)
;	      and XOR display memory with latches (rotate count = 0)
	mov	dx,3ceh
	mov	al,5
	out	dx,al
	inc	dx
	mov	al,0		    ; Write mode 0
	out	dx,al
	mov	dx,3ceh
	mov	al,3		    ; Data Rotate register
	out	dx,al
	inc	dx
	mov	al,00h		    ; standard mode - data is written unmodified
	out	dx,al
	call	_mouse_on
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_attrib endp

_send_com proc	far
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	es
; end of initialization

	xor	ax, ax
	mov	es, ax
	mov	bx, 400h
	mov	ax, [bp+6]	; get port to work with
	shl	ax, 1
	add	bx, ax
	mov	dx, es:[bx]
	mov	ax, [bp+8]	; get character to send, status already checked
	out	dx, al

; exit code
	pop	es
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_send_com endp

_com_input proc far
	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds

	xor	ax, ax
	mov	es, ax
	mov	ax, [bp+6]
	shl	ax, 1
	mov	bx, 400h
	add	bx, ax
	mov	dx,es:[bx]
	add	dx,5	;line status port
ci_wait:
	in	al,dx	; read line status
	and	al,1	;something there?
	jz	ci_wait

	sub	dx, 5
	in	al,dx
;	 mov	 ah,0
; return status in AH
	mov	ah, al
	add	dx, 5
	in	al, dx
	xchg	ah, al

	cld
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_com_input endp


pl_prt	    equ     [bp+6]
pl_off	    equ     [bp+8]
pl_seg	    equ     [bp+10]
pl_x1	    equ     [bp+12]
pl_y1	    equ     [bp+14]
pl_x2	    equ     [bp+16]
pl_y2	    equ     [bp+18]
pl_interval equ     [bp+20]

_pline proc far
	push	bp
	mov	bp,sp
	sub	sp, 24
	push	di
	push 	si
	push	ds
	push	es

	mov	ax, pl_interval
	mov	local11, ax
	mov	ax, pl_off
	mov	cl, 4
	shr	ax, cl
	add	ax, pl_seg
	mov	es, ax
	mov	ax, pl_off
	and	ax, 0fh
	mov	local8, ax
	mov	ax, pl_prt
	or	ax, ax
	jnz	pline0
	jmp	lq_line

pline0:
	dec	ax
	jz	fx
	dec	ax
	jmp	hpii

fx:
	jmp	fx_line
hpii:
	jmp	hpii_line

fx_line:
;  calculate line drawing stuff
; initial increments
	mov	cx,1	    ; x axis
	mov	dx,cx	    ; y axis
; vertical distance
	mov	di, pl_y2   ; y2
	cmp	di, 22*8
	jc	fx_sane0

	mov	di, (22*8)-1
fx_sane0:
	mov	ax, pl_y1
	cmp	ax, 22*8
	jc	fx_sane1

	mov	word ptr pl_y1, (22*8)-1
fx_sane1:
	jmp	lq_sane1

lq_line:
;  calculate line drawing stuff
; initial increments
	mov	cx,1	    ; x axis
	mov	dx,cx	    ; y axis
; vertical distance
	mov	di, pl_y2   ; y2
	cmp	di, 22*24
	jc	lq_sane0

	mov	di, 22*24-1
lq_sane0:
	mov	ax, pl_y1
	cmp	ax, 22*24
	jc	lq_sane1

	mov	word ptr pl_y1, 22*24-1
lq_sane1:
	sub	di, pl_y1   ; y1
	jge	plvplus

	neg	dx	    ; y increment is -1
	neg	di	    ; make y change positive
plvplus:
	mov	local1,dx
; horizontal distance
	mov	si, pl_x2   ; x2
	sub	si, pl_x1   ; x1
	jge	plhplus

	neg	cx
	neg	si
plhplus:
	mov	local2, cx
; more or less than 45 degrees
	cmp	si, di
	jge	plhoriz

	xor	cx, cx
	xchg	si, di
	jmp	plready

plhoriz:
	xor	dx, dx
plready:
	mov	local3, di	; shortest distance
	mov	local4, cx
	mov	local5, dx
;
	mov	ax, local3
	shl	ax, 1
	mov	local6, ax
	sub	ax, si
	mov	di, ax
	sub	ax, si
	mov	local7, ax
	mov	dx, pl_y1	; y1
	mov	local9, dx
	mov	cx, pl_x1	; x1
	mov	local10, cx
	inc	si
	inc	si
pl_loop:
	dec	si
	jz	pl_exit
	call	near ptr lq_pldodot
	cmp	di, 0
	jge	pl_diag

; straight segment
	mov	cx, local10
	add	cx, local4
	mov	dx, local9
	add	dx, local5
	mov	local9, dx
	mov	local10, cx
	add	di, local6
	jmp	pl_loop

pl_diag:
	mov	cx, local10
	add	cx, local2
	mov	dx, local9
	add	dx, local1
	mov	local9, dx
	mov	local10, cx
	add	di, local7
	jmp	pl_loop

pl_exit:
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret

hpii_line:
;  calculate line drawing stuff
; initial increments
	mov	cx,1	    ; x axis
	mov	dx,cx	    ; y axis
; vertical distance
	mov	di, pl_y2   ; y2
	cmp	di, 335
	jc	hp_sane0

	mov	di, 334
hp_sane0:
	mov	ax, pl_y1
	cmp	ax, 335
	jc	hp_sane1

	mov	word ptr pl_y1, 334
hp_sane1:
	sub	di, pl_y1   ; y1
	jge	hpplvplus

	neg	dx	    ; y increment is -1
	neg	di	    ; make y change positive
hpplvplus:
	mov	local1,dx
; horizontal distance
	mov	si, pl_x2   ; x2
	sub	si, pl_x1   ; x1
	jge	hpplhplus

	neg	cx
	neg	si
hpplhplus:
	mov	local2, cx
; more or less than 45 degrees
	cmp	si, di
	jge	hpplhoriz

	xor	cx, cx
	xchg	si, di
	jmp	hpplready

hpplhoriz:
	xor	dx, dx
hpplready:
	mov	local3, di	; shortest distance
	mov	local4, cx
	mov	local5, dx
;
	mov	ax, local3
	shl	ax, 1
	mov	local6, ax
	sub	ax, si
	mov	di, ax
	sub	ax, si
	mov	local7, ax
	mov	dx, pl_y1	; y1
	mov	local9, dx
	mov	cx, pl_x1	; x1
	mov	local10, cx
	inc	si
	inc	si
hppl_loop:
	dec	si
	jz	pl_exit
	call	near ptr hp_pldodot
	cmp	di, 0
	jge	hppl_diag

; straight segment
	mov	cx, local10
	add	cx, local4
	mov	dx, local9
	add	dx, local5
	mov	local9, dx
	mov	local10, cx
	add	di, local6
	jmp	hppl_loop

hppl_diag:
	mov	cx, local10
	add	cx, local2
	mov	dx, local9
	add	dx, local1
	mov	local9, dx
	mov	local10, cx
	add	di, local7
	jmp	hppl_loop

_pline endp

lq_pldodot   proc near
	dec	word ptr local11	;"color" or interval
	jz	lq_pldodot_cont 	; only plot when zero

	ret
lq_pldodot_cont:
	mov	ax, pl_interval
	mov	local11, ax
	push	di
	push	si
	push	dx
	push	cx

	mov	si, sp
	mov	cx, ss:local9	    ; row
	mov	al, 80h
	and	cl, 7
	shr	al, cl
	mov	ch, al		    ; bit within byte
	mov	ax, ss:local9	    ; row
	mov	cl, 3
	shr	ax, cl		    ; row / 8
	mov	bx, 720
	mul	bx
	mov	di, ax
	add	di, local8
	add	di, ss:local10	    ; column
	or	es:[di], ch

	pop	cx
	pop	dx
	pop	si
	pop	di
	ret
lq_pldodot   endp

hp_pldodot   proc near
	dec	word ptr local11	;"color" or interval
	jz	hp_pldodot_cont 	; only plot when zero

	ret
hp_pldodot_cont:
	mov	ax, pl_interval
	mov	local11, ax
	push	di
	push	si
	push	dx
	push	cx

	mov	si, sp
	mov	ax, local9	 ; row
	mov	bx, 85
	mul	bx
	mov	di, ax
	add	di, local8
	mov	ax, local10	; column
	mov	cl, 3
	shr	ax, cl
	add	di, ax
	mov	cx, local10	; column
	and	cl, 7
	mov	al, 80h
	shr	al, cl
	or	es:[di], al

	pop	cx
	pop	dx
	pop	si
	pop	di
	ret
hp_pldodot   endp

_line proc far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, 0A000H
	mov	es, ax

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
;	 mov	 al, ah
;	 out	 dx, al

;  calculate line drawing stuff
; initial increments
	mov	cx,1	    ; x axis
	mov	dx,cx	    ; y axis
; vertical distance
IF 1
	mov	ax, [bp+8]  ; y1
	cmp	ax, 480
	jc	line_sane0

	mov	[bp+8], 479 ; y1
line_sane0:
ENDIF
	mov	di, [bp+12] ; y2
IF 1
	cmp	di, 480
	jc	line_sane1

	mov	di, 479
line_sane1:
ENDIF
	sub	di, [bp+8]  ; y1
	jge	lvplus

	neg	dx	    ; y increment is -1
	neg	di	    ; make y change positive
lvplus:
	mov	local1,dx
; horizontal distance
	mov	si, [bp+10] ; x2
	sub	si, [bp+6]  ; x1
	jge	lhplus

	neg	cx
	neg	si
lhplus:
	mov	local2, cx
; more or less than 45 degrees
	cmp	si, di
	jge	lhoriz

	xor	cx, cx
	xchg	si, di
	jmp	lready

lhoriz:
	xor	dx, dx
lready:
	mov	local3, di	; shortest distance
	mov	local4, cx
	mov	local5, dx
;
	mov	ax, local3
	shl	ax, 1
	mov	local6, ax
	sub	ax, si
	mov	di, ax
	sub	ax, si
	mov	local7, ax
	mov	dx, [bp+8]	; y1
	push	dx
	mov	cx, [bp+6]	; x1
	push	cx
	inc	si
	inc	si
l_loop:
	dec	si
	jz	l_exit
	call	near ptr dodot
	cmp	di, 0
	jge	l_diag

; straight segment
	pop	cx
	add	cx, local4
	pop	dx
	add	dx, local5
	push	dx
	push	cx
	add	di, local6
	jmp	l_loop

l_diag:
	pop	cx
	add	cx, local2
	pop	dx
	add	dx, local1
	push	dx
	push	cx
	add	di, local7
	jmp	l_loop

l_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	ax
	pop	ax
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_line endp

dodot	proc near
	push	di
	push	si
	push	dx

	mov	si, sp
	mov	ax, ss:[si+10]
	mov	bx, 80
	mul	bx
	mov	di, ax
	mov	ax, ss:[si+8]
	mov	bx, ax
	mov	cl,3
	shr	ax, cl
	add	di, ax
	and	bx, 7
	mov	cl, bl
	mov	al,80H
	shr	al, cl
	mov	dx, 3CFH
	out	dx, al
	mov	al,es:[di]
	mov	ax, [bp+14]
	mov	es:[di], al

	pop	dx
	pop	si
	pop	di
	ret
dodot	endp

_vline proc far
	push	bp
	mov	bp,sp
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, 0A000H
	mov	es, ax

	mov	ax, [bp+10]	; ending row
	mov	bx, [bp+8]	; starting row
	sub	ax, bx
	inc	ax
	push	ax		; rows to do
	mov	ax,80		; bytes / row
	mul	bx
	mov	dx, [bp+6]	; column to do
	mov	bx, dx
	mov	cl, 3
	shr	bx, cl		; gives byte offset
	add	ax, bx
	mov	di, ax		; actual offset
	and	dx, 7		; bit offset
	mov	cx, dx
	mov	ah,80h
	shr	ah, cl		; bit to set

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, ah
	out	dx, al

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

	pop	cx
	mov	ax, [bp+12] ; color to use
vl_loop:
	mov	ah, es:[di]
	mov	es:[di], al
	add	di, 80
	loop	vl_loop


vl_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_vline endp

_hline proc far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, [bp+6]	; row it's on
	mov	bx,80
	mul	bx		; gives offset (less column)
	mov	di, ax

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register

	mov	ax, 0A000H
	mov	es, ax

	mov	ax, [bp+10]	; ending col
	mov	bx, [bp+8]	; starting col
	mov	cl, 3
	shr	ax, cl
	shr	bx, cl
	add	di, bx		; offset of first byte
	sub	ax, bx		; total bytes to do
	mov	[bp-2], ax	; save bytes to do

	xor	bx, bx
	dec	bx		; all 1's
	mov	cx, [bp+8]	; starting column
	and	cl, 7		; starting bit
	shr	bh, cl		; first byte mask
	mov	cx, [bp+10]	; ending column
	inc	cx
	and	cl, 7		; ending bit
	mov	ch, 8
	sub	ch, cl
	mov	cl, ch
	and	cl, 7
	shl	bl, cl		; last byte mask
	mov	cx, [bp-2]	; bytes to do (less one)
	or	cx, cx
	jnz	hl_more

	and	bh, bl
hl_more:
	mov	al, bh		; first byte mask
	out	dx,al
	mov	ax, [bp+12]	; get color
	mov	ah, es:[di]
	mov	es:[di], al
	or	cx, cx
	jz	hl_exit 	; we're done
	inc	di
	dec	cx
	jz	hl_end

	mov	al, 0FFh
	out	dx, al		; all bits in the middle
	mov	ax, [bp+12]	; get color
hl_loop:
	mov	ah, es:[di]
	mov	es:[di], al
	inc	di
	loop	hl_loop

hl_end:
	mov	al, bl		; last byte mask
	out	dx, al
	mov	ax, [bp+12]	; get color
	mov	ah, es:[di]
	mov	es:[di], al


hl_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_hline endp


_area_clear proc far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, [bp+6]	; row it's on
	mov	bx,80
	mul	bx		; gives offset (less column)
	mov	di, ax

	mov	ax, [bp+8]
	sub	ax, [bp+6]
	inc	ax
	mov	local1, ax	; vertical lines to do

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register

	mov	ax, 0A000H
	mov	es, ax

	mov	ax, [bp+12]	; ending col
	mov	bx, [bp+10]	 ; starting col
	mov	cl, 3
	shr	ax, cl
	shr	bx, cl
	add	di, bx		; offset of first byte
	mov	local3, di
	sub	ax, bx		; total bytes to do
	mov	local2, ax	; save bytes wide to do

	xor	bx, bx
	dec	bx		; all 1's
	mov	cx, [bp+10]	 ; starting column
	and	cl, 7		; starting bit
	shr	bh, cl		; first byte mask
	mov	cx, [bp+12]	; ending column
	inc	cx
	and	cl, 7		; ending bit
	mov	ch, 8
	sub	ch, cl
	mov	cl, ch
	and	cl, 7
	shl	bl, cl		; last byte mask
	mov	local4, bx
	mov	cx, local2	; bytes to do (less one)
	or	cx, cx
	jnz	ac_more

; it's one byte wide -- combine left & right
	and	bh, bl
	mov	al, bh		; combined left & right bit mask
	out	dx, al
	jmp	ac_end		; go do combined left & right

ac_more:
	mov	al, bh		; first byte mask
	out	dx,al
	mov	ax, [bp+14]	; get color
	push	cx
	push	di
	mov	cx, local1
ac_more1:			; do left byte
	mov	ah, es:[di]
	mov	es:[di], al
	add	di, 80
	loop	ac_more1

	pop	di
	pop	cx

	inc	di		; past byte column just done
	mov	local3, di	; new left pointer
	dec	cx
	mov	local2, cx
	jz	ac_right	; no "middle bytes" -- go do right side

	mov	al, 0FFh
	out	dx, al		; all bits in the middle
	mov	bx, local1
	mov	ax, [bp+14]	; get color
	mov	local3, di
ac_loop2:
	push	di
ac_loop:
	mov	ah, es:[di]
	mov	es:[di], al
	inc	di
	loop	ac_loop

	pop	di
	add	di, 80
	mov	cx, local2
	dec	bx
	jnz	ac_loop2

ac_right:
	mov	ax, local4	; last byte mask
	out	dx, al
ac_end:
	mov	di, local3
	add	di, local2
	mov	cx, local1
	mov	ax, [bp+14]	; get color
ac_end1:
	mov	ah, es:[di]
	mov	es:[di], al
	add	di, 80
	loop	ac_end1

ac_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_area_clear endp


_up_arrow proc far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, 0A000H
	mov	es, ax

	mov	ax, [bp+6]
	dec	ax
	mov	bx,14
	mul	bx
	add	ax, 11
	mov	bx, 80
	mul	bx
	mov	di, ax
	add	di, [bp+8]
	xor	bx, bx

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 08h
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 1Ch
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 3Eh
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 07Fh
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 1Ch
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl
	mov	ah, es:[di+80]
	mov	es:[di+80],bl
	mov	ah, es:[di+160]
	mov	es:[di+160],bl

uar_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_up_arrow endp


_down_arrow proc far
	push	bp
	mov	bp,sp
	sub	sp, 16
	push	di
	push 	si
	push	ds
	push	es
	call	_mouse_off

	mov	ax, 0A000H
	mov	es, ax

	mov	ax, [bp+6]
	dec	ax
	mov	bx,14
	mul	bx
	add	ax, 11
	mov	bx, 80
	mul	bx
	mov	di, ax
	add	di, [bp+8]
	xor	bx, bx

; select write mode 2 = same color to all unmasked pixels of this byte
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 2	    ; write mode 2, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register

	mov	al, 1Ch
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl
	mov	ah, es:[di+80]
	mov	es:[di+80],bl
	mov	ah, es:[di+160]
	mov	es:[di+160],bl

	add	di, 240
	mov	al, 07Fh
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 3Eh
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 1Ch
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

	add	di, 80
	mov	al, 08h
	out	dx, al
	mov	ah, es:[di]
	mov	es:[di], bl

dar_exit:
; restore original write mode
	mov	dx, 3ceH
	mov	al, 5
	out	dx, al	    ; index = 5:  Mode register
	inc	dx
	mov	al, 0	    ; write mode 0, read mode 0
	out	dx, al

; index the bit mask register
	mov	dx, 3ceH
	mov	al, 8
	out	dx, al	    ; index = 8:  Bit Mask register
	inc	dx	    ; ready DX for writes to bit mask register
	mov	al, 0FFh
	out	dx, al	    ; all bits

	call	_mouse_on
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret
_down_arrow endp

CON_TEXT ends

	END
