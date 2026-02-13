// setTimeout function signature:
// setTimeout(callback, delay, optionalArg1, OptionalArgn). If used, optional args are passed to the callback

// Example passing a named function to setTimeout as a callback
function callMeLater() {
  console.log(`This is the callMeLater named function`)
}

setTimeout(callMeLater, 1000) 


// Passing an anonymous callback and a time to setTimeout
setTimeout(function() {
    console.log(`This is an anonymous function`)
  }, 1000) 

// Pass callback function as an arrow function - popular
setTimeout(()=> console.log(`This is an arrow function`), 1000) 

console.log(`This message will be output first because the other functions are delayed`)