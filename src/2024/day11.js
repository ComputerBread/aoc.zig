//const input = [872027, 227, 18, 9760, 0, 4, 67716, 9245696];
//const input = [125, 17];
//const input = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
const input = [0]
let count = input.length;

// this seem to stop working after 22 digits, hopefully it will be ok :/
function nbDigits(num) {
  return String(num).length;
}

// const map = new Map();
// map.put(0,)

for (let i = 0; i < 25; i++) {
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
