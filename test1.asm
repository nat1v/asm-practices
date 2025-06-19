section .data
    Nama:     db 'Komang Adi Ari Jaya Kusuma',10  ; NAMA + plus a linefeed character
    namaLen:  equ $-Nama                      ; Length of the 'NAMA' string
    NIM:      db '2415101033',10
    NIMLen:   equ $-NIM                       ; Length nim
    
    msgInput: db 'silahkan masukan nomor: '
    msgInputLen: equ $-msgInput                ; Corrected the colon here too for consistency
    
    msgOutput: db 'nomor anda: '
    msgOutputLen: equ $-msgOutput             ; <<< CORRECTED LINE
    
section .bss
    userInput resb 256  ; Reserve 256 bytes for user input.

section .text
    global _start

_start:
    ; Print Nama
    mov eax,4           ; The system call for write (sys_write)
    mov ebx,1           ; File descriptor 1 - standard output
    mov ecx,Nama        ; Put the offset of Nama in ecx
    mov edx,namaLen     ; Put the length of Nama in edx
    int 80h             ; call kernel to print
                         
    ; Print NIM
    mov eax,4           ; The system call for write (sys_write)
    mov ebx,1
    mov ecx,NIM
    mov edx,NIMLen
    int 80h
    
    ; Print msgInput (prompt for input)
    mov eax,4           ; The system call for write (sys_write)
    mov ebx,1
    mov ecx,msgInput
    mov edx,msgInputLen
    int 80h
    
    ; Read user input
    mov eax, 3          ; System call for read (sys_read)
    mov ebx, 0          ; File descriptor 0 - standard input (stdin)
    mov ecx, userInput  ; Buffer to store the input
    mov edx, 256        ; Maximum number of bytes to read
    int 80h             ; Call kernel
                        ; After this, 'eax' will contain the number of bytes read

    ; Save the number of bytes read
    mov esi, eax        ; Store the number of bytes read in esi

    ; Display "nomor anda: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msgOutput
    mov edx, msgOutputLen ; Now edx will have the correct length for 'nomor anda: '
    int 80h

    ; Display the actual user input
    mov eax, 4
    mov ebx, 1
    mov ecx, userInput  ; Pointer to the stored input
    mov edx, esi        ; Length of the input to print (bytes read by sys_read)
    int 80h
    
    ; Exit program
    mov eax,1           ; syscall to exit
    mov ebx,0           ; Exit with return "code" of 0 (no error)
    int 80h;

