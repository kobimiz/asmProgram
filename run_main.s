    # 322576364 Kobi Mizrahi
    .section .rodata
scan_unsigned_int:    .string "%u"
scan_str:             .string "%s"

    .text
    .globl run_main
    .type run_main, @function
run_main:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq	%rbp
	movq	%rsp, %rbp

    # need: rdi- option, rsi- first PString, rdx- second PString
    # going to call push_PString twice. this is a counter.
    pushq   $2
    sub     $8, %rsp                # for alignment of 16 bytes

    # pushes pstring to stack (input from user)
push_PString:
    # allocating memory on the stack for the PString
    sub     $16, %rsp               # memory for the length (only one byte is used, but 16 are needed for alignment)
    sub     $256, %rsp              # memory for the string

    # get str1 length (address stored in rsi)
    movq    $scan_unsigned_int, %rdi
    leaq    (%rsp), %rsi
    xorq    %rax, %rax              # zero out %rax as instructed
    call    scanf

    # call scanf again to scan string
    movq    $scan_str, %rdi
    leaq    1(%rsp), %rsi           # pointer to the 2nd byte (the first one is for the length)
    xorq    %rax, %rax              # zero out %rax as instructed
    call    scanf

    # decrement the counter i saved at the begining
    movq    -8(%rbp), %r10          # get the counter
    dec     %r10
    movq    %r10, -8(%rbp)
    jz      pushOption              # if this is the second iteration, out of the loop
    jmp     push_PString            # else, call push_PString for the second time

pushOption:
    # scan option
    sub     $16, %rsp               # allocate memory
    movq    $scan_unsigned_int, %rdi
    leaq    (%rsp), %rsi 
    xorq    %rax, %rax  
    call    scanf

    # right now the option is in %rsp, the second PString is in %rsp+16 and the first is in %rsp+16+(256+16)=%rsp+288
    movq    (%rsp), %rdi
    leaq    288(%rsp), %rsi
    leaq    16(%rsp), %rdx

    call    run_func

    # exiting function- restoring old stack pointer and frame pointer
    movq    %rbp, %rsp
    popq    %rbp
    ret
