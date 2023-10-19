// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IERC20 {
    // Occures when any amount (including zero) of the token transfers from an account to another
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // total supply
    function totalSupply() external view returns (uint256);

    // returns balance of an account
    function balanceOf(address account) external view returns (uint256);

    // transfer amount of token to receipient address from message sender's account
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}