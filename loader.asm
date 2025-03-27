	BITS 16
	
	mov cx, 8
	mov si, key+0x7c00

keyboard:
	xor ax, ax
	int 0x16
	mov [si], al
	inc si, 
	mov ah, 0x0e
	int 0x10
	loop keyboard

init:	
	xor ax, ax
	mov ax, 0x7e0
	mov bx, 0
	mov es, ax

	mov ah, 2
	mov al, 1
	mov cl, 2
	xor ch, ch
	mov dh, 0
	int 0x13



	xor ax, ax
	mov si, 0x6000
	mov di, 0x6101
	mov bx, key + 0x7c00
	xor cl, cl
	
S:
	mov byte [si], al; S[i]
	mov dl, byte [bx]; key[i]
	mov byte [di], dl; key[i]
	inc si
	inc di
	inc bx
	inc cl
	inc ax
	cmp cl, 8
	jne next
	mov bx, key + 0x7c00
	xor cl, cl
next:
	cmp ax, 256
	je coun;decrypt;KSA
	jmp S  

coun:
	xor ax, ax 
	xor cx, cx ; j = 0
	xor bx, bx ; counter
	xor dx, dx 
KSA:
	mov si, 0x6000 ; S[0]
	mov di, 0x6101 ; T[0]

	mov al, [si + bx] ; S[i]
	mov dl, [di + bx] ; T[i]
	
	add cl, dl; j + S[i]
	add cl, al; j + S[i] + T[i]

	; al = S[i] bl = i
	mov dx, bx;tmp for count
	mov bx, cx; bx = j 
	xchg al, [si + bx]; swap a(S[i])  S[j]
	mov bx, dx; counter
	mov [si + bx], al; S[i] = ax

	inc bx
	cmp bx, 256
	je cane
	jmp KSA


PRGA:
	xor bx, bx
	inc ah; i+1 mod n
	mov bl, ah; bh = i
	add al, byte [di + bx]; j = (j + S[i]) mod n
	mov dl, byte [di + bx]; dl = S[i]
	mov dh, bl; dh tmp for bl(=i)
	mov bl, al; bx = j
	xchg dl, byte [di + bx]; swap dl S[j](dl = S[j])

	mov bl, dh; bl = i	
	mov byte [di + bx], dl; end swap(S[i] = S[j])
	
	mov bl, al
	add dl, byte [di + bx]; t = (S[i] + S[j])
	xor bx, bx
	mov bl, dl
	mov ch, byte [di + bx]; K = S[t]
	jmp iter

cane:
	xor cl, cl; counter
	xor ax, ax; ah = i al = j
	mov si, 0x7e00
	mov di, 0x6000

decrypt:
	
	jmp PRGA
iter:	
	xor [si], ch

	inc si; next byte
	inc cl
	cmp cl, 58; size of payload
	je end
	jmp decrypt

end:
	jmp 0x7e0:0

key: db "aaaaaaa0"
	times 510-($-$$) db 0
	dw 0xaa55
