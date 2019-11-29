.data                                                           // pseudo op for data section (declare the memory region)
define(monthArr, x22)                                           // store address of months array
define(suffixArr, x23)                                          // store address of suffix array

.text                                                           // pseudo op for (default) text section
result: .string "%s %d%s, %d\n"                                 // define string literal for printing result if input is valid
jan:    .string "January"                                       // define string literal 
feb:    .string "Febuary"                                       // define string literal
mar:    .string "March"                                         // define string literal
apr:    .string "April"                                         // define string literal
may:    .string "May"                                           // define string literal
jun:    .string "June"                                          // define string literal
jul:    .string "July"                                          // define string literal
aug:    .string "August"                                        // define string literal
sep:    .string "September"                                     // define string literal
oct:    .string "October"                                       // define string literal
nov:    .string "November"                                      // define string literal
dec:    .string "December"                                      // define string literal
st:     .string "st"                                            // define string literal
nd:     .string "nd"                                            // define string literal
rd:     .string "rd"                                            // define string literal
th:     .string "th"                                            // define string literal

invalidError:   .string "usage: a5b mm dd yyyy\n"               //  define string literal for error message

// define months in order (external array of pointer)
months:         .dword  jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
// define suffixes for numbers 1 - 31 (days in month)
suffix:         .dword  st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st

argc    .req    w23                                             // alias for argc (number of command line arguments)
argv    .req    x24                                             // alias for argv (argument vector, stores values of provided arguments)

define(month, w19)
define(day, w20)
define(year, x21)

.balign 4                                                       // quadword instruction alignment
.global main                                                    // expose main to linker

fp      .req    x29                                             // register alias for frame pointer
lr      .req    x30                                             // register alias to link register

main:
    stp         fp, lr, [sp, -16]!                              // allocate memory
    mov         fp, sp                                          // update current sp to fp

done:                                                           // terminate program if no errors occured
    ldp         fp, lr, [sp], 16                                // deallocate memory
    ret                                                         // return with exit code

error:
    adrp        x0, invalidError                                // printf invalidError string
    add         x0, x0, :lo12:invalidError                      // printf
    bl          printf                                          // printf
    b           done                                            // branch to done after displaying error
