const fs = require("fs");
const { exec } = require("child_process");
require("dotenv").config();

const forgeCommand = "forge script script/MockERC20.s.sol:MockERC20Script --chain-id 43113 --fork-url https://api.avax-test.network/ext/C/rpc --broadcast";
const forgeMintCommand = "forge script script/MintMockERC20.s.sol:MintMockERC20Script --chain-id 43113 --fork-url https://api.avax-test.network/ext/C/rpc --broadcast";

(async () => {
  try {
    const envFile = ".env";

    // Check if .env exists, and parse it if so
    const envVars = fs.existsSync(envFile) ? parseEnv(fs.readFileSync(envFile, "utf8")) : {};

    // Check for token addresses
    if (!envVars.TOKEN_A_ADDRESS || !envVars.TOKEN_B_ADDRESS) {
      console.log("Token addresses not found in .env. Running the Forge deployment script.");

      // Run Forge deployment script
      exec(forgeCommand, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error running Forge script: ${error.message}`);
          return;
        }
        if (stderr) {
          console.error(`Forge script stderr: ${stderr}`);
          return;
        }

        console.log(`Forge script stdout:\n${stdout}`);

        // Extract token addresses from the script output
        const tokenAddresses = extractAddresses(stdout);

        if (tokenAddresses.length === 2) {
          const [tokenAAddress, tokenBAddress] = tokenAddresses;
          console.log("Storing token addresses in .env:");
          console.log(`TOKEN_A_ADDRESS=${tokenAAddress}`);
          console.log(`TOKEN_B_ADDRESS="${tokenBAddress}"`);

          // Update or create the .env file
          envVars.TOKEN_A_ADDRESS = `"${tokenAAddress}"`;
          envVars.TOKEN_B_ADDRESS = `"${tokenBAddress}"`;
          saveEnv(envFile, envVars);
        } else {
          console.error("Failed to extract both token addresses from the script output.");
        }
      });
    } else {
      console.log("Token addresses already exist in .env:");
      console.log(`TOKEN_A_ADDRESS: ${envVars.TOKEN_A_ADDRESS}`);
      console.log(`TOKEN_B_ADDRESS: ${envVars.TOKEN_B_ADDRESS}`);

      // Run Forge mint command
      console.log("Running Forge mint command...");
      exec(forgeMintCommand, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error running Forge mint command: ${error.message}`);
          return;
        }
        if (stderr) {
          console.error(`Forge mint command stderr: ${stderr}`);
          return;
        }
        console.log(`Forge mint command stdout:\n${stdout}`);
      });
    }
  } catch (error) {
    console.error("Error checking .env file or running the Forge script:", error);
  }
})();

// Helper function to parse .env content
function parseEnv(content) {
  const lines = content.split("\n");
  const env = {};

  for (const line of lines) {
    const [key, value] = line.split("=");
    if (key && value) {
      env[key.trim()] = value.trim();
    }
  }

  return env;
}

// Helper function to save variables back to the .env file
function saveEnv(filePath, variables) {
  const content = Object.entries(variables)
    .map(([key, value]) => `${key}=${value}`)
    .join("\n");

  fs.writeFileSync(filePath, content, "utf8");
  console.log(`Updated .env file:\n${content}`);
}

// Helper function to extract token addresses from the script output
function extractAddresses(output) {
  const regex = /MockERC20 deployed on [\w\s]+ at: (0x[a-fA-F0-9]{40})/g;
  let match;
  const addresses = [];

  // Capture all matching addresses
  while ((match = regex.exec(output)) !== null) {
    addresses.push(match[1]);
  }

  return addresses;
}
