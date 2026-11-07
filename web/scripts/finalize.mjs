import { copyFile, readFile, writeFile, rm } from 'node:fs/promises';

const builtPath = new URL('../build/index.html', import.meta.url);
const pagePath = new URL('../index.html', import.meta.url);
let html = await readFile(builtPath, 'utf8');
html = html.replaceAll('./assets/', './build/assets/');
await writeFile(pagePath, html);
await rm(builtPath);