Demo of file upload to a staging area
ETL process to extract the data, transform it from text into records then load into tables

endpoint examples:
Show server is up
http://localhost:3000

Load data from text file into the specified table
http://localhost:3000/etl/quiz/quiz.txt  same for both databases but Mongo will name quiz collection quizzes

Check the data has arrived in the database using workbench or compass

Read data from the specified table
Also can check with http://localhost:3000/data/quizzes for mongo
or http://localhost:3000/data/quiz for mysql

Change the env var in .env from MYSQL to MONGO, restart the app then rerun the API call
Check the data has arrived in mongo using compass

****
Change env var in terminal to show it overrides .env
$env:DB_TYPE="MYSQL"
node etl.js

Load some data, change the env var and show the two different tables
