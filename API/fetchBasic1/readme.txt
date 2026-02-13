localhost:3000/async.html

By using the async fetch, the front end is not blocked waiting for a lengthy API to return
Demo this by running a lengthy API then setting the front end counter going

That's fine for the front end, but if the backend is blocking, the front end is responsive 
but we can't call another API as the server thread is blocked so we need to make lengthy 
operations on the server async as well - e.g. reading a database

This can be demonstrated by calling the non-blocking API which will take several seconds but then 
clicking on another link to show server is not blocked as it is still responsive

Refresh the page to clear results