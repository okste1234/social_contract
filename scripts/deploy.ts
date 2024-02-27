import { ethers } from "hardhat";

async function main() {

  const NFTSFactory = await ethers.deployContract("NFTSFactory");
  await NFTSFactory.waitForDeployment();

  console.log(`NFTSFactory is deployed to ${NFTSFactory.target}`);


  const socialMedia = await ethers.deployContract("SocialMedia", [NFTSFactory.target]);
  await socialMedia.waitForDeployment();

  console.log(`SocialMedia is deployed to ${socialMedia.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// NFTSFactory is deployed to 0x1DCBd5DB7D4F49Eb44D3Ef3e52D41B4Ea7684B9e
// SocialMedia is deployed to 0xA98Be0a3a63A3245635b1685Fb80E717E9bc6E71