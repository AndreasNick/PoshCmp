;====================================
;Minimalistic PowerShell to 
;Machinecode (Assembler) Compiler
;Andreas Nick 2019
;====================================

format PE Console
entry start
Include '%include%\win32a.inc'
;=======================================
section '.code' code readable executable
;=======================================
start:
;= variable =
     mov eax, 1
     mov [i], eax
;= variable =
     mov eax, 0
     mov [j], eax
;= variable =
     mov eax, 10
     mov [k], eax
;= while =
.LABEL1:
     mov eax, [k]
     CMP EAX, 0
     JBE .LABEL2
     ccall   [printf], D653, [i]
     mov eax, [i]
     mov ecx, eax
     mov eax, [j]
     add eax, ecx
     mov [i], eax
     mov eax, [i]
     mov ecx, eax
     mov eax, [j]
     neg eax
     add eax, ecx
     mov [j], eax
     mov eax, [k]
     mov ecx, eax
     mov eax, 1
     neg eax
     add eax, ecx
     mov [k], eax
     JMP .LABEL1
.LABEL2:
    stdcall [ExitProcess],0
;====================================
section '.bss' readable writeable
;====================================
     i dd ?
     j dd ?
     k dd ?
;============ Constants ===============
section '.data' data readable writeable
;======================================

printfempty  db 10,0
printfint    db "%lu",10,0
D653         db "fibu %lu", 10, 0

;====================================
section '.idata' import data readable
;====================================

library kernel,'kernel32.dll',\
        msvcrt,'msvcrt.dll'

import  kernel,\
        ExitProcess,'ExitProcess',\
        AllocConsole,'AllocConsole'

import  msvcrt,\
        printf,'printf',\
        getchar,'_fgetchar'
