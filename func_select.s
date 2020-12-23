    # Kobi Mizrahi
    .section .rodata
print_PStrings:            .string "first pstring length: %d, second pstring length: %d\n"
print_PStrings_replaced:   .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
scan_two_chars:            .string " %c %c"
scan_two_ints:             .string " %u %u"
invalid_input:             .string "invalid input!\n"
print_new_pstring:         .string "length: %d, string: %s\n"
invalid_option:            .string "invalid option!\n"
compare_result:            .string "compare result: %d\n"

    .cases:
    .quad case50_60
    .quad caseDef
    .quad case52
    .quad case53
    .quad case54
    .quad case55
    .quad caseDef
    .quad caseDef
    .quad caseDef
    .quad caseDef
    .quad case50_60

    .text
    .globl run_func
    .type run_func, @function
run_func:
    # initializing- saving the old frame, creating a new one and saving the callee save register
	pushq   %rbp
	movq    %rsp, %rbp

    # set up the stack with the given parameters
    pushq   %rdi                            # option
    pushq   %rsi                            # pointer to first PString
    pushq   %rdx                            # pointer to second PString
    leaq    -8(%rsp), %rsp                  # alignment

    # make jump table
    subl    $50, %edi                       # subtract from option
    cmpl    $10, %edi
    ja      caseDef
    jmp     *.cases(, %edi, 8)

case50_60:
    sub     $16, %rsp                       # allocate memory for two lengths returned by pstrlen

    # get first pstring length
    movq    -16(%rbp), %rdi
    call    pstrlen
    movq    %rax, 8(%rsp)

    # get second pstring length
    movq    -24(%rbp), %rdi
    call    pstrlen
    movq    %rax, 16(%rsp)

    # print the PStrings
    movq    $print_PStrings, %rdi
    movq    8(%rsp), %rsi
    movq    16(%rsp), %rdx
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
    jmp     done

case52:
    sub     $16, %rsp                       # allocate memory for 2 chars (and align)

    # scan the chars
    movq    $scan_two_chars, %rdi
    leaq    (%rsp), %rsi
    leaq    1(%rsp), %rdx
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    scanf

    # replace chars in first PString
    mov     -16(%rbp), %rdi
    mov     (%rsp), %rsi
    mov     1(%rsp), %rdx
    call    replaceChar

    # replace chars in second PString
    mov     -24(%rbp), %rdi
    call    replaceChar

    # print replaced chars
    movq    $print_PStrings_replaced, %rdi
    movq    (%rsp), %rsi                    # put old char as second argument
    movq    1(%rsp), %rdx                   # put new char as third argument

    movq    -16(%rbp), %rax                 # get pointer to first PString
    leaq    1(%rax), %rcx                   # the string pointer starts at the second byte
    movq    -24(%rbp), %rax                 # get pointer to second PString
    leaq    1(%rax), %r8                    # the string pointer starts at the second byte
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
    jmp     done

case53:
    sub     $16, %rsp                       # allocate memory for 2 ints (and align)

    # scan the ints
    movq    $scan_two_ints, %rdi
    leaq    (%rsp), %rsi
    leaq    4(%rsp), %rdx
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    scanf

    # check if ints are valid
    movl    (%rsp) , %r8d # get i
    movl    4(%rsp), %r9d # get j

    # check if i or j negative
    test    %r8d, %r8d
    js      invalidInput
    test    %r9d, %r9d
    js      invalidInput

    # check if i or j are exceeding either strings' length
    # get first strings length
    movq    -16(%rbp), %rdi
    call    pstrlen
    sub     $1, %rax                        # %rax is length and i want to compare it to index
    cmp     %r8d, %eax
    js      invalidInput                    # if i > maxIndex1
    cmp     %r9d, %eax
    js      invalidInput                    # if j > maxIndex1
    
    # get second strings length
    movq    -24(%rbp), %rdi
    call    pstrlen
    sub     $1, %rax                        # %rax is length and i want to compare it to index
    cmp     %r8d, %eax
    js      invalidInput                    # if i > maxIndex2
    cmp     %r9d, %eax
    js      invalidInput                    # if j > maxIndex2

    # valid input if reached here. pass parameters to pstrijcpy
    movq    -16(%rbp), %rdi
    movq    -24(%rbp), %rsi
    movl    %r8d     , %edx
    movl    %r9d     , %ecx
    call    pstrijcpy
    jmp     printOutput
