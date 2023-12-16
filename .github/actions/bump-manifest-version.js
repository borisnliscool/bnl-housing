// inspired by https://github.com/overextended/ox_inventory
const fs = require("fs");

const version = process.env.TGT_RELEASE_VERSION;
const manifestFile = fs.readFileSync("fxmanifest.lua", { encoding: "utf8" });

const newContents = manifestFile.replace(
	/\bversion\s+(.*)$/gm,
	`version '${version.replace("v", "")}'`
);

fs.writeFileSync("fxmanifest.lua", newContents);
