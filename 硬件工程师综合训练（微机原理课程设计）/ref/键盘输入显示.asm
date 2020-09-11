;******************************************
;��8086ϵ��΢���ӿ�ʵ��ϵͳ�����ʵ����Ŀ
;������ɨ����ʾʵ��
;******************************************
code    segment
        assume cs:code

OUTSEG  equ  0ffdch             ;�ο��ƿ�
OUTBIT  equ  0ffddh             ;λ���ƿ�/��ɨ��
IN_KEY  equ  0ffdeh             ;���̶����
LedBuf  db   6 dup(?)           ;��ʾ����

        org  1000h
Start:
        mov  LedBuf+0,0c2h      ;��ʾ"Good"
        mov  LedBuf+1,0a3h
        mov  LedBuf+2,0a3h
        mov  LedBuf+3,0a1h
        mov  LedBuf+4,0ffh
        mov  LedBuf+5,0ffh

MLoop:
        call Disp               ;��ʾ
        call GetKey             ;ɨ����̲���ȡ��ֵ
        and  al,0fh             ;��ʾ����
        mov  ah,0
        mov  bx,offset LEDMAP
        add  bx,ax
        mov  al,[bx]
        mov  LEDBuf+5,al
        jmp  MLoop

Disp:
        mov  bx,offset LEDBuf
        mov  cl,6               ;��6���˶ι�
        mov  ah,00100000b       ;����߿�ʼ��ʾ
DLoop:
        mov  dx,OUTBIT
        mov  al,0
        out  dx,al              ;�����а˶ι�
        mov  al,[bx]
        mov  dx,OUTSEG
        out  dx,al

        mov  dx,OUTBIT
        mov  al,ah
        out  dx,al              ;��ʾһλ�˶ι�

        push ax
        mov  ah,1
        call Delay
        pop  ax

        shr  ah,1
        inc  bx
        dec  cl
        jnz  DLoop

        mov  dx,OUTBIT
        mov  al,0
        out  dx,al              ;�����а˶ι�
        ret

Delay:                          ;��ʱ�ӳ���
        push  cx
        mov   cx,256
        loop  $
        pop   cx
        ret

GetKey:                         ;��ɨ�ӳ���
        mov  al,0ffh            ;����ʾ��
        mov  dx,OUTSEG
        out  dx,al
        mov  bl,0
        mov  ah,0feh
        mov  cx,8
key1:   mov  al,ah
        mov  dx,OUTBIT
        out  dx,al
        shl  al,1
        mov  ah,al
        nop
        nop
        nop
        nop
        nop
        nop
        mov  dx,IN_KEY
        in   al,dx
        not  al
        nop
        nop
        and  al,0fh
        jnz  key2
        inc  bl
        loop key1
nkey:   mov  al,20h
        ret
key2:   test al,1
        je   key3
        mov  al,0
        jmp  key6
key3:   test al,2
        je   key4
        mov  al,8
        jmp  key6
key4:   test al,4
        je   key5
        mov  al,10h
        jmp  key6
key5:   test al,8
        je   nkey
        mov  al,18h
key6:   add  al,bl
        cmp  al,10h
        jnc  fkey
        mov  bx,offset KeyTable
        xlat
fkey:   ret

LedMap:                         ;�˶ι���ʾ��
        db   0c0h,0f9h,0a4h,0b0h,099h,092h,082h,0f8h
        db   080h,090h,088h,083h,0c6h,0a1h,086h,08eh

KeyTable:                       ;���붨��
        db   07h,04h,08h,05h,09h,06h,0ah,0bh
        db   01h,00h,02h,0fh,03h,0eh,0ch,0dh

code    ends
        end Start
