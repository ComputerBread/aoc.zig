const path = "../../input/2024/day12.txt";
const file = Bun.file(path);

//const text = await file.text();


function parseCoordinates(text) {
  // Split the text into lines
  const lines = text.trim().split('\n');

  // Array to store parsed entries
  const entries = [];

  // Temporary variables to build each entry
  let currentEntry = {
    buttonA: { x: null, y: null },
    buttonB: { x: null, y: null },
    prize: { x: null, y: null }
  };

  // Regular expressions for parsing
  const buttonRegex = /Button (A|B): X\+(\d+), Y\+(\d+)/;
  const prizeRegex = /Prize: X=(\d+), Y=(\d+)/;

  lines.forEach(line => {
    // Check for Button A
    const buttonAMatch = line.match(buttonRegex);
    if (buttonAMatch && buttonAMatch[1] === 'A') {
      currentEntry.buttonA.x = parseInt(buttonAMatch[2]);
      currentEntry.buttonA.y = parseInt(buttonAMatch[3]);
      return;
    }

    // Check for Button B
    const buttonBMatch = line.match(buttonRegex);
    if (buttonBMatch && buttonBMatch[1] === 'B') {
      currentEntry.buttonB.x = parseInt(buttonBMatch[2]);
      currentEntry.buttonB.y = parseInt(buttonBMatch[3]);
      return;
    }

    // Check for Prize coordinates
    const prizeMatch = line.match(prizeRegex);
    if (prizeMatch) {
      currentEntry.prize.x = parseInt(prizeMatch[1]);
      currentEntry.prize.y = parseInt(prizeMatch[2]);

      // Add completed entry to results and reset
      entries.push(currentEntry);
      currentEntry = {
        buttonA: { x: null, y: null },
        buttonB: { x: null, y: null },
        prize: { x: null, y: null }
      };
    }
  });

  return entries;
}

function matrix(m, n) {
  return Array.from({
    length: m
  }, () => new Array(n).fill(Number.MAX_SAFE_INTEGER));
};

// Example usage
const coordinateData = `Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279`;

const games = parseCoordinates(coordinateData);
const priceA = 3;
const priceB = 1;

let res = 0;
// i guess init pos is 0,0
for (const game of games) {
  console.log(game);
  const queue = [];
  const m = new Map();
  queue.push({ cost: 0, ...game.prize });
  while (queue.length > 0) {
    console.log("queue length: ", queue.length)
    const curr = queue.shift();

    //console.log("???? button A", game.buttonA);
    //console.log("???? button B", game.buttonB);
    const posAfterA = { x: curr.x - game.buttonA.x, y: curr.y - game.buttonA.y, cost: curr.cost + priceA };
    const posAfterB = { x: curr.x - game.buttonB.x, y: curr.y - game.buttonB.y, cost: curr.cost + priceB };
    const namePosA = `${posAfterA.x}-${posAfterA.y}`;
    const namePosB = `${posAfterB.x}-${posAfterB.y}`;

    // console.log("curr ", curr)
    // console.log("A ", posAfterA);
    // console.log("B ", posAfterB);

    // careful if A and B move at the same speed
    if (posAfterA.x >= 0 && posAfterA.y >= 0) {
      let min = posAfterA.cost;
      if (m.has(namePosA)) {
        const v = m.get(namePosA);
        min = Math.min(v, min);
      }
      m.set(namePosA, min);
      queue.push(posAfterA);
    } else {
      console.log("out")
    }

    if (posAfterB.x >= 0 && posAfterB.y >= 0) {
      let min = posAfterB.cost;
      if (m.has(namePosB)) {
        const v = m.get(namePosB);
        min = Math.min(v, min);
      }
      m.set(namePosB, min);
      queue.push(posAfterB);
    } else {
      console.log("out")
    }
  }
  res += m.get("0-0");
}
console.log(res);
