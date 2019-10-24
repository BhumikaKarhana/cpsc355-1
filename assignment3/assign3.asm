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

// assembler equates for offsets for i, j, and min
i_s   = 16                                          // stack offset for i
j_s   = 20                                          // stack offset for j
min_s = 24                                          // stack offset for min variable
ia_s  = 28

define(index, w19)                                  // macro for register storing i
define(j_index, w20)                                // macro for register storing j
define(base, x21)                                   // macro for register storing array base address 

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

define(randomNum, w22)                              // macro used to perform ops on the result of rand

loop1:
    bl      rand                                    // call library function rand()
    ldr     index, [fp, i_s]                        // 
    and     randomNum, w0, 0xFF                     // and operation on random number stored in w0 and 0xFF (255)
    str     randomNum, [base, index, SXTW 2]        // store result in array at current index

    // print string literal to standard output 
    adrp    x0, element                             
    add     x0, x0, :lo12:element                   
    mov     w1, index                               // first argument of printf is the index
    mov     w2, randomNum                           // second argument of printf is the random number itself
    bl      printf                                  // branch and link printf
    
    add     index, index, 1                         // increment index
    str     index, [fp, i_s]                        // store new index on stack

loop1Test:
    cmp     index, size                             // compare index to array size
    b.lt    loop1                                   // check if index < 50 and if so, loop again
    // end of loop1 // 

    mov     index, 0
    str     index, [fp, i_s]
    //b       loop2Test


printLabel:                                         // print a label before printing sorted elements
    // print string literal to standard output 
    adrp    x0, label
    add     x0, x0, :lo12:label
    bl      printf                                  // branch and link printf

loop2:                                              // second for loop

loop3:                                              // inner for loop in loop2

loop2Test:

done:
   mov      x0, 0                                   // set zero register
   ldp      fp, lr, [sp], dealloc                   // deallocate stack memory
   ret                                              // return with exit code
