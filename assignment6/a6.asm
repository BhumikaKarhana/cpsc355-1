.text                                               // define following instructions in .text section
bufsize =   8                                       // buffer size
alloc   =   -(16 + bufsize) & -16                   // allocation size
dealloc =   -alloc                                  // deallocation size 
buf_s   =   16                                      // buffer offset

printError: .string "\nAn error has occured.\n"     // error string literali
printEOF:   .string "\nEOF\n"                       // print end of file indicator

heading:    .string "Input\t\tln(x)\n"              // column heading output
result:     .string "%13.10f\t%13.10f\n"            // output column of result


endLim: .double 0r1.0e-13                           // limit for stopping the series
//oneF:   .double 0r1.0                               // float 1 used for calculations

fp      .req   x29                                  // register alias for frame pointer
lr      .req   x30                                  // register alias for link register

argc    .req   w19                                  // register alias for argc (main subroutine argument)
argv    .req   x20                                  // register alias for argv (main subroutine argument)

fileD   .req   w21                                  // file descriptor register alias
readB   .req   x24                                  // read bytes register alias
answer  .req   x25                                  // answer alias

multiplicand    .req    d25                         // 1/term number (1/1, 1/2, 1/3, etc.)
numerator       .req    d20                         // Numerator (x-1)
//factor          .req    d21                         // Factorial (n!)
term            .req    d22                         // term = numerator/denominator
acc             .req    d23                         // accumulator = term0 + term1 + term2 + ...
inc             .req    d24                         // increment variable

//fmov         d28, 1

.balign     4                                       // quadword align instructions 
.global     main                                    // make main visible to linker

lnx:
    stp     fp, lr, [sp, alloc]!                    // allocate memory for subroutine
    mov     fp, sp                                  // update frame pointer to current stack pointer

    //  mov     x28, x0
    //ldr     x28, [x0]    mov     x0, x28
    fmov    d9, d0                                  // move input argument into temporary register d9

    adrp    x10, endLim
    add     x10, x10, :lo12:endLim
    ldr     d10, [x10]

    //fadd    d0, d9, d9

    //fsub    numerator, d9, oneF                     // store x - 1 in numerator
    //fdiv    term, numerator, d9                     // store numerator / x in term



    //fmov    d0, d9

    //cmp     d9, d10
    //b.ne    lnxDone

//lnxSeries:
    

lnxDone:
    ldp     fp, lr, [sp], dealloc                   // deallocate subroutine memory
    ret                                             // return from caller from subroutine


main:
    stp     fp, lr, [sp, alloc]!                    // allocate memory
    mov     fp, sp                                  // update frame pointer to current stack pointer

    mov     argc, w0                                // store first argument in argc (count of cmd line arguments)
    mov     argv, x1                                // store second argument in argv (vector of cmd line arguments)

    cmp     argc, 2                                 // check if exactly 2 arguments are provided (program name and input file name)
    b.ne    error                                   // otherwise, print error

    //add     x1, fp, buf_s

top:
    mov     w0, -100                                // read input file
    //mov     x2, bufsize
    //mov     x8, 63
    //svc     0

    //cmp     x0, 0
    //b.le    done

    ldr     x1, [argv, 8]                           // load file name from argv (cmd argument) and set it to argument 0
    mov     w2, 0                                   // mov 0 into argument 1
    mov     w3, 0                                   // mov 0 into argument 2
    mov     x8, 56                                  // mov code 56 (openat) service request
    svc     0                                       // system call
    mov     fileD, w0                               // mov result into file descriptor register

    cmp     fileD, 0                                // compare file descriptor register with 0
    b.ge    printHeader                             // if it's greater than or equal, move along with printing result

    b       done                                    // otherwise, branch to done

printHeader:
    adrp    x0, heading                             // print heading
    add     x0, x0, :lo12:heading                   // print heading
    bl      printf                                  // branch and link printf

    add     x23, fp, buf_s                          // set buffer address (offset from fp)
    //mov     multiplicand, 1                         // set initial multiplicand to 1

openOk:
    mov     w0, fileD                               // move file descriptor register to w0
    mov     x1, x23                                 // 
    mov     w2, bufsize                             // move buffer size into w2
    mov     x8, 63                                  // set service request (read)
    svc     0                                       // system call
    mov     readB, x0                               // get address of bytes that were read

    cmp     readB, bufsize                          // check if the read line is buffer size
    b.ne    eofExit                                 // branch to end of file exit

    // calculate natural log
    ldr     d0, [fp, buf_s]                         // load input number
    bl      lnx                                     // branch and link to lnx subroutine
    fmov    d25, d0                                 // mov result into x25
    //add     multiplicand, multiplicand, 1           // increment multiplicand by 1

    adrp    x0, result                              // print result
    add     x0, x0, :lo12:result                    // print result
    ldr     d0, [fp, buf_s]                         // pass current input to printf
    fmov    d1, d25                                 // pass result of ln x to printf
    bl      printf

    b       openOk                                  // read the next input from file


eofExit:                                            // method for closing the file after it ahs been read
    //close file after printing "EOF"
    adrp    x0, printEOF                            // print EOF string
    add     x0, x0, :lo12:printEOF                  // print EOF string
    bl      printf                                  // branch and link printf

    mov     w0, fileD                               // close the file
    mov     x8, 57                                  // send close service request
    svc     0                                       // system call

    b       done                                    // skip over error and terminate program

error:                                              // print generic error message for any errors that occur (file i/o, incorrect input, etc.)
    adrp    x0, printError                          // print error message
    add     x0, x0, :lo12:printError                // low 12 bits (printf)
    bl      printf                                  // branch and link printf

done:
    ldp    fp, lr, [sp], dealloc                    // deallocate memory
    ret                                             // return with exit code
