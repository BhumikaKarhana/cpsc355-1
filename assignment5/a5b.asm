.data                                                           // pseudo op for data section (declare the memory region)
define(monthArr, x27)                                           // store address of months array
define(suffixArr, x28)                                          // store address of suffix array

.text                                                           // pseudo op for (default) text section
result: .string "%s %d%s, %d\n"                                 // define string literal for printing result if input is valid
jan_m:  .string "January"                                       // define string literal 
feb_m:  .string "Febuary"                                       // define string literal
mar_m:  .string "March"                                         // define string literal
apr_m:  .string "April"                                         // define string literal
may_m:  .string "May"                                           // define string literal
jun_m:  .string "June"                                          // define string literal
jul_m:  .string "July"                                          // define string literal
aug_m:  .string "August"                                        // define string literal
sep_m:  .string "September"                                     // define string literal
oct_m:  .string "October"                                       // define string literal
nov_m:  .string "November"                                      // define string literal
dec_m:  .string "December"                                      // define string literal
st:     .string "st"                                            // define string literal
nd:     .string "nd"                                            // define string literal
rd:     .string "rd"                                            // define string literal
th:     .string "th"                                            // define string literal

invalidError:   .string "usage: a5b mm dd yyyy\n"               //  define string literal for error message

.balign 8                                                       // doubleword alignment
// define months in order (external array of pointer)
months:         .dword  jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
// define suffixes for numbers 1 - 31 (days in month)
suffix:         .dword  st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st

argc    .req    w23                                             // alias for argc (number of command line arguments)
argv    .req    x24                                             // alias for argv (argument vector, stores values of provided arguments)

define(month, w19)                                              // define macro for month (result register)
define(day, w20)                                                // define macro for day (result register)
define(year, x21)                                               // define macro for year (result register)

.balign 4                                                       // quadword instruction alignment
.global main                                                    // expose main to linker

fp      .req    x29                                             // register alias for frame pointer
lr      .req    x30                                             // register alias to link register

main:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update current sp to fp

    mov         argc, w0                                        // mov given argc into permanent register defined above
    mov         argv, x1                                        // mov given argv into permanent register defined above
    // mm dd yyy
    mov         w25, 1                                          // month is the 1st argument
    mov         w26, 2                                          // day is the 2nd argument
    mov         w27, 3                                          // year is the 3rd argumebt

    // error handling for input arguments
    cmp         argc, 4                                         // if the amount of inputs is != 4
    b.ne        error                                           // branch to error and end program

    ldr         x0, [argv, w25, SXTW 3]                         // get month from month array
    bl          atoi                                            // parse int from string
    mov         month, w0                                       // store result in month register

    cmp         month, 12                                       // check if input month is > 12
    b.gt        error                                           // branch to error and end program
    cmp         month, 0                                        // check if input month is negative or 0
    b.le        error                                           // branch to error and end program

    ldr         x0, [argv, w26, SXTW 3]                         // get day from arguments provided
    bl          atoi                                            // parse int from string
    mov         day, w0                                         // store result in day register

    cmp         day, 31                                         // check if day is > 31
    b.gt        error                                           // branch to error and end program
    cmp         day, 0                                          // check if input day is negative or 0
    b.le        error                                           // branch to error and end program

    ldr         x0, [argv, w27, SXTW 3]                         // get year from arguments provided
    bl          atoi                                            // parse int from string
    sxtw        x0, w0                                          // sign extend result
    mov         year, x0                                        // store sign extended result in year register

    cmp         year, 0                                         // check if input year is negative
    b.lt        error                                           // branch to error and end program
    // end error handling (for inputs)

    adrp        monthArr, months                                // get correct month using monthArr address
    add         monthArr, monthArr, :lo12:months                // low 12 bits of address 
    sub         month, month, 1                                 // subtract 1 from input month (get array index)

    adrp        suffixArr, suffix                               // get correct suffix usinf suffixArr address
    add         suffixArr, suffixArr, :lo12:suffix              // low 12 bits of address

    adrp        x0, result                                      // printf result
    add         x0, x0, :lo12:result                            // printf result
    ldr         x1, [monthArr, month, SXTW 3]                   // pass month name as first argument to printf
    mov         w2, day                                         // pass day as second argument to printf
    sub         day, day, 1                                     // subtract 1 from day (to get suffix array index)
    ldr         x3, [suffixArr, day, SXTW 3]                    // pass correct suffix as third argument to printf
    mov         x4, year                                        // pass year as fourth argument to printf
    bl          printf                                          // branch and link printf

    b           done                                            // branch to done if no errors occured

error:
    adrp        x0, invalidError                                // printf invalidError string
    add         x0, x0, :lo12:invalidError                      // printf
    bl          printf                                          // printf

done:                                                           // terminate program if no errors occured
    ldp         fp, lr, [sp], 16                                // deallocate memory
    ret                                                         // return with exit code


