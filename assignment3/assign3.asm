sortedLabel:        .string "\nSorted array:\n"     // printf string literal for printing label before printing sorted array elements
printElement:       .string "V[%d]: %d\n"           // printf string literal for printing array elements (sorted and unsorted)

.balign 4
.global main
 
i_size  =  4                                        // size of each array element
size    =  50                                       // number of elements in array
v_size  =  size * i_size                            // total size of array in memory
alloc   =  -(16 + 16 + v_size) & -16                // pre-increment value for the stack pointer (used in main "prologue")
dealloc =  -alloc                                   // post-increment value for the stack pointer (used in main "epilogue")

i_s   = 16                                          // stack offset for i
j_s   = 20                                          // stack offset for j
min_s = 24                                          // stack offset for min variable



main:
    stp     x29, x30, [sp, alloc]!
    mov     x29, sp



done:
   mov      x0, 0
   ldp      x29, x30, [sp], dealloc
   ret
