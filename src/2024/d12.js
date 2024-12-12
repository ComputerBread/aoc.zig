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

// bruh, my memory is tricking me into believing that this was a DP problem
// like, I am actually bugging

function dfs(r, c, t) {
  if (garden[r][c] != t || visited[r][c]) {
    return { r: 0, p: 0, v: visited[r][c] };
  }
  visited[r][c] = true;
  const res = { r: 1, p: 4, v: true };
  if (r > 0) {
    const reg = dfs(r - 1, c, t) // up
    if (reg.r !== 0) {
      res.r += reg.r;
      res.p = res.p + reg.p - 2;
    } else if (reg.v) {
      res.p -= 2;
    }

  }
  if (r < N - 1) {
    const reg = dfs(r + 1, c, t) // down
    if (reg.r !== 0) {
      res.r += reg.r;
      res.p = res.p + reg.p - 2;
    } else if (reg.v) {
      res.p -= 2;
    }

  }
  if (c < N - 1) {
    const reg = dfs(r, c + 1, t) // left
    if (reg.r !== 0) {
      res.r += reg.r;
      res.p = res.p + reg.p - 2;
    } else if (reg.v) {
      res.p -= 2;
    }

  }
  if (c > 0) {
    const reg = dfs(r, c - 1, t) // right
    if (reg.r !== 0) {
      res.r += reg.r;
      res.p = res.p + reg.p - 2;
    } else if (reg.v) {
      res.p -= 2;
    }

  }
  return res;
}
let price = 0;
for (let i = 0; i < N; i++) {
  for (let j = 0; j < N; j++) {
    const res = dfs(i, j, garden[i][j]);
    price += res.r * res.p;
    if (res.r != 0)
      console.log(res.r, " * ", res.p);
  }
}
console.log(price);
