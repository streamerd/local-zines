// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

// instead of ownable, using access control with roles
contract LocalZine is ERC1155, AccessControl, ERC1155Burnable {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant COLLABORATOR_ROLE = keccak256("COLLABORATOR_ROLE");
    bytes32 public constant COMMUNITY_ROLE = keccak256("COMMUNITY_ROLE");

    mapping(bytes32 => uint256) private _roleToMintAmount;
    mapping(address => bytes32) private _addressToRole;
    mapping (uint256 => string) private _uris;
    
    uint256 public constant FRONT_COVER = 0;
    uint256 public constant PAGE_1 = 1;
    uint256 public constant PAGE_2 = 2;
    uint256 public constant PAGE_3 = 3;
    uint256 public constant PAGE_4 = 4;
    uint256 public constant PAGE_5 = 5;
    uint256 public constant PAGE_6 = 6;
    uint256 public constant PAGE_7 = 7;
    uint256 public constant BACK_COVER = 8;
    
    // for now define test accounts on rinkeby testnet.
    address private hiphop_hamburg = 0x88B7996A21df2FA8bA14706219569019E9D121a3;
    address private graffiti_hamburg = 0x7D98d9DA7eDBd83D7299e8d7A055614dB7dCe597;
    address[] private communityAddresses = [graffiti_hamburg, hiphop_hamburg];
   
    address private collaborator_one = 0xF2Bb8DCD9c246c03a42b029942DDD92Dd0Ea2302;
    address private collaborator_two = 0xf9268Ce96A1A66F061C8C1515343A33aAFff6d51;
    address[] private collaboratorAddresses = [collaborator_one, collaborator_two];
    
    /* @doc
        role: Participant can have below roles:
                URI_SETTER_ROLE, MINTER_ROLE, COLLABORATOR_ROLE, COMMUNITY_ROLE
        number_of_tokens: we'll mint this amount of those tokens (pages of zine) to each.
    */
     struct Participant {
        address walletAddr; 
        bytes32 role;
    }
    Participant[] participants;

    // TODO:// override setURI or URI function to inject {id}s. 
    // provide an IPFS root folder for multiple metadata for each token.
    // an example folder containing metadatas as 0.json, 1.json ... on IPFS.
    constructor() public ERC1155("https://bafybeiakm2hohh2pfkx7nmlno37q4knr4kb3i2klllpr5uh5wfgsjyqdcy.ipfs.dweb.link/{id}.json") {
        setCollaboratorAddresses();
        setCommunityAddresses();
        setupRoles();
        setMintAmounts();
        initParticipants(); 
        require(participants.length > 0, "Der exists no collaborator nor community account defined yet.");

        for(uint256 i = 0; i < participants.length; i++){
            mintToParticipant(FRONT_COVER, participants[i]);
            mintToParticipant(PAGE_1, participants[i]);
            mintToParticipant(PAGE_2, participants[i]);
            mintToParticipant(PAGE_3, participants[i]);
            mintToParticipant(PAGE_4, participants[i]);
            mintToParticipant(PAGE_5, participants[i]);
            mintToParticipant(PAGE_6, participants[i]);
            mintToParticipant(PAGE_7, participants[i]);
            mintToParticipant(BACK_COVER, participants[i]);
        }
    }
 
    function setupRoles() public onlyRole(MINTER_ROLE) {
        _setupRole(URI_SETTER_ROLE, msg.sender); 
        _setupRole(MINTER_ROLE, msg.sender); 
        _setupRole(COLLABORATOR_ROLE, msg.sender); 
        _setupRole(COLLABORATOR_ROLE, collaborator_one);
        _setupRole(COLLABORATOR_ROLE, collaborator_two);
        _setupRole(COMMUNITY_ROLE, hiphop_hamburg); 
        _setupRole(COMMUNITY_ROLE, graffiti_hamburg); 
    }
    
    // different roles can get their tokens in a range of rarity.
    function setMintAmounts() public onlyRole(MINTER_ROLE) {
        _roleToMintAmount[URI_SETTER_ROLE] = 0; // for now, set to 0.
        _roleToMintAmount[MINTER_ROLE] = 0;     // for now, set to 0.
        _roleToMintAmount[COLLABORATOR_ROLE] = 3;
        _roleToMintAmount[COMMUNITY_ROLE] = 2;
    }

    function setCollaboratorAddresses() public onlyRole(MINTER_ROLE){
        collaboratorAddresses[0] = collaborator_one;
        collaboratorAddresses[1] = collaborator_two;
    }
    
    function setCommunityAddresses() public onlyRole(MINTER_ROLE) {
        communityAddresses[1] = graffiti_hamburg;
        communityAddresses[0] = hiphop_hamburg;
    }
    
    function initParticipants() 
    public onlyRole(MINTER_ROLE) {

        for(uint256 i = 0; i < collaboratorAddresses.length; i++){
            _addressToRole[collaboratorAddresses[i]] = COLLABORATOR_ROLE;
            participants.push(Participant(collaboratorAddresses[i], COLLABORATOR_ROLE, _roleToMintAmount[COLLABORATOR_ROLE]));
        }
        for(uint256 i = 0; i < communityAddresses.length; i++){
            _addressToRole[communityAddresses[i]] = COMMUNITY_ROLE;
            participants.push(Participant(communityAddresses[i], COMMUNITY_ROLE, _roleToMintAmount[COMMUNITY_ROLE]));
        }
    }
    
    function mintToParticipant(uint256 tokenId, Participant memory participant) 
    public onlyRole(MINTER_ROLE) {
            _mint(participant.walletAddr, tokenId, _roleToMintAmount[participant.role], "");
    }
    
    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    // collaborators can burn any tokens. 
    // "Banksy Shreds 'Girl with Balloon' Painting after Sotheby's Auction"
    // https://www.youtube.com/watch?v=BZ9PAoKvqX8
    function burn(address walletAddr, uint256 tokenId, uint256 amount) public override onlyRole(COLLABORATOR_ROLE){
        _burn(walletAddr, tokenId, amount);
    }


    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public view 
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
      function uri(uint256 tokenId) override 
      public view 
      returns (string memory) {
        return(_uris[tokenId]);
    }
    
    function setTokenUri(uint256 tokenId, string memory uri) 
    public onlyRole(URI_SETTER_ROLE) 
    {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice"); 
        _uris[tokenId] = uri; 
    }
    
    
}