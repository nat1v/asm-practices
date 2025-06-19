section .bss
    input1  resb 10
    input2  resb 10
    result  resb 12         ; Max 11 chars + null (e.g., -2147483648)
    result_len resb 4

section .data
    nim             db 'NIM: 2415101033', 10
    nimLen          equ $ - nim
    
    nama            db 'Nama: mang di', 10
    namaLen         equ $ - nama

    msg1            db 10, ' bilangan pertama: '
    msg1Len         equ $ - msg1

    msg2            db ' bilangan kedua: '
    msg2Len         equ $ - msg2

    msgHasil        db 10, 'Hasil penjumlahan: '
    msgHasilLen     equ $ - msgHasil

    newline         db 10
    newlineLen      equ $ - newline

section .text
    global _start

_start:
    ; Tampilkan NIM
    mov eax, 4
    mov ebx, 1
    mov ecx, nim
    mov edx, nimLen
    int 0x80

    ; Tampilkan Nama
    mov eax, 4
    mov ebx, 1
    mov ecx, nama
    mov edx, namaLen
    int 0x80

    ; Input bilangan pertama
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, msg1Len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input1
    mov edx, 10
    int 0x80
    mov ebp, eax
    cmp byte [input1 + ebp - 1], 10 ; Check if last char is newline
    jne .skip_newline_input1
    dec ebp                         ; Don't count newline in length
.skip_newline_input1:
    mov byte [input1 + ebp], 0      ; Null-terminate
    
    ; Input bilangan kedua
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, msg2Len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input2
    mov edx, 10
    int 0x80
    mov ebp, eax
    cmp byte [input2 + ebp - 1], 10 ; Check if last char is newline
    jne .skip_newline_input2
    dec ebp                         ; Don't count newline in length
.skip_newline_input2:
    mov byte [input2 + ebp], 0      ; Null-terminate

    ; Konversi input1 ke integer
    mov esi, input1
    call str_to_int
    mov edi, eax                    ; Store first number in EDI

    ; Konversi input2 ke integer
    mov esi, input2
    call str_to_int
    add eax, edi                    ; Sum is now in EAX

    ; Konversi hasil ke string
    mov ebx, result                 ; EBX points to result buffer
    call int_to_str                 ; EAX (sum) is input. Returns length in ECX.
    mov [result_len], ecx           ; Store length

    ; Tampilkan pesan hasil
    mov eax, 4
    mov ebx, 1
    mov ecx, msgHasil
    mov edx, msgHasilLen
    int 0x80

    ; Tampilkan hasil penjumlahan
    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, [result_len]           ; Use stored length
    int 0x80

    ; Print final newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, newlineLen
    int 0x80

    ; Akhiri program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; -----------------------------------------
; str_to_int: konversi string ke integer
; input: ESI -> pointer string (null-terminated)
; output: EAX = integer
; -----------------------------------------
str_to_int:
    xor eax, eax        ; hasil = 0
    xor ecx, ecx        ; index = 0

.next_char:
    mov bl, [esi + ecx]
    cmp bl, 0           ; null terminator
    je .done_str_to_int

    sub bl, '0'         ; ASCII ke nilai angka
    imul eax, 10        ; eax = eax * 10
    add eax, ebx        ; eax = eax + (digit from bl)
    inc ecx
    jmp .next_char

.done_str_to_int:
    ret

; -----------------------------------------
; int_to_str: konversi integer ke string
; input: EAX = integer, EBX = buffer (e.g., 'result')
; output: ASCII string hasil di buffer (null-terminated),
;         ECX = length of the string (excluding null terminator)
; -----------------------------------------
int_to_str:
    ; Save registers used by this function
    push eax            ; Original number
    push ebx            ; Buffer address
    push edx            ; Remainder/divisor
    push edi            ; Temporary pointer

    mov edi, ebx        ; EDI = buffer start address
    mov ecx, 0          ; ECX = string length counter

    ; Handle negative numbers
    cmp eax, 0
    jge .handle_positive_or_zero

    ; If negative
    mov byte [edi], '-' ; Put sign in buffer
    inc edi             ; Move pointer past sign
    inc ecx             ; Count sign in length
    neg eax             ; Make number positive for conversion

.handle_positive_or_zero:
    ; Handle zero case
    cmp eax, 0
    jnz .convert_digits

    mov byte [edi], '0' ; If number is 0, just put '0'
    mov byte [edi+1], 0 ; Null-terminate
    inc ecx             ; Length is 1
    jmp .int_to_str_done ; Done

.convert_digits:
    ; Build string in reverse at the end of the buffer
    ; The 'result' buffer is 12 bytes. We need space for 11 digits + null.
    ; Point 'temp_ptr' to the space for the null terminator.
    mov ebp, ebx        ; EBP will be our temporary pointer
    add ebp, 11         ; EBP now points to index 11 (last byte of result buffer)
    mov byte [ebp], 0   ; Null-terminate the string at its maximum possible end

.loop_digits:
    xor edx, edx        ; Clear EDX for division
    mov esi, 10         ; Divisor
    div esi             ; EAX / 10 -> EAX = quotient, EDX = remainder
    add dl, '0'         ; Convert remainder to ASCII digit
    dec ebp             ; Move temp pointer backward
    mov [ebp], dl       ; Store digit
    test eax, eax       ; Check if quotient is zero
    jnz .loop_digits

    ; EBP now points to the first digit of the number (or sign if it was negative)
    ; EDI points to the start of the 'result' buffer (after potential sign)
    ; Now, copy the string from EBP to EDI

.copy_string:
    mov al, [ebp]       ; Get character from temporary string
    mov [edi], al       ; Put character into final buffer
    inc ebp             ; Move source pointer
    inc edi             ; Move destination pointer
    inc ecx             ; Increment actual string length
    cmp al, 0           ; Check for null terminator
    jne .copy_string

    dec ecx             ; Do not count the null terminator in the length

.int_to_str_done:
    ; Restore registers
    pop edi
    pop edx
    pop ebx
    pop eax
    ret