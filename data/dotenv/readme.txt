Start a shell. It will inherit system vars. Try: 
Windows: Get-ChildItem Env: | Sort-Object 
Bash: env | Sort

With or without dotenv, we can read the shell env vars using process.env
Run the app in the debugger but comment out the dotenv. Note it starts on port 5000
Use localhost:5000/all to see what env vars we have inherited from the shell
Use localhost:5000/app to see that the app is using fixed constants not env vars

With or without dotenv, we can read the shell env vars using process.env
The dotenv config function will read .env and write them to the process env

Set the port number in the terminal to 3000, restart the app and see what happens
It still sees 5000. This is because the debugger starts its own shell so can't see that env var
Start the app from the command line with node app.js and see what happens
It starts on 3000 because process.env can see it so it reads it 
This is useful for passing values to the app at runtime
Leave the debugger running and the app at 3000, open another shell and run at 2000
Try local host on all three ports

Set an env var in one of the shells $env:TONY="Mr Nice Guy" (need to stop the app ^C to enter it)
Try the 3 endpoints again and explain why you only see this in one of them

Uncomment the dotenv and run the app in the debugger. If your other app are still running you will see you can't have 2 apps on the same port
Note the app is now running on 3000 as it read this from the .env and wrote it to the process env to be read by process.env
localhost:3000/app will show the .env values are being used in the app

Stop the app in the debugger and set the APP_PASSWORD in the terminal to mypass or whatever
Start the app at the terminal
Access the API endpoint for app and see that the .env password has been overridden
This way we can modify the configuration of the application without changing the code so improves maintainability

To show that apps in the same shell share env vars set in the shell
Set APP_PASSWORD=wibble
start the app in the terminal: node app.js &
The & will run it in the background so we can still use the terminal to start another
The first app will run at 3000 based on the .env
Set $env:PORT=5000 - can't run the app on the same port. This will override .env for this process
Start the second app node app.js &
Check the API on both and see the password being used by both is the same

You need to manually stop and remove the processes:
List the jobs with get-job
stop-job ID 
remove-job ID 
For each



