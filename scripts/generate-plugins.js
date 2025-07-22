#!/usr/bin/env node
// Generate sheldon plugins.toml from package.json dependencies

const fs = require('fs');
const path = require('path');

// Read package.json
const packageJsonPath = path.join(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Create sheldon config directory
const sheldonConfigDir = path.join(process.env.HOME, '.config', 'sheldon');
if (!fs.existsSync(sheldonConfigDir)) {
    fs.mkdirSync(sheldonConfigDir, { recursive: true });
}

// Generate plugins.toml content
let tomlContent = '# Generated from package.json by mac-dev-setup\n';
tomlContent += '# This file configures Zsh plugins managed by sheldon\n\n';
tomlContent += '# Shell configuration\n';
tomlContent += 'shell = "zsh"\n\n';

const dependencies = packageJson.dependencies || {};

for (const [name, gitUrl] of Object.entries(dependencies)) {
    if (gitUrl.startsWith('git+')) {
        // Extract git URL and version tag
        const cleanUrl = gitUrl.replace('git+', '').split('#')[0];
        const tag = gitUrl.includes('#') ? gitUrl.split('#')[1] : 'main';
        const repoPath = cleanUrl
            .replace('https://github.com/', '')
            .replace(/\.git$/, ''); // Strip .git suffix that breaks sheldon

        tomlContent += `[plugins.${name}]\n`;
        tomlContent += `github = "${repoPath}"\n`;
        tomlContent += `tag = "${tag}"\n\n`;
    }
}

// Write plugins.toml
const pluginsTomlPath = path.join(sheldonConfigDir, 'plugins.toml');
fs.writeFileSync(pluginsTomlPath, tomlContent);

console.log(`Generated sheldon config: ${pluginsTomlPath}`);
console.log(`Configured ${Object.keys(dependencies).length} plugins`);
