namedFn() // Function can be called before its declaration because functions and variables are hoisted


function namedFn() {
  console.log(`This is a named function`)
}

namedFn() // And after

//assignedFn() // Can't be called here because although assignedFn can be hoisted, the assignment can't
// The following is an assignment of an anonymous function
// This can be used where you need to assign the variable to a different function
// When it is called, it will call the other function. It's effectively a function pointer / reference
const assignedFn = function() {
  console.log(`This is an assigned function`)
}

assignedFn() // Can be called here

