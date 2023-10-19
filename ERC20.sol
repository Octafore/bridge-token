// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "./lib/IERC20.sol";
import {IERC20Metadata} from "./lib/IERC20Metadata.sol";
import {IERC20Errors} from "./lib/IERC20Errors.sol";

abstract contract ERC20 is IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private mBalance;

    mapping(address account => mapping(address spender => uint256)) private mAllowances;

    uint256 private mTotalSupply;

    string private mName;
    string private mSymbol;

    constructor(string memory aName, string memory aSymbol) {
        mName = aName;
        mSymbol = aSymbol;
    }
    function name() public view virtual returns (string memory) {
        return mName;
    }
    function symbol() public view virtual returns (string memory) {
        return mSymbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 8;
    }
    function totalSupply() public view virtual returns (uint256) {
        return mTotalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return mBalance[account];
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return mAllowances[owner][spender];
    }
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            mTotalSupply += value;
        } else {
            uint256 fromBalance = mBalance[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                mBalance[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                mTotalSupply -= value;
            }
        } else {
            unchecked {
                mBalance[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        mAllowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}