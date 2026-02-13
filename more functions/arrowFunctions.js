// Traditional function
function exp(x,y) {
  let result = 1 // in case y=0
  for (let i=0; i < y; i++) {
    result *= x
  }
  return result
}

// Using an anonymous function assigned to a constant
const exp1 = function(x,y) {
  let result = 1; // in case y=0
  for (let i=0; i < y; i++) {
    result *= x
  }
  return result
}


// Using an arrow anonymous function with 2 parameters and a block
const exp2 = (x,y) => {
  let result = 1; // in case y=0
  for (let i=0; i < y; i++) {
    result *= x
  }
  return result
}

// Calling all three is the same
console.log(`2^16 is: ${exp(2,16)}`) 
console.log(`2^16 is: ${exp1(2,16)}`)
console.log(`2^16 is: ${exp2(2,16)}`)


// Arrow fn with no params and no block. Return is implied
const msg = () => "This is a message"
console.log(`The message is: ${msg()}`)


// Arrow fn with 1 parameter and no block. x is a param, x*x is returned
const square = x => x*x
console.log(`9 squared = ${square(9)}`)
