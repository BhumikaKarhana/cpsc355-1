print_cuboid:    .string "Cuboid %s origin = (%d, %d)\n\tBase width = %d Base length = %d\n\tHeight = %d\n\tVolume = %d\n\n"    // string literal for printing cuboid's origin
//print_measurements:     .string "\tBase width = %d Base length = %d\n"      // string literal for cuboid's dimensions
//print_height:           .string "\tHeight = %d\n"                           // string literal for cuboid's height
//print_volume:           .string "\tVolume = %d\n\n"                         // string literal for cuboid's volume

print_first_label:      .string "first"                                     // string literal for subroutine argument
print_second_label:     .string "second"                                    // string literal for subroutine argument

print_init_vals:        .string "Initial cuboid values:\n"                  // string literal for label
print_changed_vals:     .string "\nChanged cuboid values:\n"                // string literal for label

define(first_cuboid_base, w9)                                               // macro for register storing base address of 1st cuboid
define(second_cuboid_base, w20)                                             // macro for register storing base address of 2nd cuboid

point_x = 0                                                                 // offset for point.x from base of struct
point_y = 4                                                                 // offset for point.y from base of struct
size_point = 8                                                              // total size of struct

dimension_width = 0                                                         // offset for width from struct base
dimension_length = 4                                                        // offset for length from struct base
size_dimension = 8                                                          // total size of dimenstion struct

cuboid_origin = 0                                                           // offset for origin struct from cuboid struct
cuboid_base = cuboid_origin + size_point                                    // offset for cuboid height from struct base
cuboid_height = cuboid_base + size_dimension                                // offset for dimension struct from cuboid struct
cuboid_volume = cuboid_height + 4                                           // offset for cuboid volume from struct base
size_cuboid = size_point + size_dimension                                   // total size of cuboid struct

first_cuboid = size_cuboid                                                  // size of 1st cuboid
second_cuboid = size_cuboid                                                 // size of 2nd cuboid
alloc = -(16 + first_cuboid + second_cuboid) & -16                          // calculate size needed to allocate
dealloc = -alloc                                                            // deallocate memory size

.balign 4                                                                   // align instructions
.global main                                                                // expose "main" to linker

first_s = 16                                                                // address of first cuboid is $fp + 16
second_s = first_s + size_cuboid                                            // address of second cuboid is $fp + 16 + size of a single cuboid

fp  .req    x29                                                             // register alias for frame pointer
lr  .req    x30                                                             // register alias for link register

newCuboid:                                                                  // newCuboid() subroutine
    stp     fp, lr, [sp, alloc]!                                            // save fp and lr to stack
    mov     fp, lr                                                          // update fp to current sp

    mov     w9, 0
    str     w9, [x0, cuboid_origin + point_x]                               // store point.x value on stack
    str     w9, [x0, cuboid_origin + point_y]                               // store point.y value on stack

    mov     w21, 2
    str     w21, [x0, cuboid_base + dimension_width]                        // store cuboid width on stack
    str     w21, [x0, cuboid_base + dimension_length]                       // store cuboid length on stack

    mov     w21, 3                                                          // set w21 to 3
    str     w21, [x0, cuboid_height]                                        // use w21 to store cuboid height
    str     w10, [x0, cuboid_volume + cuboid_height + dimension_width + dimension_length]   // store c.volume on stack

end1SR:                                                                     // deallocate memory and return from newCuboid subroutine
    ldp     fp, lr, [sp], 16                                                // deallocate memory
    ret                                                                     // return

move:
    stp     fp, lr, [sp, -16]!                                              // save fp and lr to stack
    mov     fp, sp                                                          // update fp to current sp
    
    ldr     w22, [x0, cuboid_origin + point_x]                              // load cuboid point.x in w22
    ldr     w23, [x0, cuboid_origin + point_y]                              // load cuboid point.y in w23
    add     w22, w22, w1                                                    // add parameter value to current value
    add     w23, w23, w2                                                    // add parameter value to current value

    str     w22, [x0, cuboid_origin + point_x]                              // update current value with new value on stack
    str     w23, [x0, cuboid_origin + point_y]                              // update current value with new value on stack

end2SR:                                                                     // deallocate memory and return from move subroutine
    ldp     fp, lr, [sp], 16                                                // deallocate mem
    ret                                                                     // return

scale:
   ldr      w24, [x1, cuboid_base + dimension_width]                        // load current cuboid width from stack
   mul      w24, w24, w2                                                    // multiply it by parameter value given
   str      w24, [x1, cuboid_base + dimension_width]                        // store update value on stack

   ldr      w25, [x1, cuboid_base + dimension_length]                       // load current cuboid length from stack
   mul      w25, w25, w2                                                    // multiply it by parameter value given
   str      w25, [x1, cuboid_base + dimension_length]                       // store updated value on stack

   ldr      w26, [x0, cuboid_height]                                        // load current height from stack
   mul      w26, w26, w2                                                    // multiply it by given parameter value
   str      w26, [x0, cuboid_height]                                        // store updated value on stack
    
   ldr      w27, [x0, cuboid_volume + cuboid_height + dimension_width + dimension_length]   // load current volume from sack
   mul      w27, w26, w25                                                   // multiply it by given value
   mul      w27, w27, w24                                                   // multiply it by given value (in two parts because there are 3 multiplicands)
   str      w27, [x0, cuboid_volume + cuboid_height + dimension_width + dimension_length]   // store updated valued on stack

