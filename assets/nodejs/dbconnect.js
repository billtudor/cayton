
/* Question 2:

Consider the below MSSQL table structure. Please create and open an example Node JS connection to a MSSQL 
Server to the point it can be queried.
Following a succesful connection to the MSSQL Server, please query the below table returning the Users 
FirstName, LastName and MobileNumber. 
Output the the resulting dataset to screen or console. 

*/

var mssql = require('mssql');

var con = mssql.createConnection({
  host: "localhost",
  user: "a_username",
  password: "a_password",
  database: "tempdb"
});

con.connect(function(err) {
  if (err) throw err;
  con.query("SELECT FirstName, LastName and MobileNumber FROM Users", function (err, result, fields) {
    if (err) throw err;
    console.log(result);
  });
});