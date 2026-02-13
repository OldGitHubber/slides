// fn is a callback function. The called function can execute different operations on the data
// This is polymorphism without OOP
function maths(a,b,fn) {
  console.log(`Demo a callback function. We don't know what fn will do but it needs two params`)
  let result = fn(a,b)
  console.log(`fn(a,b)=${result}\n`)
}

// Standard function declaration
function add(a,b) {
  return a+b
}

maths(3,5,add)



// Anonymous function declaration
const subtract = function(a,b) {
  return a-b
}

maths(3,5,subtract)



// Arrow function declaration
const multiply = (a,b) => a*b

maths(3,5,multiply)



// Anonymous function passed as an arrow function. Popular
maths(3,5, (a,b)=>a/b)