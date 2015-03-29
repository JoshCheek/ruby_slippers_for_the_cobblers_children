// Expression bodies
var evens = [2,4,6,8,10]
var odds = evens.map(v => v + 1);
var nums = evens.map((v, i) => v + i);
console.log(odds)
console.log(nums)
