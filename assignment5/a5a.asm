//MAXOP   =   20                                                  // define constant MAXOP
//NUMBER  =   0                                                   // define constant NUMBER
//TOOBIG  =   9                                                   // define constant TOOBIG
//MAXVAL  =   100                                                 // define constant MAXVAL
//BUFSIZE =   100                                                 // define constant BUFSIZE

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
//.global bufp                                                    // make bufp global
//.global buf                                                     // make buf global

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
//.global getch                                                   // make getch subroutine global
//.global ungetch                                                 // make ungetch subroutine global

//.global MAXVAL
//.global BUFSIZE

// push() subroutine
push:
    stp         fp, lr, [sp, -16]!                              // allocate memory for push()
    mov         fp, sp                                          // store current sp on the fp

    mov         w9, w0
    
    adrp        x19, sp_a                                       //
    add         x19, x19, :lo12:sp_a                            //
    ldr         w24, [x19]                                      //

    adrp        x20, val_a                                      //
    add         x20, x20, :lo12: val_a                          //
    ldr         w25, [x20]                                      //

    cmp         w24, MAXVAL                                     // compare 
    b.ge        pushElse                                        //

    str         w9, [x25, w24, SXTW 2]                          // store int f in val[sp]
    add         x24, x24, 1                                     // increment sp by 1
    str         w24, [x19]                                      // update sp in memory

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
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    adrp        x21, sp_a
    add         x21, x21, :lo12:sp_a
    ldr         w26, [x21]

    adrp        x22, val_a
    add         x22, x22, :lo12: val_a
    ldr         w27, [x22]

    cmp         w26, 0                                          //
    b.ge        popElse                                         //

    sub         w26, w26, 1                                     // pre decrement sp (--sp)
    
    adrp        x23, val_a                                      //
    add         x23, x23, :lo12:val_a                           //
    str         w23, [x23, w26, SXTW 2]                         //

    mov         w0, w23                                         // value to be returned

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
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp                                          //

    adrp        x14, sp_a                                       //
    add         x14, x14, :lo12:sp_a                            //
    ldr         w14, [x14]                                      //

    mov         w14, 0                                          //
    str         w14, [x14]                                      //

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //

/*
// getop() subroutine
getop:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //

// getch subroutine
getch:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //

// ungetch() subroutine
ungetch:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //
*/
// deallocate memory and exit program
done:
    ldp         fp, lr, [sp], 16                                //
    ret                                                         //
