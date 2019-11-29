//define(MAXOP, 20)
//define(NUMBER, 0)
//define(TOOBIG, 9)
//define(MAXVAL, 100)
//define(BUFSIZE, 100)

.bss                                                            // define pseudo-op .bss: all following values are stored in the bss section
val_a:          .skip 4 * MAXVAL                                // initialize val array 
buf:            .skip BUFSIZE                                   // intialize buf array
sp_a:           .skip 4                                         // initialize sp variable 
bufp:           .skip 4                                         // initialize buffer pointer variable

.text                                                           // define pseudo-op .text: use default .text section for following ops
.global sp_a                                                    // make sp_a global
.global val_a                                                   // make val global
.global bufp                                                    // make bufp global
.global buf                                                     // make buf global

printError1:    .string "error: stack full\n"                   // string literal for error in push()
printError2:    .string "error: stack empty\n"                  // string literal for error in pop()
printError3:    .string "ungetch: too many characters\n"        // string literal for invalid input error in ungetch()

.balign         4                                               // quadword instruction alignment

fp  .req        x29                                             // register alias for frame pointer
lr  .req        x30                                             // register alias for link register

.global push                                                    // make push subroutine global
.global pop                                                     // make pop subroutine global
.global clear                                                   // make clear subroutine global
//.global getop                                                   // make getop subroutine global
.global getch                                                   // make getch subroutine global
.global ungetch                                                 // make ungetch subroutine global

// push() subroutine
push:
    stp         fp, lr, [sp, -16]!                              // allocate memory for push()
    mov         fp, sp                                          // store current sp on the fp

    mov         w9, w0                                          // move first argument in temp register w9
    
    adrp        x11, sp_a                                       // get address of sp_a
    add         x11, x11, :lo12:sp_a                            // low 12 bits of the sp_a address
    ldr         w11, [x11]                                      // load value from pointer address

    adrp        x10, val_a                                      // get address of val_a
    add         x10, x10, :lo12: val_a                          // low 12 bits of the val_a address
    ldr         w10, [x10]                                      // load value from pointer address

    cmp         w11, MAXVAL                                     // compare sp_a value to MAXVAL
    b.ge        pushElse                                        // branch to else statment if the if-test fails

    str         w9, [x10, w11, SXTW 2]                          // store int f in val[sp]
    add         x11, x11, 1                                     // increment sp by 1
    str         w11, [x11]                                      // update sp in memory

    b           pushContinue                                    // continue to end of subroutine (by skipping over else)

pushElse:                                                       // logic for else statement in push()
    adrp        x0, printError1                                 // print error
    add         x0, x0, :lo12:printError1                       // print error
    bl          printf                                          // branch and link printf

    bl          clear                                           // branch and link clear
    mov         w0, 0                                           // return 0 (by mov-ing 0 in w0)

pushContinue:                                                   // end of push() subroutine
    ldp         fp, lr, [sp], 16                                // deallocate memory from push() subroutine
    ret                                                         // return from subroutine
    
// pop() subroutine
pop:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update fp to current sp

    adrp        x12, sp_a                                       // get address of sp_A
    add         x12, x12, :lo12:sp_a                            // low 12 bits of the sp_a address
    ldr         w12, [x12]                                      // load value from pointer address

    adrp        x13, val_a                                      // get address of val_a
    add         x13, x13, :lo12: val_a                          // low 12 bits of val_a
    ldr         w13, [x13]                                      // load value from given address

    cmp         w12, 0                                          // compare sp_a value to 0
    b.ge        popElse                                         // branch to else statement if the if-test fails

    sub         w12, w12, 1                                     // pre decrement sp (--sp)
    
    adrp        x14, val_a                                      // get address of val_a
    add         x14, x14, :lo12:val_a                           // low 12 bits of the address
    str         w14, [x14, w12, SXTW 2]                         // update value of sp in val

    mov         w0, w14                                         // value to be returned

    //str         w9, [x20, x19, SXTW 2]                          // store int f in val[sp]
    //add         x19, x19, 1                                     // increment sp by 1
    //str         x19, [w19]                                      // update sp in memory
    
    b           popContinue                                     // continue to end of subroutine (by skipping over else)

popElse:                                                        // logic for else statement in pop()
    adrp        x0, printError2                                 // print error
    add         x0, x0, :lo12:printError2                       // print error
    bl          printf                                          // branch and link printf

    bl          clear                                           // branch and link clear
    mov         w0, 0                                           // return 0 (by mov-ing 0 in w0)

popContinue:                                                    // end of push() subroutine
    ldp         fp, lr, [sp], 16                                // deallocate memory from push() subroutine
    ret                                                         // return from subroutine

// clear() subroutine
clear:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update fp to current sp

    adrp        x14, sp_a                                       // get address of sp_a
    add         x14, x14, :lo12:sp_a                            // low 12 bits of address
    ldr         w14, [x14]                                      // load value from given address

    mov         w14, 0                                          // zero the sp register
    str         w14, [x14]                                      // store new sp value

    ldp         fp, lr, [sp], 16                                // deallocate memory
    ret                                                         // return from subroutine

/*
// getop() subroutine
getop:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //
*/

// getch subroutine
getch:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update fp to current sp

    adrp        x15, bufp                                       // get address of bufp
    add         x15, x15, :lo12:bufp                            // low 12 bits of the bufp address
    ldr         w15, [x15]                                      // load value from pointer address

    adrp        x10, buf                                        // get address of buf
    add         x10, x10, :lo12:buf                             // low 12 bits of buf
    ldr         w10, [x10]                                      // load value from given address

    cmp         w10, 0                                          // if buf <= 0
    b.le        getCharBranch                                   // branch to getChar

    sub         w10, w10, 1                                     // decrement value of buf
    ldr         w0, [x10, w15, SXTW 2]                          // load value of bufp[buf] into result register

getCharBranch:
    bl          getchar                                         // branch and link getchar

getchContinue:
    ldp         fp, lr, [sp], 16                                // deallocate memory
    ret                                                         // return from subroutine


// ungetch() subroutine
ungetch:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update current sp in fp

    adrp        x15, bufp                                       // get address of bufp
    add         x15, x15, :lo12:bufp                            // low 12 bits of the bufp address
    ldr         w15, [x15]                                      // load value from pointer address

    cmp         w15, BUFSIZE                                    // compare result with BUFSIZE
    b.le        ungetchInnerIf                                  // skip over else statement

    adrp        x0, printError3                                 // print error if above test fails
    add         x0, x0, :lo12:printError3                       // print error
    bl          printf                                          // branch and link printf

    b           ungetchContinue                                 // skip over to end of function after printing

ungetchInnerIf:
    adrp	    x12, buf					                    // get address of buf
    add	        x12, x12, :lo12:buf				                // low 12 bits of the buf address

    str	        w0, [x12, w10, SXTW 2]				            // store new buf[bufp]

    add	        w15, w15, 1					                    // increment bufp value
    str	        w10, [x9]					                    // store new value

ungetchContinue:
    ldp         fp, lr, [sp], 16                                // deallocate memory
    ret                                                         // return from subroutin

// deallocate memory and exit program
done:
    ldp         fp, lr, [sp], 16                                // deallocate memory 
    ret                                                         // return from program with exit code
