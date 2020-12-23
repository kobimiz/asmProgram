    # Kobi Mizrahi
    .section .rodata
print_PString:   .string "length %u, '%s'\n"

    .text
    .globl pstrlen
    .type pstrlen, @function

    .globl replaceChar
    .type replaceChar, @function

    .globl pstrijcpy
    .type pstrijcpy, @function

    .globl swapCase
    .type swapCase, @function

    .globl pstrijcmp
    .type pstrijcmp, @function

pstrlen:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

doneRetPtr:
    # %rdi is a pointer to PString
    movzbq  (%rdi), %rax        # the first byte of a pstring is its length

    movq    %rbp, %rsp
    popq    %rbp
    ret

replaceChar:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

    # %rdi is a pointer to PString
    # %rsi is the old char
    # %rdx is the new char

    # get length
    call    pstrlen

    # do while %rax is greater than 0
    test    %rax, %rax
    jz      doneRetPtr          # jump if 0
loop1:
    # get the current char
    movb    (%rdi, %rax,), %r8b
    cmp     %r8b, %sil          # compare the first byte of the current char and char we are looking for
    jnz     skip1
    movb    %dl, (%rdi, %rax,)  # if last comparison was succussful, put new char (%dl = first byte of %rdx)
skip1:
    sub     $1, %rax
    test    %rax, %rax
    jnz     loop1               # jump if not 0
    # return pointer to PString
    jmp     doneRetPtr


pstrijcpy:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

    # %rdi is a pointer to PString1
    # %rsi is a pointer to PString2
    # %rdx is i
    # %rcx is j

    # do while their difference is non negative
    cmp     %edx, %ecx
    js      doneRetPtr          # jump if negative
loop2:
    # get address to replace
    leaq    1(%rdi, %rcx,), %r8
    # get character to replace with
    movb    1(%rsi, %rcx,), %r9b
    movb    %r9b, (%r8)         # replace

    sub     $1, %ecx            # decrease counter
    cmp     %edx, %ecx
    jge     loop2               # jump if j>=i
    jmp     doneRetPtr

swapCase:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

    # %rdi is a pointer to PString1

    # get length
    call    pstrlen

    # do while %rax is greater than 0
    test    %rax, %rax
    jz      doneRetPtr          # jump if 0
loop3:
    # ascii:
    # A-65, Z-90, a-97, z-122 ===> dif=32
    # get the current char
    movb    1(%rdi, %rax,), %r8b

lowercase:
    cmp     $122, %r8b
    jg      skip3 # if >122
    cmp     $97, %r8b
    js      uppercase # if <97

    sub     $32, %r8b           # convert to uppercase
    movb    %r8b, 1(%rdi, %rax,)
    jmp     skip3
uppercase:
    cmp     $90, %r8b
    jg      skip3               # if >90
    cmp     $65, %r8b
    js      skip3               # if <65

    add     $32, %r8b           # convert to lowercase
    movb    %r8b, 1(%rdi, %rax,)
skip3:
    sub     $1, %rax
    test    %rax, %rax
    jns     loop3               # jump if not 0
    jmp     doneRetPtr


pstrijcmp:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

    # %rdi is a pointer to PString1
    # %rsi is a pointer to PString2
    # %rdx is a i
    # %rcx is a j

    cmp     %edx, %ecx
    js      doneRetVoid         # jump if negative
loop4:
    movb    1(%rdi, %rdx,), %r8b # get the current char of string1
    movb    1(%rsi, %rdx,), %r9b # get the current char of string2

    # compare the two characters. if not equal can deduce lexicographic order
    cmp     %r8b, %r9b
    ja      string2Bigger
    jb      string1Bigger
    jmp     skip4
string2Bigger:
    movq    $-1, %rax
    jmp     doneRetVoid
string1Bigger:
    movq    $1, %rax
    jmp     doneRetVoid
skip4:
    add     $1, %edx
    cmp     %edx, %ecx
    jge     loop4               # jump if j>=i

    # iff we made it this far, the strings are equal
    movq    $0, %rax

doneRetVoid:
    movq    %rbp, %rsp
    popq    %rbp
    ret
