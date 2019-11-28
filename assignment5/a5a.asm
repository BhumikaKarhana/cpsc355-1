//MAXOP   =   20                                                  // define constant MAXOP
//NUMBER  =   0                                                   // define constant NUMBER
//TOOBIG  =   9                                                   // define constant TOOBIG
MAXVAL  =   100                                                 // define constant MAXVAL
BUFSIZE =   100                                                 // define constant BUFSIZE

//define(MAXOP, 20)
//define(NUMBER, 0)
//define(TOOBIG, 9)
//define(MAXVAL, 100)
//define(BUFSIZE, 100)

.bss                                                            // define pseudo-op .bss: all following values are stored in the bss section
sp_a:           .skip 4                                         // initialize sp variable 
val:            .skip 4 * MAXVAL                                // initialize val array 
bufp:           .skip 4                                         // initialize buffer pointer variable
buf:            .skip 1 * BUFSIZE                               // intialize buf array

.text                                                           // define pseudo-op .text: use default .text section for following ops
.global sp_a                                                    // make sp_a global
.global val                                                     // make val global
.global bufp                                                    // make bufp global
.global buf                                                     // make buf global

printError1:    .string "error: stack full\n"                   // string literal for error in push()
printError2:    .string "error: stack empty\n"                  // string literal for error in pop()
printError3:    .string "ungetch: too many characters\n"        // string literal for invalid input error in ungetch()

.balign         4                                               // quadword instruction alignment

fp  .req        x29                                             // register alias for frame pointer
lr  .req        x30                                             // register alias for link register

.global push                                                    // make push subroutine global
//.global pop                                                     // make pop subroutine global
//.global clear                                                   // make clear subroutine global
//.global getop                                                   // make getop subroutine global
//.global getch                                                   // make getch subroutine global
//.global ungetch                                                 // make ungetch subroutine global

// push() subroutine
push:
    stp         fp, lr, [sp, -16]!                              // allocate memory for push()
    mov         fp, sp

    cmp         sp, MAXVAL                                      //
    b.ge        pushElse                                        //

    ldr         
    //mov         w0, 

    b           pushContinue                                    // continue to end of subroutine (by skipping over else)

pushElse:                                                       // logic for else statement in push()
    adrp        x0, printError1                                 // print error
    add         x0, x0, :lo12:printError1                       // print error
    bl          printf                                          // branch and link printf

pushContinue:                                                   // end of push() subroutine
    ldp         fp, lr, [sp], 16                                // deallocate memory from push() subroutine
    ret                                                         // return from subroutine
    
// pop() subroutine
pop:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //

// clear() subroutine
clear:
    stp         fp, lr, [sp, -16]!                              //
    mov         fp, sp

    ldp         fp, lr, [sp], 16                                //
    ret                                                         //

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

// deallocate memory and exit program
done:
    ldp         fp, lr, [sp], 16                                //
    ret                                                         //
