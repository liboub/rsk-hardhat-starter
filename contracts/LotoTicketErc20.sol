pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';


contract LottoTicketsERC20 is ERC20 , ReentrancyGuard {
    uint256 private totalMinted;
    uint256 private totalBurned;
    uint256 public mintCost = 1;
    IERC20 public docToken;


    constructor( address payable _docTokenAddress) ERC20('LottoTickets', 'LTT') {
        docToken = IERC20(address(_docTokenAddress)); // Initialize the DocToken instance with its address
    uint256 initialSupply = 1000000 * (10**uint256(decimals()));
        // delete this
        _mint(msg.sender, initialSupply);
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, 'The caller is another contract');
        _;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0; // Set to 0 for non-divisible tokens
    }

    function mintWithDOC(uint256 quantity) public nonReentrant callerIsUser {
        require(quantity > 0, 'Quantity must be positive');

        uint256 totalCost = mintCost * quantity;
        uint256 tokensToSend = totalCost * 10**18; // Assuming the cost is in a token with 18 decimals

        require(
            docToken.allowance(msg.sender, address(this)) >= tokensToSend,
            'Approve DocToken first'
        );

        bool sent = docToken.transferFrom(
            msg.sender,
            address(this),
            tokensToSend
        );
        require(sent, 'DocToken transfer failed');

        // Mint the tokens using ERC-20 _mint function
        _mint(msg.sender, quantity);
        totalMinted += quantity;
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        totalBurned += amount;
    }
}