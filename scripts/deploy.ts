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

// NFTSFactory is deployed to 0xC4c4FC115795F04B2Cc69a56369F414CEdAdEEc0;
// SocialMedia is deployed to 0x6D92B9b83CECD903FA051DAC194FDB3e97417716;