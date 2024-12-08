const path = "../../input/2024/day8.txt";
const file = Bun.file(path);

const text = await file.text();
const set = new Set([...text]);
const val = [...set.values()].filter((v) => v !== '.' && v !== '\n');
const ascii = val.map(v => v.charCodeAt(0));

console.log(`there is ${val.length} nodes: ${val}`);
console.log(`Max code point is ${Math.max(...ascii)}, Min is ${Math.min(...ascii)}, nodes: ${ascii}`);
const lines = text.split('\n');
console.log(`there is ${lines.length} lines of ${lines[0].length} chars`)
