const path = "../../input/2024/day12.txt";
const file = Bun.file(path);

//const text = await file.text();

const text = `RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE`;

const lines = text.split('\n').filter(val => val.trim().length != 0);

const N = lines.length;
console.log(`there is ${lines.length} lines of ${lines[0].length} chars`)
const garden = [];
for (let line of lines) {
  garden.push(line.split(''));
}


var visited = Array(N).fill().map(() => Array(N).fill(false));

