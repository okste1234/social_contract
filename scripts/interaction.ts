import { ethers } from "hardhat";

async function main() {

  const socialMediaAddress = "0x6D92B9b83CECD903FA051DAC194FDB3e97417716";

  const socialMedia = await ethers.getContractAt("ISocialMedia", socialMediaAddress);

  // const tx = await socialMedia.registerUser("okste", "dazzling")
  // await tx.wait();

  // console.log(tx);

  const uri = "ipfs/QmbLw2oDhFrivbiqWStZj9zwjHFD5ETiAazVsREUzPjJyw";

  const tx2 = await socialMedia.createPost("another cute cat", uri);

  await tx2.wait();

  console.log(tx2);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// NFTSFactory is deployed to 0xC4c4FC115795F04B2Cc69a56369F414CEdAdEEc0
// SocialMedia is deployed to 0x6D92B9b83CECD903FA051DAC194FDB3e97417716