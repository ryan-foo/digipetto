pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

abstract contract YourCollectible is ERC721, VRFConsumerBase {

  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor(bytes32[] memory assetsForSale) public
    VRFConsumerBase(
      0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
      0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
    )  ERC721("YourCollectible", "YCB") {
    _setBaseURI("https://ipfs.io/ipfs/");
    for(uint256 i=0;i<assetsForSale.length;i++){
      forSale[assetsForSale[i]] = true;
    }
    keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    fee = 0.1 * 10 ** 18; // 0.1 LINK
  }

  //this marks an item in IPFS as "forsale"
  mapping (bytes32 => bool) public forSale;
  //this lets you look up a token by the uri (assuming there is only one of each uri for now)
  mapping (bytes32 => uint256) public uriToTokenId;

  //NFT stats
  mapping (bytes32 => uint8) public tokenStrength;

  //lifespan NFTs
  mapping(bytes32 => uint8) public remainingLifespan;

  function getRandomNumber() public returns (bytes32 requestId) {
      require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
      return requestRandomness(keyHash, fee);
  }

  // add more on-chain randomness in future
  function generateCharacter(uint256 tokenId) public returns(string memory){

    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Dog",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );  
}

  function fulfillRandomness(uint256 randomness) internal {
      randomResult = randomness;
    }

    function calcAdditionalModifiers() public pure returns (uint256) {
        // Request for Worldcoin Modifier?
        // Request ENS
        uint32 worldCoin = 0;
        uint32 polygonId = 0;
        uint32 ens = 0;

        uint256 mod = 0;
        if (worldCoin == 1) {
            mod += 5;
        } else if (polygonId == 1) {
            mod += 5;
        }
        else if (ens == 1) {
            mod += 5;
        }
        return mod;
    }

    getLevels(uint256 tokenId) public view returns (uint256) {

    }

    getTokenURI() public returns (uint256) {

    }

    function trainPet() public returns (uint256) {

    }

      function restPet(string id) public returns (uint256) {
        remainingLifespan[uriHash] = 
        _setTokenURI(id, tokenURI);

        uritoTokenId[uriHash] = id;
    }

  function mintItem(string memory tokenURI)
      public
      returns (uint256)
  {
      bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));

      //make sure they are only minting something that is marked "forsale"
      require(forSale[uriHash],"NOT FOR SALE");
      forSale[uriHash]=false;

      tokenStrength[uriHash] = uint8((randomResult % 100)+ 1);
      remainingLifespan[uriHash] = uint8((randomResult % 100) + 1 + calcAdditionalModifiers());
      randomResult = 0;

      _tokenIds.increment();

      uint256 id = _tokenIds.current();
      _mint(msg.sender, id);
      _setTokenURI(id, tokenURI);

      uriToTokenId[uriHash] = id;

      return id;
  }
}