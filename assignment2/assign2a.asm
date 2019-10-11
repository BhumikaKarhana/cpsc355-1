outputInfo: .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"
ouputAnswer: .string "product = 0x%08x  multiplier = 0x%08x\n"
output64Answer: .string "64 bit result = 0x%016lx (%ld)\n"

define(FALSE, 0)                        // define boolean macro FALSE
define(TRUE, 1)                         // define boolean macro TRUE

.global main

.balign 4

// OUTPUT: 
/*
    multiplier = 0x00000046 (70)  multiplicand = 0xfefefefe (-16843010)

    product = 0xffffffff  multiplier = 0xb9b9b974

    64 bit result = 0xffffffffb9b9b974 (-1179010700)
*/

main:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // defining macros
    // 32-bit integers
    define(multiplier, w19)             // "multiplier" set to the 32 bit register w19
    define(multiplicand, w20)            // "multiplicand" set to the 32 bit register w20
    define(product, w21)                // "product" set to the 32 bit register w21
    define(i, w22)                      // "i" set to the 32 bit register w22
    define(negative, w23)               // "negative" set to the 32 bit register w23
    define(temp3, w24)                  // "temp3" is a temporary 32 bit register
    // long ints (64-bit)
    define(result, x24)                 // "result" set to the 64 bit register x24
    define(temp1, x25)                  // "temp1" set to the 64 bit register x25
    define(temp2, x26)                  // "temp2" set to the 64 bit register x26

    movz    multiplicand, 0xFEFE, lsl 16        // assign first half of hexadecimal value to multiplicand and left shift by 16 bits
    mov     temp3, 0xFEFE                       // move the rest of the number in a temp register
    add     multiplicand, multiplicand, temp3   // add the temp register and the first half to get the whole number stored in multiplicand

    mov     multiplier, 70              // assign integer value to multiplier
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

    b       step1                       // branch to the first step of the algorithm, stepping over the else label

else: 
    mov     negative, 1                 // move 1 (true) into negative register if multiplier is <= to 0

step1:




    mov     x0, 0

    ldp     x29, x30, [sp], 16
    ret


#include <stdio.h>
#define FALSE 0
#define TRUE  1
#int main()
#{
#int multiplier, multiplicand, product, i, negative;
#long int result, temp1, temp2;
#Initialize variables
#multiplicand = -16843010;
#multiplier = 70;
#product = 0;
# Print out initial values of variables
#printf("multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n",
# multiplier, multiplier, multiplicand, multiplicand);
# Determine if multiplier is negative
#negative = multiplier < 0 ? TRUE : FALSE;
# Do repeated add and shift
#for (i = 0; i < 32; i++) {
#if (multiplier & 0x1) {
#product = product + multiplicand;
#}
# Arithmetic shift right the combined product and multiplier
#multiplier = multiplier >> 1;
#if (product & 0x1) {
#multiplier = multiplier | 0x80000000;
#} else {
#multiplier = multiplier & 0x7FFFFFFF;
#}
#product = product >> 1;
#}
# Adjust product register if multiplier is negative
#if (negative) {
#product = product - multiplicand;
#}
# Print out product and multiplier
#printf("product = 0x%08x  multiplier = 0x%08x\n",
# product, multiplier);
# Combine product and multiplier together
#temp1 = (long int)product & 0xFFFFFFFF;
#temp1 = temp1 << 32;
#temp2 = (long int)multiplier & 0xFFFFFFFF;
#result = temp1 + temp2;
# Print out 64-bit result
#printf("64-bit result = 0x%016lx (%ld)\n", result, result);
#return 0;
#}

