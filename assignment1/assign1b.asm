// define macros for commonly used registers
define(current_x, x20)
define(current_y, x21)
define(current_max, x22)

// assign string literals for later use when printing to stdout
// outputXY prints the current x and y on each iteration, outputMax prints the current maximum
outputXY:	.string "current X = %d, Y = %d \n"
outputMax:	.string "  maximum: %d \n"
// result is printed at the end of the program to print the global max that was found
result: .string "\nthe global max is %d\n"

// ensure instructions are properly aligned
// make "main" visible to linker
.balign 4
.global main

main:
    // save state
	stp x29, x30, [sp, -16]!
	mov x29, sp

	// set the initial values for the variables
    // set starting x to -10 (it goes to -4)
	mov current_x, -10
    // start the current y at 0 and add values to it while doing calculations
	mov current_y, 0
    // start the current max at a really small value so it gets updated at the first iteration
	mov current_max, -500
    
    // start the first iteration of the loop
	b test

// define macros for the individual x terms in the polynomial
define(x_term1, x24)
define(x_term2, x23)
define(x_term3, x28)

// define macros for temporary registers
define(temp, x23)
define(temp2, x25)

test:
	// domain: {x | -10 <= x <= 4}
	// check if current x is = 4
	// if so, print final result which then branches to done
	cmp current_x, 4
	b.gt printResult
    
    // BEGIN LOOP BODY

    // reset temporary registers before doing calculations
    mov current_y, 0
    mov temp, 0
    mov x_term1, 0
    mov x_term2, 0
	mov x_term3, 0

    // 11x
    mov x_term3, 11
    // use temp2 and x_term3 to calculate 11x
    mul temp2, current_x, x_term3

    // -22x^2
    mov x_term1, -22
    // use temp to store x^2
    mul temp, current_x, current_x
    // multiply and add the temps with the x values for this term
    mul x_term1, x_term1, temp
    add x_term1, x_term1, temp2

    // reset temporary regiters used in previous calculations
    mov x_term2, 0
    mov x_term3, 0

	// -2x^3
	mov x_term2, -2
    // store x^2 in x_term3
	mul x_term3, current_x, current_x
    // combine all the x terms to get the y value without the constant 57
	mul x_term3, x_term3, current_x
    mul x_term2, x_term2, x_term3
    // add x terms together and store them in x_term2 (which 57 will be added to later)
    add x_term2, x_term2, x_term1

    // add constant 57 to final value of y, after all the calculatios involving x
    add x_term2, x_term2, 57
    
    // make current max as global max if it is greater than it
    cmp x_term2, current_max
    b.gt newMaximum
    // branch to end of loop where everything gets printed
    b endLoop

endLoop: 
    // print current x,y values
    adrp x0, outputXY
    add x0, x0, :lo12:outputXY
    // value for first %d is the x value and the y value for the second %d
    mov x1, current_x
    mov x2, x_term2
    // branch to and link printf
    bl printf
    // increment the current x value (used as a loop counter)
    add current_x, current_x, 1

	// print current maximum value so far
	adrp x0, outputMax
    add x0, x0, :lo12:outputMax
    // value for %d in strinf literal is current_max
    mov x1, current_max
    bl printf
    // move to the next iteration of the loop after printing to stdout
    b test

newMaximum:
    // set the new maximum and branch to the end of the loop (printing to stdout)
    mov current_max, x_term2
    b endLoop

printResult:
    // printing final result, the maximum value of the polynomial
    adrp x0, result
    add x0, x0, :lo12:result
    // value for %d in string literal = current_max
    mov x1, current_max
    bl printf
    b done

done:
	// exit program with exit code 0
	mov x0, 0
    // restore state and return
	ldp x29, x30, [sp], 16
	ret
