outputInfo: .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"      // define string literals for first printf
outputAnswer: .string "product = 0x%08x  multiplier = 0x%08x\n"                     // define string literal for second print
output64Answer: .string "64 bit result = 0x%016lx (%ld)\n"                          // define string literal for last printf

.global main                            // make main visible to linker

.balign 4                               // align instructions

main:
    stp     x29, x30, [sp, -16]!        // main "prologue"
    mov     x29, sp                     // main "prologue"

    // defining macros
    // 32-bit integers
    define(multiplier, w19)             // "multiplier" set to the 32 bit register w19
    define(multiplicand, w20)           // "multiplicand" set to the 32 bit register w20
    define(product, w21)                // "product" set to the 32 bit register w21
    define(i, w22)                      // "i" set to the 32 bit register w22
    define(negative, w23)               // "negative" set to the 32 bit register w23
    define(temp3, w24)                  // "temp3" is a temporary 32 bit register
    // long ints (64-bit)
    define(result, x24)                 // "result" set to the 64 bit register x24
    define(temp1, x25)                  // "temp1" set to the 64 bit register x25
    define(temp2, x26)                  // "temp2" set to the 64 bit register x26
    

    movz    multiplicand, 0x1F1F, lsl 16        // assign first half of hexadecimal value to multiplicand and left shift by 16 bits
    mov     temp3, 0x1F1F                       // move the rest of the number in a temp register
    add     multiplicand, multiplicand, temp3   // add the temp register and the first half to get the whole number stored in multiplicand

    mov     multiplier, 200              // assign integer value to multiplier
    mov     product, 0                  // assign integer value to product

    // print information about the variables that exist right now
    adrp    x0, outputInfo
    add     x0, x0, :lo12:outputInfo
    mov     w1, multiplier              // first argument in printf is the multiplier (in hex)
    mov     w2, multiplier              // next printf argument is the multiplier (in decimal)
    mov     w3, multiplicand            // next argument in printf is the multiplicand (in hex)
    mov     w4, multiplicand            // last argument in printf is the multiplicand (in decimal)
    bl      printf                      // branch to and link printf

    cmp     multiplier, wzr             // compare multiplier with the zero register
    b.le    else                        // branch to the else statement if multiplier is less than or equal to 0
    mov     negative, 0                 // move 0 (false) into negative register if multiplier is > 0

    b       step1                       // branch to the first step of the algorithm (for loop), stepping over the else label

else: 
    mov     negative, 1                 // move 1 (true) into negative register if multiplier is <= to 0

step1:
    mov     i, 0                        // set index macro to 0
    b       test1                       // branch to loop test 1 (and operator)

firstLoop:
    and     temp3, multiplier, 0x1              // and operation, store result in temporary 32 bit register
    cmp     temp3, 0                            // compare temp3 with 0 and see if it equals 0
    b.eq    afterIf                             // branch to afterIf (the code after the inner if statement)

    add     product, product, multiplicand      // repeatedly add the multiplicand to the product

afterIf: 
    asr     multiplier, multiplier, 1           // arithmetic shift right on the multiplier
    and     temp3, product, 0x1                 // and operation on 0x1 and the product value
    cmp     temp3, 0x1                          // compare temp3 and 0x1
    b.ne    innerElse                           // if temp3 is not equal to 0x1, branch to the else statemnt (if statement test fails)
    orr     multiplier, multiplier, 0x80000000  // logical or operation on multiplier and -2147483648 in hex
    b       finalLoopStep                       // branch to the rest of the loop

innerElse:                                      // inner else statement which executes if and product, 0x1 statement test fails
    and     multiplier, multiplier, 0x7FFFFFFF  // logical and operator on multiplier and 2147483647 in hex

finalLoopStep:
    asr     product, product, 1                 // arithmetic shift right on product by 1
    
    add     i, i, 1                             // increment index variable

test1:
    cmp     i, 32                               // loop test passes while i is < 32
    b.lt    firstLoop                           // branch to the loop body if test passes 

    cmp     negative, 0                         // compare negative value to 0
    b.eq    printResult                         // if negative is false, branch straight to the result

    sub     product, product, multiplicand      // else, subtract multiplicand and store it in product

printResult:
    // print the product and multiplier (second print statement)
    adrp    x0, outputAnswer
    add     x0, x0, :lo12:outputAnswer
    mov     w1, product                 // first argument in printf is the multiplier (in hex)
    mov     w2, multiplier              // next printf argument is the multiplier (in decimal)
    bl      printf                      // branch to and link printf

    sxtw    temp1, product              // extend product register to 64 bits
    and     temp1, temp1, 0xFFFFFFFF    // 
    lsl     temp1, temp1, 32            //

    sxtw    temp2, multiplier           // extend multiplier to 64 bits
    and     temp2, temp2, 0xFFFFFFFF    // 
    add     result, temp1, temp2        //
    // print the product and multiplier (second print statement)
    adrp    x0, output64Answer
    add     x0, x0, :lo12:output64Answer
    mov     x1, result                   // first argument in printf is the multiplier (in hex)
    mov     x2, result                   // next printf argument is the multiplier (in decimal)
    bl      printf                      // branch to and link printf

done:
    mov     x0, 0                       // move zero to zero register
                
    ldp     x29, x30, [sp], 16          // main "epilogue"
    ret                                 // return with exit code