end3SR:                                                                     // deallocate memory and return from scale subroutine
    ldp     fp, lr, [sp], 16                                                // deallocate memory
    ret                                                                     // return

printCuboid:
    stp     fp, lr, [sp, -16]!                                              // save fp and lr to stack
    mov     fp, sp                                                          // update fp to current sp

    adrp    x0, print_cuboid                                                // print cuboid literal
    add     w0, w0, :lo12:print_cuboid                                      // print cuboid literal
    ldr     w2, [x0, cuboid_origin + point_x]                               // first argument is origin point x
    ldr     w3, [x0, cuboid_origin + point_y]                               // second argument is origin point y
    bl      printf                                                          // branch and link to printf

end4SR:                                                                     // deallocate memory and return from printCuboid subrotine
    ldp     fp, lr, [sp], 16                                                // deallocate
    ret                                                                     // return

equalSize:                                                                  // equalSize() subroutine
    stp     fp, lr, [sp, -16]!                                              // save fp and lr to stack
    mov     fp, sp                                                          // update fp to current sp

    ldr     x21, [x0, cuboid_base + dimension_width]                        // load first cuboid's width
    ldr     x22, [x1, cuboid_base + dimension_width]                        // load first cuboid's width dimension
    cmp     x21, x22                                                        // compare both widths
    b.ne    retFalse                                                        // return false if not equal to each other

    ldr     x21, [x0, cuboid_base + dimension_length]                       // load first cuboid's length dimension
    ldr     x22, [x1, cuboid_base + dimension_length]                       // load first cuboid's length dimension
    cmp     x21, x22                                                        // compare both lengths
    b.ne    retFalse                                                        // return false if not equal to each other

    ldr     x21, [x0, cuboid_height]                                        // load first cuboid's height
    ldr     x22, [x1, cuboid_height]                                        // load first cuboid's height
    cmp     x21, x22                                                        // compare both heights
    b.ne    retFalse                                                        // return false if not equal to each other

    mov     x0, 1                                                           // set x0 to 1 (true)
    b       end5SR                                                          // jump over return false to end of subroutine

retFalse:
    mov     x0, 0                                                           // set result to 0 (false)

end5SR:                                                                     // deallocate mem and return from equalSize subroutine (5th s.r)
    ldp     fp, lr, [sp], 16                                                // deallocate
    ret                                                                     // return

main:
    stp     fp, lr, [sp, alloc]!                                            // save fp and lr to stack allocating space defined in "alloc"
    mov     fp, sp                                                          // update fp to current sp
    
    add     x19, fp, first_s                                                // store first cuboid by storing its offset in x19
    add     x20, fp, second_s                                               // store second cuboid by storing its offset in x20
    mov     x0, x19                                                         // argument to subroutine is address of first cuboid
    bl      newCuboid                                                       // branch and link newCuboid

    mov     x0, x20                                                         // argument to subroutine is address of second cuboid
    bl      newCuboid                                                       // branch and link newCuboid

    adrp    x0, print_init_vals                                             // print label
    add     w0, w0, :lo12:print_init_vals                                   // print label
    bl      printf                                                          // print label

    mov     x0, x19                                                         // pass first cuboid address as argument
    adrp    x1, print_first_label                                           // printf argument
    add     w1, w1, :lo12:print_first_label                                 // argument is "first" string literal
    bl      printCuboid                                                     // branch and link printCuboid

    mov     x0, x20                                                         // print second cuboid
    adrp    x1, print_second_label                                          // argument is "second" string literal
    add     w1, w1, :lo12:print_second_label                                // printf argument
    bl      printCuboid                                                     // branch and link printCuboid to print second cuboid

    mov     x0, x19                                                         // pass 1st cuboid address as argument
    mov     x1, x20                                                         // pass 2nd cuboid address as argument
    bl      equalSize                                                       // branch and link equalSize()
    mov     x0, x21                                                         // use equalSize() result

    cmp     x21, xzr                                                        // check if result is 0
    b.eq    innerIf                                                         // branch to inside of if statement if equal

    b       printChanged                                                    // skip over innerIf

innerIf:
    mov     x0, x19                                                         // pass address of 1st cuboid as argument
    mov     w1, 3                                                           // argument to move subroutine
    mov     w2, -6                                                          // argument to move subroutine
    bl      move                                                            // branch and link move()

    mov     x0, x20                                                         // pass address of 2nd cuboid as argument
    mov     w1, 4                                                           // scale factor argument to scale subroutine
    bl      scale                                                           // branch and link scale()

printChanged:
    adrp    x0, print_changed_vals                                          // print label
    add     w0, w0, :lo12:print_changed_vals                                // print label
    bl      printf                                                          // print label
 
    mov     x0, x19                                                         // pass address of 1st cuboid as argument
    adrp    x1, print_first_label                                           // argument is "first" literal
    add     w1, w1, :lo12:print_first_label                                 // printf argument
    bl      printCuboid                                                     // branch and link printCuboid()
 
    mov     x0, x20                                                         // pass address of 2nd cuboid as argument
    adrp    x1, print_second_label                                          // argument is "second" literal (for %s)
    add     w1, w1, :lo12:print_second_label                                // printf argument
    bl      printCuboid                                                     // branch and link printCuboid

done:
    mov     w0, 0                                                           // restore w0
    ldp     fp, lr, [sp], dealloc                                           // deallocate memory
    ret                                                                     // return with exit code
