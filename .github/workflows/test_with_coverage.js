const Cp = require("child_process");
const Fs = require("fs");
const Path = require("path");

const deleteFolderRecursive = path => {
  if (Fs.existsSync(path)) {
    Fs.readdirSync(path).forEach((file, index) => {
      const curPath = Path.join(path, file);
      if (Fs.lstatSync(curPath).isDirectory()) {
        // recurse
        deleteFolderRecursive(curPath);
      } else {
        // delete file
        Fs.unlinkSync(curPath);
      }
    });
    Fs.rmdirSync(path);
  }
};

function clean_local() {
  console.log("Cleaning old files...");
  try {
    deleteFolderRecursive("./_coverage");
  } catch (e) {
    console.error(e);
    console.warn("  _coverage not found");
  }
  try {
    Fs.unlinkSync("./coverage.json");
  } catch (e) {
    console.warn("  coverage.json not found");
  }
}

function patch_dune(dune_file) {
  console.log("Patching dune file...");
  const prev = Fs.readFileSync(dune_file, { encoding: "utf8" });
  const intermediate = prev.split("\n");
  intermediate.splice(3, 0, " (preprocess (pps bisect_ppx))");
  const next = intermediate.join("\n");

  console.log(`New dune file:

${next}`);
  Fs.writeFileSync(dune_file, next, { encoding: "utf8" });
  return prev;
}

function revert_dune(dune_file, prev) {
  console.log("Reverting dune file...");
  console.log(`New dune file:

${prev}`);
  Fs.writeFileSync(dune_file, prev, { encoding: "utf8" });
}

function run_tests() {
  console.log("Running tests...");
  Cp.execSync("esy test", {
    encoding: "utf8",
    env: { ...process.env, BISECT_ENABLE: "yes", REPORT_PATH: "./junit.xml" }
  });

  console.log("Coverage summary:");
  console.log(
    Cp.execSync(`esy bisect-ppx-report html`, {
      encoding: "utf8"
    }).toString()
  );
  console.log(
    Cp.execSync(`esy bisect-ppx-report summary`, {
      encoding: "utf8"
    }).toString()
  );

  console.log("Collecting coverage");
  Cp.execSync(`esy bisect-ppx-report send-to Codecov`, {
    encoding: "utf8"
  });
}

clean_local();
const prev_dune = patch_dune("./lib/dune");
try {
  run_tests();
} catch (e) {
  console.error(e);
}
revert_dune("./lib/dune", prev_dune);
console.log("Done.");
