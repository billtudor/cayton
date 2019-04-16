/* Question 1:
	A company offers a service that generates random numbers between 1 and 1000, one number at every request. 
	Write a product() function that accepts the amount of random numbers to generate and returns their product. 
	You can assume the presence in the code base of a getRandomNumber() function, reported below, that returns 
	a Promise which will resolve with the generated random number. 
*/

$( document ).ready(function() {

    $("#x").click(function () {
    	y =getRandomNumber();
        console.log("x clicked" && y);
    });

	function product(numReq) {
		console.log("numReq");
	}

	function getRandomNumber() {
	
	  const min = 1;
	  const max = 1000;
	  const randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;
	
	  return Promise.resolve(randomNumber);
	}


});

/* Question 2:

Consider the below MSSQL table structure. Please create and open an example Node JS connection to a MSSQL 
Server to the point it can be queried.
Following a succesful connection to the MSSQL Server, please query the below table returning the Users 
FirstName, LastName and MobileNumber. 
Output the the resulting dataset to screen or console. 

*/