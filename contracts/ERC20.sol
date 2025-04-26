// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev this token has a fixed totalsupply
contract ERC20Base is ERC20 {
    constructor() ERC20("BaseTa", "BSTA") {
        _mint(msg.sender, 100_000_000 * 10 ** decimals());
    }
}
