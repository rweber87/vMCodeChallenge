function stringToEquation(formula){
	var arr = formula.split(" ");
	var solution = 0;
	
	while(arr.indexOf("*") > -1 ){
		var multNums = [Number(arr[arr.indexOf("*") - 1]) * Number(arr[arr.indexOf("*") + 1])];
		arr = arr.slice(0, arr.indexOf("*") - 1).concat(multNums, arr.slice(arr.indexOf("*") + 2));
	};

	while(arr.indexOf("/") > -1 ){
		var divNums = [Number(arr[arr.indexOf("/") - 1]) / Number(arr[arr.indexOf("/") + 1])];
		arr = arr.slice(0, arr.indexOf("/") - 1).concat(divNums, arr.slice(arr.indexOf("/") + 2));
	};

	
	arr.forEach(function(el){
		if(el != "+"){
			solution += Number(el)
		};
	});

	return solution;
	
}

console.assert(stringToEquation('3 * 4 * 5 * 2 * 3') == 360, 'Failed Multiplcation Test')
console.assert(stringToEquation('3 * 4 + 5 * 6 / 3') == 22, 'Failed Multiplcation, Division, and Addition Test')
console.assert(stringToEquation('3 * 4 + 5 * 2 * 3') == 42, 'Failed Mixed Multiplcation And Addition Test')
console.assert(stringToEquation('3 + 4 + 5 + 2 + 3') == 17, 'Failed Only Addition Test')