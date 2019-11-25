MAXOP   =   20                                                  // define constant MAXOP
NUMBER  =   0                                                   // define constant NUMBER
TOOBIG  =   9                                                   // define constant TOOBIG
MAXVAL  =   100                                                 // define constant MAXVAL
BUFSIZE =   100                                                 // define constant BUFSIZE

.bss                                                            // define pseudo-op .bss: all following values are stored in the bss section
sp:             .skip 4                                         // initialize sp variable 
val:            .skip 4 * MAXVAL                                // initialize val array 
bufp:           .skip 4                                         // initialize buffer pointer variable
buf:            .skip 1 * BUFSIZE                               // intialize buf array

.text                                                           // define pseudo-op .text: use default .text section for following ops
.global sp                                                      // make sp global
.global val                                                     // make val global
.global bufp                                                    // make bufp global
.global buf                                                     // make buf global

printError1:    .string "error: stack full\n"                   // string literal for error in push()
printError2:    .string "error: stack empty\n"                  // string literal for error in pop()
printError3:    .string "ungetch: too many characters\n"        // string literal for invalid input error in ungetch()

.balign         4                                               // quadword instruction alignment

push:
    stp         x

pop:
    stp         x

clear:
    stp         x

getop:
    stp         x

getch:
    stp         x

ungetch:
    stp         x

done:
    ldp         x29, x30, [sp], 16
    ret
