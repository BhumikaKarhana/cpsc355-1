// Abdullah Khan - UCID 30074457

// string literals for printf
label:      .string "\nSorted array:\n"             // label before printing sorted array elements
element:    .string "V[%d]: %d\n"                   // print array elements (same for sorted and unsorted arrays)

.balign 4                                           // align instructions
.global main                                        // expose main to linker

// assembler equates for array and alloc/dealloc
i_size  =  4                                        // size of each array element
size    =  50                                       // 50 elements in array
v_size  =  size * i_size                            // total size of all array elements
alloc   =  -(16 + 16 + v_size) & -16                // pre-increment value for the stack pointer (used in main "prologue")
dealloc =  -alloc                                   // post-increment value for the stack pointer (used in main "epilogue")

// assembler equates for offsets for i, j, min, and the array base
i_s   = 16                                          // stack offset for i
j_s   = 20                                          // stack offset for j
min_s = 24                                          // stack offset for min variable
ia_s  = 28                                          // stack offset for array base

define(index, w19)                                  // macro for register storing i
define(j_index, w20)                                // macro for register storing j
define(min, w21)                                    // macro for register storing min 
define(base, x28)                                   // macro for register storing array base address
define(temp, w26)

fp          .req x29                                // frame pointer's register alias
lr          .req x30                                // link register's alias

main:
    stp     fp, lr, [sp, alloc]!                    // store fp and lr on the stack and allocate space for the variables created above
    mov     fp, sp                                  // update frame pointer to the current stack pointer

    mov     base, fp                                // set the base address for array
    add     base, base, i_s                         // array base location calculated by adding its offset to fp

    mov     index, 0                                // initialize index variable to 0 in the beginning
    str     index, [fp, i_s]                        // store index on stack

    b       loop1Test                               // branch to loop1's test

define(randomNum, w22)                              // macro used to perform ops on the result of the rand function

loop1:                                              // first for-loop (to generate random array)
    bl      rand                                    // call library function rand()
    ldr     index, [fp, i_s]                        // load current index from stack
    and     randomNum, w0, 0xFF                     // and operation on random number stored in w0 and 0xFF (255)
    str     randomNum, [base, index, SXTW 2]        // store result in array at current index


    ldr    randomNum, [base, index, SXTW 2]              //  
    // print string literal to standard output 
    adrp    x0, element                             
    add     x0, x0, :lo12:element                   
    mov     w1, index                               // first argument of printf is the index
    mov     w2, randomNum                                // second argument of printf is the random number itself
    bl      printf                                  // branch and link printf
    
    mov     temp, 0
    add     index, index, 1                         // increment index
    str     index, [fp, i_s]                        // store new index on stack

loop1Test:
    cmp     index, size                             // compare index i to array size
    b.lt    loop1                                   // check if index < 50 and if so, iterate again
    // end of loop1 // 

printLabel:                                         // print a label before printing sorted elements
    // print string literal to standard output 
    adrp    x0, label
    add     x0, x0, :lo12:label
    bl      printf                                  // branch and link printf

startLoop2:
    mov     index, 0                                // reassign index variable to 0
    str     index, [fp, i_s]                        // store new index on stack
    b       loop2Test                               // branch to optimized loop test

loop2:                                              // second for-loop (for selection sort)
    mov     min, index                              // set min = i
    str     min, [fp, min_s]                        // store min on stack

    ldr     j_index, [fp, j_s]                        // load current index from stack
    ldr     index, [fp, i_s]                        // load current index from stack
    mov     j_index, index                          // set j = i
    add     j_index, j_index, 1                     // increment j (for loop condition)
    str     j_index, [fp, j_s]                      // store j on stack

    b       loop3Test                               // branch to inner loop test

define(vMin, w23)                                   // register to store V[min] (used for comparison in selection sort)
define(vJ, w24)                                     // register to store V[j] (used for comparison in selection sort)

loop3:                                              // inner for-loop in loop2
//    mov     vMin, 0
//    mov     vJ, 0
    ldr     min, [fp, min_s]                        // load min from stack
    ldr     j_index, [fp, j_s]                        // load current index from stack

    //ldr     vJ, [base, j_index, SXTW 2]
    //ldr     vMin, [base, min, SXTW 2]
    ldr     vJ,[base, j_index, SXTW 2]              // load V[j] from array on stack
    ldr     vMin, [base, min, SXTW 2]               // load V[min] from array on stack

    cmp     vMin, vJ                                // compare V[j] to V[min]
    b.lt    continue                                // skip to continue

    mov     min, j_index
    str     j_index, [fp, min_s]                    // store j on stack in min's position (min = j)

continue:
    //add     index, index, 1
    //str     index, [fp, i_s]                        // store new index on stack
    //mov     min, j_index
    // ldr     j_index, [fp, j_s]                        // load current index from stack
    add     j_index, j_index, 1
    str     j_index, [fp, j_s]                      // store j on stack

loop3Test:                                          // inner for-loop test
    //ldr     j_index, [fp, j_s]                      // load current index from stack
    cmp     j_index, size                           // compare j to array size
    b.lt    loop3                                   // check if index < 50 and if so, iterate again

    ldr     min, [fp, min_s]                        // load min from stack
    ldr     vJ, [base, j_index, SXTW 2]             // load V[j] from array on stack
    ldr     vMin, [base, min, SXTW 2]             // load V[j] from array on stack

    ldr     index, [fp, i_s]                        // load current index from stack
    ldr     w27, [base, index ,SXTW 2]               // v[i]
    //mov     temp, vMin
    //ldr     w25, [base, index, SXTW 2]

    mov     temp, w27
    mov     w27, vMin
    mov     vMin, temp
    //mov     vMin, w25
    //mov     w25, temp

    str     vMin, [base, min, SXTW 2]
    str     w27, [base, index, SXTW 2]

    // print string literal to standard output 
    adrp    x0, element
    add     x0, x0, :lo12:element
    mov     w0, index
    mov     w1, w27
    bl      printf                                  // branch and link printf
    
    ldr     index, [fp, i_s]                        // load current index from stack
    add     index, index, 1
    str     index, [fp, i_s]                        // store new index on stack

loop2Test:                                          // optimized loop2 test
    cmp     index, size                             // compare index i to array size
    b.lt    loop2                                   // check if index < 50 and if so, iterate again

done:
   mov      x0, 0                                   // set zero register
   ldp      fp, lr, [sp], dealloc                   // deallocate stack memory
   ret                                              // return with exit code




   //x/50wd $address it'll display 50 word sized integers from memory