invalidInput:
    movq    $invalid_input, %rdi
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
printOutput:
    # print the first pstring
    movq    $print_new_pstring, %rdi
    movq    -16(%rbp), %rax                 # get pointer to first PString
    movzbq  (%rax), %rsi                    # get string length, only one byte was written by scanf
    leaq    1(%rax), %rdx                   # the string pointer starts at the second byte
    xorq    %rax, %rax 
    call    printf

    # print the second pstring
    movq    $print_new_pstring, %rdi
    movq    -24(%rbp), %rax                 # get pointer to second PString
    movzbq  (%rax), %rsi                    # get string length, only one byte was written by scanf
    leaq    1(%rax), %rdx                   # the string pointer starts at the second byte
    xorq    %rax, %rax 
    call    printf
    jmp     done

case54:
    # swap first pstring
    movq    -16(%rbp), %rdi
    call    swapCase
    # swap second pstring
    movq    -24(%rbp), %rdi
    call    swapCase

    # print the first pstring
    movq    $print_new_pstring, %rdi
    movq    -16(%rbp), %rax                 # get pointer to first PString
    movzbq  (%rax), %rsi                    # get string length, only one byte was written by scanf
    leaq    1(%rax), %rdx                   # the string pointer starts at the second byte
    xorq    %rax, %rax 
    call    printf

    # print the second pstring
    movq    $print_new_pstring, %rdi
    movq    -24(%rbp), %rax                 # get pointer to second PString
    movzbq  (%rax), %rsi                    # get string length, only one byte was written by scanf
    leaq    1(%rax), %rdx                   # the string pointer starts at the second byte
    xorq    %rax, %rax 
    call    printf
    jmp     done

case55:
    sub     $16, %rsp                       # allocate memory for 2 ints (and align)

    # scan the ints
    movq    $scan_two_ints, %rdi
    leaq    (%rsp), %rsi
    leaq    4(%rsp), %rdx
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    scanf

    # check if ints are valid
    movl    (%rsp) , %r8d                   # get i
    movl    4(%rsp), %r9d                   # get j

    # check if i or j negative
    test    %r8d, %r8d
    js      invalidInput2
    test    %r9d, %r9d
    js      invalidInput2

    # check if i or j are exceeding either strings' length
    # get first strings length
    movq    -16(%rbp), %rdi
    call    pstrlen
    sub     $1, %rax                        # %rax is length and i want to compare it to index
    cmp     %r8d, %eax
    js      invalidInput2                   # if i > maxIndex1
    cmp     %r9d, %eax
    js      invalidInput2                   # if j > maxIndex1
    
    # get second strings length
    movq    -24(%rbp), %rdi
    call    pstrlen
    sub     $1, %rax                        # %rax is length and i want to compare it to index
    cmp     %r8d, %eax
    js      invalidInput2                   # if i > maxIndex2
    cmp     %r9d, %eax
    js      invalidInput2                   # if j > maxIndex2

    # valid input
    movq    -16(%rbp), %rdi
    movq    -24(%rbp), %rsi
    movl    %r8d     , %edx
    movl    %r9d     , %ecx
    call    pstrijcmp

validInput:
    # print the result
    movq    $compare_result, %rdi
    movq    %rax, %rsi
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
    jmp     done
invalidInput2:
    movq    $invalid_input, %rdi
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
    movq    $-2, %rax
    jmp     validInput

caseDef:
    movq    $invalid_option, %rdi
    xorq    %rax, %rax                      # zero out %rax as instructed
    call    printf
    jmp     done

done:
    # exiting function- restoring old stack pointer and frame pointer
    movq    %rbp, %rsp
    popq    %rbp
    ret
