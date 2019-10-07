// define macros for commonly used registers




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
	mov x20, -10
    // start the current y at 0 and add values to it while doing calculations
	mov x21, 0
    // start the current max at a really small value so it gets updated at the first iteration
	mov x22, -500
    
    // start the first iteration of the loop
	b test

// define macros for the individual x terms in the polynomial




// define macros for temporary registers



test:
    // loop test, stops the excution of the loop
	// domain: {x | -10 <= x <= 4}
	// check if current x is = 4
	// if so, print final result which then branches to done
	cmp x20, 4
	b.gt done

start:
    // BEGIN LOOP BODY

    // reset temporary registers before doing calculations
    mov x21, 0
    mov x23, 0
    mov x24, 0
    mov x23, 0
	mov x28, 0

    // 11x
    mov x28, 11
    // use x25 and x28 to calculate 11x
    mul x25, x20, x28

    // -22x^2
    mov x24, -22
    // use x23 to store x^2
    mul x23, x20, x20
    // multiply and add the temps with the x values for this term (using madd instruction) 
    madd x24, x24, x23, x25

    // reset temporary regiters used in previous calculations
    mov x23, 0
    mov x28, 0

	// -2x^3
	mov x23, -2
    // store x^2 in x28
	mul x28, x20, x20
    // combine all the x terms to get the y value without the constant 57
	mul x28, x28, x20
    // add x terms together and store them in x23 using madd instruvction (which 57 will be added to later)
    madd x23, x23, x28, x24

    // finally add constant 57 to the value of y, after all the calculations involving x
    add x23, x23, 57
    
    // make current max as global max if it is greater than it
    cmp x23, x22
    b.gt newMaximum
    // branch to end of loop where everything gets printed
    b endLoop

endLoop: 
    // print current x,y values
    adrp x0, outputXY
    add x0, x0, :lo12:outputXY
    // value for first %d is the x value and the y value for the second %d
    mov x1, x20
    mov x2, x23
    // branch to and link printf
    bl printf
    // increment the current x value (used as a loop counter)
    add x20, x20, 1

	// print current maximum value so far
	adrp x0, outputMax
    add x0, x0, :lo12:outputMax
    // value for %d in strinf literal is x22
    mov x1, x22
    bl printf
    // move to the next iteration of the loop after printing to stdout
    b test

newMaximum:
    // set the new maximum and branch to the end of the loop (printing to stdout)
    mov x22, x23
    b endLoop

printResult:
    // printing final result, the maximum value of the polynomial
    adrp x0, result
    add x0, x0, :lo12:result
    // value for %d in string literal = x22
    mov x1, x22
    bl printf
    b done

done:
	// exit program with exit code 0
	mov x0, 0
    // restore state and return
	ldp x29, x30, [sp], 16
	ret
