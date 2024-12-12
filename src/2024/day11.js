const input = [872027, 227, 18, 9760, 0, 4, 67716, 9245696];
//const input = [125, 17];
//const input = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
//const input = [0]
let count = input.length;

// this seem to stop working after 22 digits, hopefully it will be ok :/
function nbDigits(num) {
  return String(num).length;
}

const map = new Map();
// i = iteration
// n = number
// return number of numbers created after "i" iterations
function p(n, i) {

  if (i == 0) return 1;

  const key = `${n}-${i}`;
  const v = map.get(key);
  if (v != undefined) {
    return v;
  }


  let res = 0;
  let nbD = nbDigits(n);
  if (n === 0) {
    res = p(1, i - 1);
  } else if ((nbD & 1) == 0) {
    const shift = Math.pow(10, nbD / 2)
    res = p(Math.trunc(n / shift), i - 1) + p(n % shift, i - 1);
  } else {
    res = p(n * 2024, i - 1);
  }
  map.set(key, res);
  return res;
}

let res = 0;
for (let bal of input) {
  res += p(bal, 75);
}
console.log(res);

for (let i = 0; i < 75; i++) {
  let newCount = 0;
  for (let j = 0; j < count; j++) {
    const n = input.shift();
    if (n == 0) {
      newCount += 1;
      input.push(1);
      continue;
    }
    let nbD = nbDigits(n);
    if ((nbD & 1) == 0) {
      const shift = Math.pow(10, nbD / 2)
      input.push(Math.trunc(n / shift));
      input.push(n % shift);
      newCount += 2;
      continue;
    }
    input.push(n * 2024);
    newCount += 1;
  }
  count = newCount;
}

console.log(input.length);
