global start	;; make start label available outside this form

section .text

bits 32

start:
	call print_hello
	hlt

print_hello:
	;; take the hello world from ../bootloader. It is the same code
	;; but this time it is grub that setups things for us...

	mov word [0xb8000], 0x0E48 ;; 0x0: background black
				   ;; 0xE: foreground yellow
				   ;; 0x48:H
	mov word [0xb8002], 0x0E65 ;; e
	mov word [0xb8004], 0x0E6c ;; l
	mov word [0xb8006], 0x0E6c ;; l
	mov word [0xb8008], 0x0E6f ;; o
	mov word [0xb800a], 0x0E2c ;; ,
	mov word [0xb800c], 0x0E20 ;;
	mov word [0xb800e], 0x0E77 ;; w
	mov word [0xb8010], 0x0E6f ;; o
	mov word [0xb8012], 0x0E72 ;; r
	mov word [0xb8014], 0x0E6c ;; l
	mov word [0xb8016], 0x0E64 ;; d
	mov word [0xb8018], 0x0E21 ;; !

	ret
