const path = "../../input/2024/day13.txt";
const file = Bun.file(path);

const text = await file.text();


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

const games = parseCoordinates(text);
const priceA = 3;
const priceB = 1;

console.log(Number.MAX_SAFE_INTEGER)
let res = 0;
// i guess init pos is 0,0
for (const game of games) {
  const dp = matrix(game.prize.x + 1, game.prize.y + 1);
  dp[0][0] = 0;
  //console.log(game)
  for (let i = 0; i <= game.prize.x; i++) {
    for (let j = 0; j <= game.prize.y; j++) {
      if ((i - game.buttonA.x) >= 0
        && (j - game.buttonA.y) >= 0
        && dp[i - game.buttonA.x][j - game.buttonA.y] != Number.MAX_SAFE_INTEGER
      ) {
        dp[i][j] = Math.min(dp[i][j], dp[i - game.buttonA.x][j - game.buttonA.y] + priceA);
      }
      if ((i - game.buttonB.x >= 0)
        && (j - game.buttonB.y >= 0)
        && dp[i - game.buttonB.x][j - game.buttonB.y] != Number.MAX_SAFE_INTEGER) {
        dp[i][j] = Math.min(dp[i][j], dp[i - game.buttonB.x][j - game.buttonB.y] + priceB);
      }
    }
  }
  const resQuestionMark = dp[game.prize.x][game.prize.y];
  if (resQuestionMark != Number.MAX_SAFE_INTEGER)
    res += resQuestionMark;
  console.log("res", res)
}

console.log("total res", res)
