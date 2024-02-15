// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

contract CurveErrorCodes {
    enum Error {
        OK, // No error
        INVALID_NUMITEMS, // The numItem value is 0
        SPOT_PRICE_OVERFLOW, // The updated spot price doesn't fit into 128 bits
        DELTA_OVERFLOW, // The updated delta doesn't fit into 128 bits
        SPOT_PRICE_UNDERFLOW // The updated spot price goes too low
    }
}

interface IOwnershipTransferReceiver {
    function onOwnershipTransferred(address oldOwner, bytes memory data) external payable;
}

interface IPropertyChecker {
    function hasProperties(uint256[] calldata ids, bytes calldata params) external returns (bool);
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/// @author: manifold.xyz

/**
 * @dev Lookup engine interface
 */
interface IRoyaltyEngineV1 is IERC165 {
    /**
     * Get the royalty for a given token (address, id) and value amount.  Does not cache the bps/amounts.  Caches the spec for a given token address
     *
     * @param tokenAddress - The address of the token
     * @param tokenId      - The id of the token
     * @param value        - The value you wish to get the royalty of
     *
     * returns Two arrays of equal length, royalty recipients and the corresponding amount each recipient should get
     */
    function getRoyalty(address tokenAddress, uint256 tokenId, uint256 value)
        external
        returns (address payable[] memory recipients, uint256[] memory amounts);

    /**
     * View only version of getRoyalty
     *
     * @param tokenAddress - The address of the token
     * @param tokenId      - The id of the token
     * @param value        - The value you wish to get the royalty of
     *
     * returns Two arrays of equal length, royalty recipients and the corresponding amount each recipient should get
     */
    function getRoyaltyView(address tokenAddress, uint256 tokenId, uint256 value)
        external
        view
        returns (address payable[] memory recipients, uint256[] memory amounts);
}

interface ICurve {
    /**
     * @notice Validates if a delta value is valid for the curve. The criteria for
     * validity can be different for each type of curve, for instance ExponentialCurve
     * requires delta to be greater than 1.
     * @param delta The delta value to be validated
     * @return valid True if delta is valid, false otherwise
     */
    function validateDelta(uint128 delta) external pure returns (bool valid);

    /**
     * @notice Validates if a new spot price is valid for the curve. Spot price is generally assumed to be the immediate sell price of 1 NFT to the pool, in units of the pool's paired token.
     * @param newSpotPrice The new spot price to be set
     * @return valid True if the new spot price is valid, false otherwise
     */
    function validateSpotPrice(uint128 newSpotPrice) external view returns (bool valid);

    /**
     * @notice Given the current state of the pair and the trade, computes how much the user
     * should pay to purchase an NFT from the pair, the new spot price, and other values.
     * @param spotPrice The current selling spot price of the pair, in tokens
     * @param delta The delta parameter of the pair, what it means depends on the curve
     * @param numItems The number of NFTs the user is buying from the pair
     * @param feeMultiplier Determines how much fee the LP takes from this trade, 18 decimals
     * @param protocolFeeMultiplier Determines how much fee the protocol takes from this trade, 18 decimals
     * @return error Any math calculation errors, only Error.OK means the returned values are valid
     * @return newSpotPrice The updated selling spot price, in tokens
     * @return newDelta The updated delta, used to parameterize the bonding curve
     * @return inputValue The amount that the user should pay, in tokens
     * @return tradeFee The amount that is sent to the trade fee recipient
     * @return protocolFee The amount of fee to send to the protocol, in tokens
     */
    function getBuyInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 tradeFee,
            uint256 protocolFee
        );

    /**
     * @notice Given the current state of the pair and the trade, computes how much the user
     * should receive when selling NFTs to the pair, the new spot price, and other values.
     * @param spotPrice The current selling spot price of the pair, in tokens
     * @param delta The delta parameter of the pair, what it means depends on the curve
     * @param numItems The number of NFTs the user is selling to the pair
     * @param feeMultiplier Determines how much fee the LP takes from this trade, 18 decimals
     * @param protocolFeeMultiplier Determines how much fee the protocol takes from this trade, 18 decimals
     * @return error Any math calculation errors, only Error.OK means the returned values are valid
     * @return newSpotPrice The updated selling spot price, in tokens
     * @return newDelta The updated delta, used to parameterize the bonding curve
     * @return outputValue The amount that the user should receive, in tokens
     * @return tradeFee The amount that is sent to the trade fee recipient
     * @return protocolFee The amount of fee to send to the protocol, in tokens
     */
    function getSellInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 tradeFee,
            uint256 protocolFee
        );
}

abstract contract OwnableWithTransferCallback {

    bytes4 constant TRANSFER_CALLBACK = type(IOwnershipTransferReceiver).interfaceId;

    error Ownable_NotOwner();
    error Ownable_NewOwnerZeroAddress();

    address private _owner;

    event OwnershipTransferred(address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init(address initialOwner) internal {
        _owner = initialOwner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) revert Ownable_NotOwner();
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The new address to become owner
     * @param data Any additional data to send to the ownership received callback.
     * Disallows setting to the zero address as a way to more gas-efficiently avoid reinitialization.
     * When ownership is transferred, if the new owner implements IOwnershipTransferCallback, we make a callback.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner, bytes calldata data) public payable virtual onlyOwner {
        if (newOwner == address(0)) revert Ownable_NewOwnerZeroAddress();
        _transferOwnership(newOwner);

        if (newOwner.code.length > 0) {
            try IOwnershipTransferReceiver(newOwner).onOwnershipTransferred{value: msg.value}(msg.sender, data) {}
            // If revert...
            catch (bytes memory reason) {
                // If we just transferred to a contract w/ no callback, this is fine
                if (reason.length == 0) {
                    // i.e., no need to revert
                }
                // Otherwise, the callback had an error, and we should revert
                else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * @dev Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
        emit OwnershipTransferred(newOwner);
    }
}

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

interface ILSSVMPairFactoryLike {
    struct Settings {
        uint96 bps;
        address pairAddress;
    }

    enum PairNFTType {
        ERC721,
        ERC1155
    }

    enum PairTokenType {
        ETH,
        ERC20
    }

    enum PairVariant {
        ERC721_ETH,
        ERC721_ERC20,
        ERC1155_ETH,
        ERC1155_ERC20
    }

    function protocolFeeMultiplier() external view returns (uint256);

    function defaultProtocolFeeRecipient() external view returns (address payable);

    function authAllowedForToken(address tokenAddress, address proposedAuthAddress) external view returns (bool);

    function getSettingsForPair(address pairAddress) external view returns (bool settingsEnabled, uint96 bps);

    function enableSettingsForPair(address settings, address pairAddress) external;

    function disableSettingsForPair(address settings, address pairAddress) external;

    function routerStatus(LSSVMRouter router) external view returns (bool allowed, bool wasEverTouched);

    function isValidPair(address pairAddress) external view returns (bool);

    function getPairNFTType(address pairAddress) external pure returns (PairNFTType);

    function getPairTokenType(address pairAddress) external pure returns (PairTokenType);

    function getProtocolFeeRecipient(address referrerAddress) external view returns (address payable);

    function openLock() external;

    function closeLock() external;
}

/**
 * @title The base contract for an NFT/TOKEN AMM pair
 * @author boredGenius, 0xmons, 0xCygaar
 * @notice This implements the core swap logic from NFT to TOKEN
 */
abstract contract LSSVMPair is OwnableWithTransferCallback, ERC721Holder, ERC1155Holder {
    /**
     *  Enums **
     */

    enum PoolType {
        TOKEN,
        NFT,
        TRADE
    }

    /**
     * Constants **
     */

    /**
     * @dev 50%, must <= 1 - MAX_PROTOCOL_FEE (set in LSSVMPairFactory)
     */
    uint256 internal constant MAX_TRADE_FEE = 0.5e18;

    /**
     *  Immutable params **
     */

    /**
     * @notice Sudoswap Royalty Engine
     */
    IRoyaltyEngineV1 public ROYALTY_ENGINE;

    /**
     *  Storage variables **
     */

    /**
     * @dev This is generally used to mean the immediate sell price for the next marginal NFT.
     * However, this should NOT be assumed, as bonding curves may use spotPrice in different ways.
     * Use getBuyNFTQuote and getSellNFTQuote for accurate pricing info.
     */
    uint128 public spotPrice;

    /**
     * @notice The parameter for the pair's bonding curve.
     * Units and meaning are bonding curve dependent.
     */
    uint128 public delta;

    /**
     * @notice The spread between buy and sell prices, set to be a multiplier we apply to the buy price
     * Fee is only relevant for TRADE pools. Units are in base 1e18.
     */
    uint96 public fee;

    /**
     * @notice The address that swapped assets are sent to.
     * For TRADE pools, assets are always sent to the pool, so this is used to track trade fee.
     * If set to address(0), will default to owner() for NFT and TOKEN pools.
     */
    address payable internal assetRecipient;

    /**
     * @notice The IPairHooks contract to use for callbacks, if any.
     */
    IPairHooks public hook;

    /**
     * @notice The referral address to use, if any.
     */
    address public referralAddress;

    /**
     *  Events
     */

    event SwapNFTInPair(uint256 amountOut, uint256[] ids, uint256 royaltyAmount);
    event SwapNFTInPair(uint256 amountOut, uint256 numNFTs, uint256 royaltyAmount);
    event SwapNFTOutPair(uint256 amountIn, uint256[] ids, uint256 royaltyAmount);
    event SwapNFTOutPair(uint256 amountIn, uint256 numNFTs, uint256 royaltyAmount);
    event SpotPriceUpdate(uint128 newSpotPrice);
    event TokenDeposit(uint256 amount);
    event TokenWithdrawal(uint256 amount);
    event NFTWithdrawal(uint256[] ids);
    event NFTWithdrawal(uint256 numNFTs);
    event DeltaUpdate(uint128 newDelta);
    event FeeUpdate(uint96 newFee);

    /**
     *  Errors
     */

    error LSSVMPair__NotRouter();
    error LSSVMPair__InvalidDelta();
    error LSSVMPair__WrongPoolType();
    error LSSVMPair__OutputTooSmall();
    error LSSVMPair__ZeroSwapAmount();
    error LSSVMPair__RoyaltyTooLarge();
    error LSSVMPair__TradeFeeTooLarge();
    error LSSVMPair__InvalidSpotPrice();
    error LSSVMPair__TargetNotAllowed();
    error LSSVMPair__NftNotTransferred();
    error LSSVMPair__AlreadyInitialized();
    error LSSVMPair__FunctionNotAllowed();
    error LSSVMPair__DemandedInputTooLarge();
    error LSSVMPair__NonTradePoolWithTradeFee();
    error LSSVMPair__BondingCurveError(CurveErrorCodes.Error error);


    function __init__(IRoyaltyEngineV1 royaltyEngine) public {
        ROYALTY_ENGINE = royaltyEngine;
    }

    /**
     * @notice Called during pair creation to set initial parameters
     * @dev Only called once by factory to initialize.
     * We verify this by making sure that the current owner is address(0).
     * The Ownable library we use disallows setting the owner to be address(0), so this condition
     * should only be valid before the first initialize call.
     * @param _owner The owner of the pair
     * @param _assetRecipient The address that will receive the TOKEN or NFT sent to this pair during swaps. NOTE: If set to address(0), they will go to the pair itself.
     * @param _delta The initial delta of the bonding curve
     * @param _fee The initial % fee taken, if this is a trade pair
     * @param _spotPrice The initial price to sell an asset into the pair
     */
    function initialize(
        address _owner,
        address payable _assetRecipient,
        uint128 _delta,
        uint96 _fee,
        uint128 _spotPrice,
        address _hookAddress,
        address _referralAddress
    ) external {
        if (owner() != address(0)) revert LSSVMPair__AlreadyInitialized();
        __Ownable_init(_owner);

        ICurve _bondingCurve = bondingCurve();
        PoolType _poolType = poolType();
        if (_poolType != PoolType.TRADE) {
            if (_fee != 0) revert LSSVMPair__NonTradePoolWithTradeFee();
        } else {
            if (_fee > MAX_TRADE_FEE) revert LSSVMPair__TradeFeeTooLarge();
            fee = _fee;
        }

        assetRecipient = _assetRecipient;

        if (!_bondingCurve.validateDelta(_delta)) revert LSSVMPair__InvalidDelta();
        if (!_bondingCurve.validateSpotPrice(_spotPrice)) revert LSSVMPair__InvalidSpotPrice();
        delta = _delta;
        spotPrice = _spotPrice;
        hook = IPairHooks(_hookAddress);
        referralAddress = _referralAddress;

        if (_hookAddress != address(0)) {
            hook.afterNewPair();
        }
    }

    /**
     * External state-changing functions
     */

    /**
     * @notice Sends token to the pair in exchange for a specific set of NFTs
     * @dev To compute the amount of token to send, call bondingCurve.getBuyInfo
     * This swap is meant for users who want specific IDs. Also higher chance of
     * reverting if some of the specified IDs leave the pool before the swap goes through.
     * @param nftIds The list of IDs of the NFTs to purchase
     * @param maxExpectedTokenInput The maximum acceptable cost from the sender. If the actual
     * amount is greater than this value, the transaction will be reverted.
     * @param nftRecipient The recipient of the NFTs
     * @param isRouter True if calling from LSSVMRouter, false otherwise. Not used for ETH pairs.
     * @param routerCaller If isRouter is true, ERC20 tokens will be transferred from this address. Not used for ETH pairs.
     * @return - The amount of token used for purchase
     */
    function swapTokenForSpecificNFTs(
        uint256[] calldata nftIds,
        uint256 maxExpectedTokenInput,
        address nftRecipient,
        bool isRouter,
        address routerCaller
    ) external payable virtual returns (uint256);

    /**
     * @notice Sends a set of NFTs to the pair in exchange for token
     * @dev To compute the amount of token to that will be received, call bondingCurve.getSellInfo.
     * @param nftIds The list of IDs of the NFTs to sell to the pair
     * @param minExpectedTokenOutput The minimum acceptable token received by the sender. If the actual
     * amount is less than this value, the transaction will be reverted.
     * @param tokenRecipient The recipient of the token output
     * @param isRouter True if calling from LSSVMRouter, false otherwise. Not used for
     * ETH pairs.
     * @param routerCaller If isRouter is true, ERC20 tokens will be transferred from this address. Not used for
     * ETH pairs.
     * @return outputAmount The amount of token received
     */
    function swapNFTsForToken(
        uint256[] calldata nftIds,
        uint256 minExpectedTokenOutput,
        address payable tokenRecipient,
        bool isRouter,
        address routerCaller
    ) external virtual returns (uint256 outputAmount);

    /**
     * View functions
     */

    /**
     * @dev Used as read function to query the bonding curve for buy pricing info
     * @param numNFTs The number of NFTs to buy from the pair
     */
    function getBuyNFTQuote(uint256 assetId, uint256 numNFTs)
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint256 newSpotPrice,
            uint256 newDelta,
            uint256 inputAmount,
            uint256 protocolFee,
            uint256 royaltyAmount
        )
    {
        uint256 tradeFee;
        (error, newSpotPrice, newDelta, inputAmount, tradeFee, protocolFee) =
            bondingCurve().getBuyInfo(spotPrice, delta, numNFTs, fee, factory().protocolFeeMultiplier());

        if (numNFTs != 0) {
            // Compute royalties
            (,, royaltyAmount) = calculateRoyaltiesView(assetId, inputAmount - tradeFee - protocolFee);

            inputAmount += royaltyAmount;
        }
    }

    /**
     * @dev Used as read function to query the bonding curve for sell pricing info including royalties
     * @param numNFTs The number of NFTs to sell to the pair
     */
    function getSellNFTQuote(uint256 assetId, uint256 numNFTs)
        external
        view
        returns (
            CurveErrorCodes.Error error,
            uint256 newSpotPrice,
            uint256 newDelta,
            uint256 outputAmount,
            uint256 protocolFee,
            uint256 royaltyAmount
        )
    {
        (error, newSpotPrice, newDelta, outputAmount, /* tradeFee */, protocolFee) =
            bondingCurve().getSellInfo(spotPrice, delta, numNFTs, fee, factory().protocolFeeMultiplier());

        if (numNFTs != 0) {
            // Compute royalties
            (,, royaltyAmount) = calculateRoyaltiesView(assetId, outputAmount);

            // Deduct royalties from outputAmount
            unchecked {
                // Safe because we already require outputAmount >= royaltyAmount in _calculateRoyalties()
                outputAmount -= royaltyAmount;
            }
        }
    }

    /**
     * @notice Returns the pair's variant (Pair uses ETH or ERC20)
     */
    function pairVariant() public pure virtual returns (ILSSVMPairFactoryLike.PairVariant);

    function factory() public pure returns (ILSSVMPairFactoryLike _factory) {
        return ILSSVMPairFactoryLike(_getArgAddress(0));
    }

    /**
     * @notice Returns the type of bonding curve that parameterizes the pair
     */
    function bondingCurve() public pure returns (ICurve _bondingCurve) {
        return ICurve(_getArgAddress(20));
    }

    /**
     * @notice Returns the address of NFT collection that parameterizes the pair
     */
    function nft() public pure returns (address _nft) {
        return _getArgAddress(40);
    }

    /**
     * @notice Returns the pair's type (TOKEN/NFT/TRADE)
     */
    function poolType() public pure returns (PoolType _poolType) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _poolType := shr(0xf8, calldataload(add(sub(calldatasize(), paramsLength), 60)))
        }
    }

    /**
     * @notice Returns the address that receives assets when a swap is done with this pair
     * Can be set to another address by the owner, but has no effect on TRADE pools
     * If set to address(0), defaults to owner() for NFT/TOKEN pools
     */
    function getAssetRecipient() public view returns (address payable) {
        // TRADE pools will always receive the asset themselves
        if (poolType() == PoolType.TRADE) {
            return payable(address(this));
        }

        address payable _assetRecipient = assetRecipient;

        // Otherwise, we return the recipient if it's been set
        // Or, we replace it with owner() if it's address(0)
        if (_assetRecipient == address(0)) {
            return payable(owner());
        }
        return _assetRecipient;
    }

    /**
     * @notice Returns the address that receives trade fees when a swap is done with this pair
     * Only relevant for TRADE pools
     * If set to address(0), defaults to the pair itself
     */
    function getFeeRecipient() public view returns (address payable _feeRecipient) {
        _feeRecipient = assetRecipient;
        if (_feeRecipient == address(0)) {
            _feeRecipient = payable(address(this));
        }
    }

    /**
     * Internal functions
     */

    /**
     * @notice Calculates the amount needed to be sent into the pair for a swap and adjusts spot price or delta if necessary
     * @param numNFTs The amount of NFTs to purchase from the pair
     * @param _bondingCurve The bonding curve to use for price calculation
     * @param _factory The factory to use for protocol fee lookup
     * @return tradeFee The amount of tokens to send as trade fee
     * @return protocolFee The amount of tokens to send as protocol fee
     * @return swapAmount The amount of tokens total tokens received or sent
     */
    function _calculateSwapInfoAndUpdatePoolParams(
        uint256 numNFTs,
        ICurve _bondingCurve,
        ILSSVMPairFactoryLike _factory,
        bool isBuy
    ) internal returns (uint256 tradeFee, uint256 protocolFee, uint256 swapAmount) {
        CurveErrorCodes.Error error;

        uint128 newDelta;
        uint128 newSpotPrice;

        (error, newSpotPrice, newDelta, swapAmount, tradeFee, protocolFee) = isBuy
            ? _bondingCurve.getBuyInfo(spotPrice, delta, numNFTs, fee, _factory.protocolFeeMultiplier())
            : _bondingCurve.getSellInfo(spotPrice, delta, numNFTs, fee, _factory.protocolFeeMultiplier());
        if (!isBuy) tradeFee = 0;

        // Revert if bonding curve had an error
        if (error != CurveErrorCodes.Error.OK) {
            revert LSSVMPair__BondingCurveError(error);
        }

        // Update pool parameters and emit events
        spotPrice = newSpotPrice;
        delta = newDelta;
        emit SpotPriceUpdate(newSpotPrice);
        emit DeltaUpdate(newDelta);
    }

    /**
     * @notice Pulls the token input of a trade from the trader (including all royalties and fees)
     * @param inputAmountExcludingRoyalty The amount of tokens to be sent, excluding the royalty (includes protocol fee)
     * @param royaltyAmounts The amounts of tokens to be sent as royalties
     * @param royaltyRecipients The recipients of the royalties
     * @param royaltyTotal The sum of all royaltyAmounts
     * @param tradeFeeAmount The amount of tokens to be sent as trade fee (if applicable)
     * @param isRouter Whether or not the caller is LSSVMRouter
     * @param routerCaller If called from LSSVMRouter, store the original caller
     * @param protocolFee The protocol fee to be paid
     */
    function _pullTokenInputs(
        uint256 inputAmountExcludingRoyalty,
        uint256[] memory royaltyAmounts,
        address payable[] memory royaltyRecipients,
        uint256 royaltyTotal,
        uint256 tradeFeeAmount,
        bool isRouter,
        address routerCaller,
        uint256 protocolFee
    ) internal virtual;

    /**
     * @notice Sends excess tokens back to the caller (if applicable)
     * @dev Swap callers interacting with an ETH pair must be able to receive ETH (e.g. if the caller sends too much ETH)
     */
    function _refundTokenToSender(uint256 inputAmount) internal virtual;

    /**
     * @notice Sends tokens to a recipient
     * @param tokenRecipient The address receiving the tokens
     * @param outputAmount The amount of tokens to send
     */
    function _sendTokenOutput(address payable tokenRecipient, uint256 outputAmount) internal virtual;

    /**
     * @dev Used internally to grab pair parameters from calldata, see LSSVMPairCloner for technical details
     */
    function _immutableParamsLength() internal pure virtual returns (uint256);

    function _getArgAddress(uint256 offset) internal pure returns (address arg) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            arg := shr(0x60, calldataload(add(sub(calldatasize(), paramsLength), offset)))
        }
    }

    /**
     * Royalty support functions
     */

    /**
     * @dev Uses getRoyaltyView to avoid state mutations and is public for external callers
     */
    function calculateRoyaltiesView(uint256 assetId, uint256 saleAmount)
        public
        view
        returns (address payable[] memory royaltyRecipients, uint256[] memory royaltyAmounts, uint256 royaltyTotal)
    {
        (address payable[] memory recipients, uint256[] memory amounts) =
            ROYALTY_ENGINE.getRoyaltyView(nft(), assetId, saleAmount);
        return _calculateRoyaltiesLogic(recipients, amounts, saleAmount);
    }

    /**
     * @dev Common logic used by _calculateRoyalties() and calculateRoyaltiesView()
     */
    function _calculateRoyaltiesLogic(address payable[] memory recipients, uint256[] memory amounts, uint256 saleAmount)
        internal
        view
        returns (address payable[] memory royaltyRecipients, uint256[] memory royaltyAmounts, uint256 royaltyTotal)
    {
        // Cache to save gas
        uint256 numRecipients = recipients.length;

        if (numRecipients != 0) {
            // If a pair has custom Settings, use the overridden royalty amount and only use the first receiver
            try factory().getSettingsForPair(address(this)) returns (bool settingsEnabled, uint96 bps) {
                if (settingsEnabled) {
                    royaltyRecipients = new address payable[](1);
                    royaltyRecipients[0] = recipients[0];
                    royaltyAmounts = new uint256[](1);
                    royaltyAmounts[0] = (saleAmount * bps) / 10000;

                    // Update numRecipients to match new recipients list
                    numRecipients = 1;
                } else {
                    royaltyRecipients = recipients;
                    royaltyAmounts = amounts;
                }
            } catch {
                // Use the input values to calculate royalties if factory call fails
                royaltyRecipients = recipients;
                royaltyAmounts = amounts;
            }
        }

        for (uint256 i; i < numRecipients;) {
            royaltyTotal += royaltyAmounts[i];
            unchecked {
                ++i;
            }
        }

        // Ensure royalty total is at most 25% of the sale amount
        // This defends against a rogue Manifold registry that charges extremely high royalties
        if (royaltyTotal > saleAmount >> 2) {
            revert LSSVMPair__RoyaltyTooLarge();
        }
    }

    /**
     * Owner functions
     */

    /**
     * @notice Rescues a specified set of NFTs owned by the pair to the owner address. (onlyOwnable modifier is in the implemented function)
     * @param a The NFT to transfer
     * @param nftIds The list of IDs of the NFTs to send to the owner
     */
    function withdrawERC721(IERC721 a, uint256[] calldata nftIds) external virtual;

    /**
     * @notice Rescues ERC20 tokens from the pair to the owner. Only callable by the owner (onlyOwnable modifier is in the implemented function).
     * @param a The token to transfer
     * @param amount The amount of tokens to send to the owner
     */
    function withdrawERC20(ERC20 a, uint256 amount) external virtual;

    /**
     * @notice Rescues ERC1155 tokens from the pair to the owner. Only callable by the owner.
     * @param a The NFT to transfer
     * @param ids The NFT ids to transfer
     * @param amounts The amounts of each id to transfer
     */
    function withdrawERC1155(IERC1155 a, uint256[] calldata ids, uint256[] calldata amounts) external virtual;

    /**
     * @notice Updates the selling spot price. Only callable by the owner.
     * @param newSpotPrice The new selling spot price value, in Token
     */
    function changeSpotPrice(uint128 newSpotPrice) external onlyOwner {
        ICurve _bondingCurve = bondingCurve();
        if (!_bondingCurve.validateSpotPrice(newSpotPrice)) revert LSSVMPair__InvalidSpotPrice();
        uint128 oldSpotPrice = spotPrice;
        spotPrice = newSpotPrice;
        emit SpotPriceUpdate(newSpotPrice);
        if (address(hook) != address(0)) {
            hook.afterSpotPriceUpdate(oldSpotPrice, newSpotPrice);
        }
    }

    /**
     * @notice Updates the delta parameter. Only callable by the owner.
     * @param newDelta The new delta parameter
     */
    function changeDelta(uint128 newDelta) external onlyOwner {
        ICurve _bondingCurve = bondingCurve();
        if (!_bondingCurve.validateDelta(newDelta)) revert LSSVMPair__InvalidDelta();
        uint128 oldDelta = delta;
        delta = newDelta;
        emit DeltaUpdate(newDelta);
        if (address(hook) != address(0)) {
            hook.afterDeltaUpdate(oldDelta, newDelta);
        }
    }

    /**
     * @notice Updates the fee taken by the LP. Only callable by the owner.
     * Only callable if the pool is a Trade pool. Reverts if the fee is >= MAX_FEE.
     * @param newFee The new LP fee percentage, 18 decimals
     */
    function changeFee(uint96 newFee) external onlyOwner {
        PoolType _poolType = poolType();
        if (_poolType != PoolType.TRADE) revert LSSVMPair__NonTradePoolWithTradeFee();
        if (newFee > MAX_TRADE_FEE) revert LSSVMPair__TradeFeeTooLarge();
        uint96 oldFee = fee;
        if (oldFee != newFee) {
            fee = newFee;
            emit FeeUpdate(newFee);
        }
        if (address(hook) != address(0)) {
            hook.afterFeeUpdate(oldFee, newFee);
        }
    }

    /**
     * @notice Changes the address that will receive assets received from
     * trades. Only callable by the owner.
     * @param newRecipient The new asset recipient
     */
    function changeAssetRecipient(address payable newRecipient) external onlyOwner {
        assetRecipient = newRecipient;
    }

    /**
     * @notice Changes the referral address
     * @param newReferral The new referral
     */
    function changeReferralAddress(address newReferral) external onlyOwner {
        referralAddress = newReferral;
    }

    /**
     * @notice Allows owner to batch multiple calls, forked from: https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/BoringBatchable.sol
     * @notice The revert handling is forked from: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/c239e1af8d1a1296577108dd6989a17b57434f8e/contracts/utils/Address.sol#L201
     * @dev Intended for withdrawing/altering pool pricing in one tx, only callable by owner, cannot change owner
     * @param calls The calldata for each call to make
     * @param revertOnFail Whether or not to revert the entire tx if any of the calls fail. Calls to transferOwnership will revert regardless.
     */
    function multicall(bytes[] calldata calls, bool revertOnFail) external onlyOwner {
        for (uint256 i; i < calls.length;) {
            bytes4 sig = bytes4(calls[i][:4]);
            // We ban calling transferOwnership when ownership
            if (sig == transferOwnership.selector) revert LSSVMPair__FunctionNotAllowed();

            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                assembly {
                    revert(add(0x20, result), mload(result))
                }
            }

            unchecked {
                ++i;
            }
        }
    }
}

contract LSSVMRouter {
    using SafeTransferLib for address payable;
    using SafeTransferLib for ERC20;

    struct PairSwapSpecific {
        LSSVMPair pair;
        uint256[] nftIds;
    }

    struct RobustPairSwapSpecific {
        PairSwapSpecific swapInfo;
        uint256 maxCost;
    }

    struct RobustPairSwapSpecificForToken {
        PairSwapSpecific swapInfo;
        uint256 minOutput;
    }

    struct NFTsForSpecificNFTsTrade {
        PairSwapSpecific[] nftToTokenTrades;
        PairSwapSpecific[] tokenToNFTTrades;
    }

    struct RobustPairNFTsFoTokenAndTokenforNFTsTrade {
        RobustPairSwapSpecific[] tokenToNFTTrades;
        RobustPairSwapSpecificForToken[] nftToTokenTrades;
        uint256 inputAmount;
        address payable tokenRecipient;
        address nftRecipient;
    }

    modifier checkDeadline(uint256 deadline) {
        _checkDeadline(deadline);
        _;
    }

    ILSSVMPairFactoryLike public immutable factory;

    constructor(ILSSVMPairFactoryLike _factory) {
        factory = _factory;
    }

    /**
     * ETH swaps
     */

    /**
     * @notice Swaps ETH into specific NFTs using multiple pairs.
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to buy from each.
     * @param ethRecipient The address that will receive the unspent ETH input
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return remainingValue The unspent ETH amount
     */
    function swapETHForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    ) external payable checkDeadline(deadline) returns (uint256 remainingValue) {
        return _swapETHForSpecificNFTs(swapList, msg.value, ethRecipient, nftRecipient);
    }

    /**
     * @notice Swaps one set of NFTs into another set of specific NFTs using multiple pairs, using
     * ETH as the intermediary.
     * @param trade The struct containing all NFT-to-ETH swaps and ETH-to-NFT swaps.
     * @param minOutput The minimum acceptable total excess ETH received
     * @param ethRecipient The address that will receive the ETH output
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return outputAmount The total ETH received
     */
    function swapNFTsForSpecificNFTsThroughETH(
        NFTsForSpecificNFTsTrade calldata trade,
        uint256 minOutput,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    ) external payable checkDeadline(deadline) returns (uint256 outputAmount) {
        // Swap NFTs for ETH
        // minOutput of swap set to 0 since we're doing an aggregate slippage check
        outputAmount = _swapNFTsForToken(trade.nftToTokenTrades, 0, payable(address(this)));

        // Add extra value to buy NFTs
        outputAmount += msg.value;

        // Swap ETH for specific NFTs
        // cost <= inputValue = outputAmount - minOutput, so outputAmount' = (outputAmount - minOutput - cost) + minOutput >= minOutput
        outputAmount = _swapETHForSpecificNFTs(
            trade.tokenToNFTTrades, outputAmount - minOutput, ethRecipient, nftRecipient
        ) + minOutput;
    }

    /**
     * ERC20 swaps
     *
     * Note: All ERC20 swaps assume that a single ERC20 token is used for all the pairs involved.
     * Swapping using multiple tokens in the same transaction is possible, but the slippage checks
     * & the return values will be meaningless, and may lead to undefined behavior.
     *
     * Note: The sender should ideally grant infinite token approval to the router in order for NFT-to-NFT
     * swaps to work smoothly.
     */

    /**
     * @notice Swaps ERC20 tokens into specific NFTs using multiple pairs.
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to buy from each.
     * @param inputAmount The amount of ERC20 tokens to add to the ERC20-to-NFT swaps
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return remainingValue The unspent token amount
     */
    function swapERC20ForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 remainingValue) {
        return _swapERC20ForSpecificNFTs(swapList, inputAmount, nftRecipient);
    }

    /**
     * @notice Swaps NFTs into ETH/ERC20 using multiple pairs.
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to sell to each.
     * @param minOutput The minimum acceptable total tokens received
     * @param tokenRecipient The address that will receive the token output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return outputAmount The total tokens received
     */
    function swapNFTsForToken(
        PairSwapSpecific[] calldata swapList,
        uint256 minOutput,
        address tokenRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {
        return _swapNFTsForToken(swapList, minOutput, payable(tokenRecipient));
    }

    /**
     * @notice Swaps one set of NFTs into another set of specific NFTs using multiple pairs, using
     * an ERC20 token as the intermediary.
     * @param trade The struct containing all NFT-to-ERC20 swaps and ERC20-to-NFT swaps.
     * @param inputAmount The amount of ERC20 tokens to add to the ERC20-to-NFT swaps
     * @param minOutput The minimum acceptable total excess tokens received
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return outputAmount The total ERC20 tokens received
     */
    function swapNFTsForSpecificNFTsThroughERC20(
        NFTsForSpecificNFTsTrade calldata trade,
        uint256 inputAmount,
        uint256 minOutput,
        address nftRecipient,
        uint256 deadline
    ) external checkDeadline(deadline) returns (uint256 outputAmount) {
        // Swap NFTs for ERC20
        // minOutput of swap set to 0 since we're doing an aggregate slippage check
        // output tokens are sent to msg.sender
        outputAmount = _swapNFTsForToken(trade.nftToTokenTrades, 0, payable(msg.sender));

        // Add extra value to buy NFTs
        outputAmount += inputAmount;

        // Swap ERC20 for specific NFTs
        // cost <= maxCost = outputAmount - minOutput, so outputAmount' = outputAmount - cost >= minOutput
        // input tokens are taken directly from msg.sender
        outputAmount =
            _swapERC20ForSpecificNFTs(trade.tokenToNFTTrades, outputAmount - minOutput, nftRecipient) + minOutput;
    }

    /**
     * Robust Swaps
     * These are "robust" versions of the NFT<>Token swap functions which will never revert due to slippage
     * Instead, users specify a per-swap max cost. If the price changes more than the user specifies, no swap is attempted. This allows users to specify a batch of swaps, and execute as many of them as possible.
     */

    /**
     * @dev Ensure msg.value >= sum of values in maxCostPerPair to make sure the transaction doesn't revert
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to buy from each.
     * @param ethRecipient The address that will receive the unspent ETH input
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return remainingValue The unspent token amount
     */
    function robustSwapETHForSpecificNFTs(
        RobustPairSwapSpecific[] calldata swapList,
        address payable ethRecipient,
        address nftRecipient,
        uint256 deadline
    ) public payable virtual checkDeadline(deadline) returns (uint256 remainingValue) {
        remainingValue = msg.value;
        uint256 pairCost;
        CurveErrorCodes.Error error;

        // Try doing each swap
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            // Calculate actual cost per swap
            (error,,, pairCost,,) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.nftIds[0], swapList[i].swapInfo.nftIds.length
            );

            // If within our maxCost and no error, proceed
            if (pairCost <= swapList[i].maxCost && error == CurveErrorCodes.Error.OK) {
                // We know how much ETH to send because we already did the math above
                // So we just send that much
                remainingValue -= swapList[i].swapInfo.pair.swapTokenForSpecificNFTs{value: pairCost}(
                    swapList[i].swapInfo.nftIds, pairCost, nftRecipient, true, msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }

        // Return remaining value to sender
        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    /**
     * @notice Swaps as many ERC20 tokens for specific NFTs as possible, respecting the per-swap max cost.
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to buy from each.
     * @param inputAmount The amount of ERC20 tokens to add to the ERC20-to-NFT swaps
     * @param nftRecipient The address that will receive the NFT output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return remainingValue The unspent token amount
     */
    function robustSwapERC20ForSpecificNFTs(
        RobustPairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address nftRecipient,
        uint256 deadline
    ) public virtual checkDeadline(deadline) returns (uint256 remainingValue) {
        remainingValue = inputAmount;
        uint256 pairCost;
        CurveErrorCodes.Error error;

        // Try doing each swap
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            // Calculate actual cost per swap
            (error,,, pairCost,,) = swapList[i].swapInfo.pair.getBuyNFTQuote(
                swapList[i].swapInfo.nftIds[0], swapList[i].swapInfo.nftIds.length
            );

            // If within our maxCost and no error, proceed
            if (pairCost <= swapList[i].maxCost && error == CurveErrorCodes.Error.OK) {
                remainingValue -= swapList[i].swapInfo.pair.swapTokenForSpecificNFTs(
                    swapList[i].swapInfo.nftIds, pairCost, nftRecipient, true, msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Swaps as many NFTs for tokens as possible, respecting the per-swap min output
     * @param swapList The list of pairs to trade with and the IDs of the NFTs to sell to each.
     * @param tokenRecipient The address that will receive the token output
     * @param deadline The Unix timestamp (in seconds) at/after which the swap will revert
     * @return outputAmount The total ETH/ERC20 received
     */
    function robustSwapNFTsForToken(
        RobustPairSwapSpecificForToken[] calldata swapList,
        address payable tokenRecipient,
        uint256 deadline
    ) public virtual checkDeadline(deadline) returns (uint256 outputAmount) {
        // Try doing each swap
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            uint256 pairOutput;

            // Locally scoped to avoid stack too deep error
            {
                CurveErrorCodes.Error error;
                uint256[] memory nftIds = swapList[i].swapInfo.nftIds;
                if (nftIds.length == 0) {
                    unchecked {
                        ++i;
                    }
                    continue;
                }
                (error,,, pairOutput,,) = swapList[i].swapInfo.pair.getSellNFTQuote(nftIds[0], nftIds.length);
                if (error != CurveErrorCodes.Error.OK) {
                    unchecked {
                        ++i;
                    }
                    continue;
                }
            }

            // If at least equal to our minOutput, proceed
            if (pairOutput >= swapList[i].minOutput) {
                // Do the swap and update outputAmount with how many tokens we got
                outputAmount += swapList[i].swapInfo.pair.swapNFTsForToken(
                    swapList[i].swapInfo.nftIds, 0, tokenRecipient, true, msg.sender
                );
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Buys NFTs with ETH and sells them for tokens in one transaction
     * @param params All the parameters for the swap (packed in struct to avoid stack too deep), containing:
     * - ethToNFTSwapList The list of NFTs to buy
     * - nftToTokenSwapList The list of NFTs to sell
     * - inputAmount The max amount of tokens to send (if ERC20)
     * - tokenRecipient The address that receives tokens from the NFTs sold
     * - nftRecipient The address that receives NFTs
     * - deadline UNIX timestamp deadline for the swap
     */
    function robustSwapETHForSpecificNFTsAndNFTsToToken(RobustPairNFTsFoTokenAndTokenforNFTsTrade calldata params)
        external
        payable
        virtual
        returns (uint256 remainingValue, uint256 outputAmount)
    {
        {
            remainingValue = msg.value;
            uint256 pairCost;
            CurveErrorCodes.Error error;

            // Try doing each swap
            uint256 numSwaps = params.tokenToNFTTrades.length;
            for (uint256 i; i < numSwaps;) {
                // Calculate actual cost per swap
                (error,,, pairCost,,) = params.tokenToNFTTrades[i].swapInfo.pair.getBuyNFTQuote(
                    params.tokenToNFTTrades[i].swapInfo.nftIds[0], params.tokenToNFTTrades[i].swapInfo.nftIds.length
                );

                // If within our maxCost and no error, proceed
                if (pairCost <= params.tokenToNFTTrades[i].maxCost && error == CurveErrorCodes.Error.OK) {
                    // We know how much ETH to send because we already did the math above
                    // So we just send that much
                    remainingValue -= params.tokenToNFTTrades[i].swapInfo.pair.swapTokenForSpecificNFTs{value: pairCost}(
                        params.tokenToNFTTrades[i].swapInfo.nftIds, pairCost, params.nftRecipient, true, msg.sender
                    );
                }

                unchecked {
                    ++i;
                }
            }

            // Return remaining value to sender
            if (remainingValue > 0) {
                params.tokenRecipient.safeTransferETH(remainingValue);
            }
        }
        {
            // Try doing each swap
            uint256 numSwaps = params.nftToTokenTrades.length;
            for (uint256 i; i < numSwaps;) {
                uint256 pairOutput;

                // Locally scoped to avoid stack too deep error
                {
                    CurveErrorCodes.Error error;
                    uint256 assetId = params.nftToTokenTrades[i].swapInfo.nftIds[0];
                    (error,,, pairOutput,,) = params.nftToTokenTrades[i].swapInfo.pair.getSellNFTQuote(
                        assetId, params.nftToTokenTrades[i].swapInfo.nftIds.length
                    );
                    if (error != CurveErrorCodes.Error.OK) {
                        unchecked {
                            ++i;
                        }
                        continue;
                    }
                }

                // If at least equal to our minOutput, proceed
                if (pairOutput >= params.nftToTokenTrades[i].minOutput) {
                    // Do the swap and update outputAmount with how many tokens we got
                    outputAmount += params.nftToTokenTrades[i].swapInfo.pair.swapNFTsForToken(
                        params.nftToTokenTrades[i].swapInfo.nftIds, 0, params.tokenRecipient, true, msg.sender
                    );
                }

                unchecked {
                    ++i;
                }
            }
        }
    }

    /**
     * @notice Buys NFTs with ERC20, and sells them for tokens in one transaction
     * @param params All the parameters for the swap (packed in struct to avoid stack too deep), containing:
     * - ethToNFTSwapList The list of NFTs to buy
     * - nftToTokenSwapList The list of NFTs to sell
     * - inputAmount The max amount of tokens to send (if ERC20)
     * - tokenRecipient The address that receives tokens from the NFTs sold
     * - nftRecipient The address that receives NFTs
     * - deadline UNIX timestamp deadline for the swap
     */
    function robustSwapERC20ForSpecificNFTsAndNFTsToToken(RobustPairNFTsFoTokenAndTokenforNFTsTrade calldata params)
        external
        virtual
        returns (uint256 remainingValue, uint256 outputAmount)
    {
        {
            remainingValue = params.inputAmount;
            uint256 pairCost;
            CurveErrorCodes.Error error;

            // Try doing each swap
            uint256 numSwaps = params.tokenToNFTTrades.length;
            for (uint256 i; i < numSwaps;) {
                // Calculate actual cost per swap
                (error,,, pairCost,,) = params.tokenToNFTTrades[i].swapInfo.pair.getBuyNFTQuote(
                    params.tokenToNFTTrades[i].swapInfo.nftIds[0], params.tokenToNFTTrades[i].swapInfo.nftIds.length
                );

                // If within our maxCost and no error, proceed
                if (pairCost <= params.tokenToNFTTrades[i].maxCost && error == CurveErrorCodes.Error.OK) {
                    remainingValue -= params.tokenToNFTTrades[i].swapInfo.pair.swapTokenForSpecificNFTs(
                        params.tokenToNFTTrades[i].swapInfo.nftIds, pairCost, params.nftRecipient, true, msg.sender
                    );
                }

                unchecked {
                    ++i;
                }
            }
        }
        {
            // Try doing each swap
            uint256 numSwaps = params.nftToTokenTrades.length;
            for (uint256 i; i < numSwaps;) {
                uint256 pairOutput;

                // Locally scoped to avoid stack too deep error
                {
                    CurveErrorCodes.Error error;
                    uint256 assetId = params.nftToTokenTrades[i].swapInfo.nftIds[0];
                    (error,,, pairOutput,,) = params.nftToTokenTrades[i].swapInfo.pair.getSellNFTQuote(
                        assetId, params.nftToTokenTrades[i].swapInfo.nftIds.length
                    );
                    if (error != CurveErrorCodes.Error.OK) {
                        unchecked {
                            ++i;
                        }
                        continue;
                    }
                }

                // If at least equal to our minOutput, proceed
                if (pairOutput >= params.nftToTokenTrades[i].minOutput) {
                    // Do the swap and update outputAmount with how many tokens we got
                    outputAmount += params.nftToTokenTrades[i].swapInfo.pair.swapNFTsForToken(
                        params.nftToTokenTrades[i].swapInfo.nftIds, 0, params.tokenRecipient, true, msg.sender
                    );
                }

                unchecked {
                    ++i;
                }
            }
        }
    }

    receive() external payable {}

    /**
     * Restricted functions
     */

    /**
     * @dev Allows an ERC20 pair contract to transfer ERC20 tokens directly from
     * the sender, in order to minimize the number of token transfers. Only callable by an ERC20 pair.
     * @param token The ERC20 token to transfer
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     */
    function pairTransferERC20From(ERC20 token, address from, address to, uint256 amount) external {
        // verify caller is a trusted pair contract
        require(factory.isValidPair(msg.sender), "Not pair");
        // verify caller is an ERC20 pair
        require(factory.getPairTokenType(msg.sender) == ILSSVMPairFactoryLike.PairTokenType.ERC20, "Not ERC20 pair");

        // transfer tokens to pair
        token.safeTransferFrom(from, to, amount);
    }

    /**
     * @dev Allows a pair contract to transfer ERC721 NFTs directly from
     * the sender, in order to minimize the number of token transfers. Only callable by a pair.
     * @param nft The ERC721 NFT to transfer
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param id The ID of the NFT to transfer
     */
    function pairTransferNFTFrom(IERC721 nft, address from, address to, uint256 id) external {
        // verify caller is a trusted pair contract
        require(factory.isValidPair(msg.sender), "Not pair");

        // transfer NFTs to pair
        nft.transferFrom(from, to, id);
    }

    function pairTransferERC1155From(
        IERC1155 nft,
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external {
        // verify caller is a trusted pair contract
        require(factory.isValidPair(msg.sender), "Not pair");

        nft.safeBatchTransferFrom(from, to, ids, amounts, bytes(""));
    }

    /**
     * Internal functions
     */

    /**
     * @param deadline The last valid time for a swap
     */
    function _checkDeadline(uint256 deadline) internal view {
        require(block.timestamp <= deadline, "Deadline passed");
    }

    /**
     * @notice Internal function used to swap ETH for a specific set of NFTs
     * @param swapList The list of pairs and swap calldata
     * @param inputAmount The total amount of ETH to send
     * @param ethRecipient The address receiving excess ETH
     * @param nftRecipient The address receiving the NFTs from the pairs
     * @return remainingValue The unspent token amount
     */
    function _swapETHForSpecificNFTs(
        PairSwapSpecific[] calldata swapList,
        uint256 inputAmount,
        address payable ethRecipient,
        address nftRecipient
    ) internal virtual returns (uint256 remainingValue) {
        remainingValue = inputAmount;

        uint256 pairCost;
        CurveErrorCodes.Error error;

        // Do swaps
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            // Calculate the cost per swap first to send exact amount of ETH over, saves gas by avoiding the need to send back excess ETH
            (error,,, pairCost,,) = swapList[i].pair.getBuyNFTQuote(swapList[i].nftIds[0], swapList[i].nftIds.length);

            // Require no errors
            require(error == CurveErrorCodes.Error.OK, "Bonding curve error");

            // Total ETH taken from sender cannot exceed inputAmount
            // because otherwise the deduction from remainingValue will fail
            remainingValue -= swapList[i].pair.swapTokenForSpecificNFTs{value: pairCost}(
                swapList[i].nftIds, remainingValue, nftRecipient, true, msg.sender
            );

            unchecked {
                ++i;
            }
        }

        // Return remaining value to sender
        if (remainingValue > 0) {
            ethRecipient.safeTransferETH(remainingValue);
        }
    }

    /**
     * @notice Internal function used to swap an ERC20 token for specific NFTs
     * @dev Note that we don't need to query the pair's bonding curve first for pricing data because
     * we just calculate and take the required amount from the caller during swap time.
     * However, we can't "pull" ETH, which is why for the ETH->NFT swaps, we need to calculate the pricing info
     * to figure out how much the router should send to the pool.
     * @param swapList The list of pairs and swap calldata
     * @param inputAmount The total amount of ERC20 tokens to send
     * @param nftRecipient The address receiving the NFTs from the pairs
     * @return remainingValue The unspent token amount
     */
    function _swapERC20ForSpecificNFTs(PairSwapSpecific[] calldata swapList, uint256 inputAmount, address nftRecipient)
        internal
        virtual
        returns (uint256 remainingValue)
    {
        remainingValue = inputAmount;

        // Do swaps
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            // Tokens are transferred in by the pair calling router.pairTransferERC20From
            // Total tokens taken from sender cannot exceed inputAmount
            // because otherwise the deduction from remainingValue will fail
            remainingValue -= swapList[i].pair.swapTokenForSpecificNFTs(
                swapList[i].nftIds, remainingValue, nftRecipient, true, msg.sender
            );

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Swaps NFTs for tokens, designed to be used for 1 token at a time
     * @dev Calling with multiple tokens is permitted, BUT minOutput will be
     * far from enough of a safety check because different tokens almost certainly have different unit prices.
     * @param swapList The list of pairs and swap calldata
     * @param minOutput The minimum number of tokens to be receieved from the swaps
     * @param tokenRecipient The address that receives the tokens
     * @return outputAmount The number of tokens to be received
     */
    function _swapNFTsForToken(PairSwapSpecific[] calldata swapList, uint256 minOutput, address payable tokenRecipient)
        internal
        virtual
        returns (uint256 outputAmount)
    {
        // Do swaps
        uint256 numSwaps = swapList.length;
        for (uint256 i; i < numSwaps;) {
            // Do the swap for token and then update outputAmount
            // Note: minExpectedTokenOutput is set to 0 since we're doing an aggregate slippage check below
            outputAmount += swapList[i].pair.swapNFTsForToken(swapList[i].nftIds, 0, tokenRecipient, true, msg.sender);

            unchecked {
                ++i;
            }
        }

        // Aggregate slippage check
        require(outputAmount >= minOutput, "outputAmount too low");
    }
}

interface IPairHooks {
    function afterNewPair() external;

    // Also need to factor in new token balance and new NFT balance during calculations
    function afterSwapNFTInPair(
        uint256 _tokensOut,
        uint256 _tokensOutProtocolFee,
        uint256 _tokensOutRoyalty,
        uint256[] calldata _nftsIn
    ) external;

    // Also need to factor in new token balance and new NFT balance during calculations
    function afterSwapNFTOutPair(
        uint256 _tokensIn,
        uint256 _tokensInProtocolFee,
        uint256 _tokensInRoyalty,
        uint256[] calldata _nftsOut
    ) external;

    function afterDeltaUpdate(uint128 _oldDelta, uint128 _newDelta) external;

    function afterSpotPriceUpdate(uint128 _oldSpotPrice, uint128 _newSpotPrice) external;

    function afterFeeUpdate(uint96 _oldFee, uint96 _newFee) external;

    // Also need to factor in the new NFT balance
    function afterNFTWithdrawal(uint256[] calldata _nftsOut) external;

    // Also need to factor in the new token balance
    function afterTokenWithdrawal(uint256 _tokensOut) external;

    // NFT Deposit and Token Deposit are called from the Factory, not the Pair
    // So instead we have this catch-all for letting external callers (like the Factory) update state for a given pair
    function syncForPair(address pairAddress, uint256 _tokensIn, uint256[] calldata _nftsIn) external;
}

/**
 * @title An NFT/Token pair where the token is an ERC20
 * @author boredGenius, 0xmons, 0xCygaar
 */
abstract contract LSSVMPairERC20 is LSSVMPair {
    using SafeTransferLib for ERC20;

    error LSSVMPairERC20__RoyaltyNotPaid();
    error LSSVMPairERC20__MsgValueNotZero();
    error LSSVMPairERC20__AssetRecipientNotPaid();

    /**
     * @notice Returns the ERC20 token associated with the pair
     * @dev See LSSVMPairCloner for an explanation on how this works
     * @dev The last 20 bytes of the immutable data contain the ERC20 token address
     */
    function token() public pure returns (ERC20 _token) {
        assembly {
            _token := shr(0x60, calldataload(sub(calldatasize(), 20)))
        }
    }

    /**
     * @inheritdoc LSSVMPair
     */
    function _pullTokenInputs(
        uint256 inputAmountExcludingRoyalty,
        uint256[] memory royaltyAmounts,
        address payable[] memory royaltyRecipients,
        uint256, /* royaltyTotal */
        uint256 tradeFeeAmount,
        bool isRouter,
        address routerCaller,
        uint256 protocolFee
    ) internal override {
        address _assetRecipient = getAssetRecipient();

        // Transfer tokens
        inputAmountExcludingRoyalty -= protocolFee;
        if (isRouter) {
            // Verify if router is allowed
            // Locally scoped to avoid stack too deep
            ERC20 token_ = token();
            {
                (bool routerAllowed,) = factory().routerStatus(LSSVMRouter(payable(msg.sender)));
                if (!routerAllowed) revert LSSVMPair__NotRouter();
            }

            // Cache state and then call router to transfer tokens from user
            uint256 beforeBalance = token().balanceOf(_assetRecipient);
            LSSVMRouter(payable(msg.sender)).pairTransferERC20From(
                token_, routerCaller, _assetRecipient, inputAmountExcludingRoyalty
            );

            // Verify token transfer (protect pair against malicious router)
            if (token_.balanceOf(_assetRecipient) - beforeBalance != inputAmountExcludingRoyalty) {
                revert LSSVMPairERC20__AssetRecipientNotPaid();
            }

            // Transfer royalties (if they exist)
            for (uint256 i; i < royaltyRecipients.length;) {
                beforeBalance = token_.balanceOf(royaltyRecipients[i]);
                LSSVMRouter(payable(msg.sender)).pairTransferERC20From(
                    token_, routerCaller, royaltyRecipients[i], royaltyAmounts[i]
                );
                if (token_.balanceOf(royaltyRecipients[i]) - beforeBalance != royaltyAmounts[i]) {
                    revert LSSVMPairERC20__RoyaltyNotPaid();
                }
                unchecked {
                    ++i;
                }
            }

            // Take protocol fee (if it exists)
            if (protocolFee != 0) {
                LSSVMRouter(payable(msg.sender)).pairTransferERC20From(
                    token_, routerCaller, factory().getProtocolFeeRecipient(referralAddress), protocolFee
                );
            }
        } else {
            // Transfer tokens directly (sans the protocol fee)
            ERC20 token_ = token();
            token_.safeTransferFrom(msg.sender, _assetRecipient, inputAmountExcludingRoyalty);

            // Transfer royalties (if they exists)
            for (uint256 i; i < royaltyRecipients.length;) {
                token_.safeTransferFrom(msg.sender, royaltyRecipients[i], royaltyAmounts[i]);
                unchecked {
                    ++i;
                }
            }

            // Take protocol fee (if it exists)
            if (protocolFee != 0) {
                token_.safeTransferFrom(msg.sender, factory().getProtocolFeeRecipient(referralAddress), protocolFee);
            }
        }
        // Send trade fee if it exists, is TRADE pool, and fee recipient != pool address
        // @dev: (note that tokens are sent from the pool and not the caller)
        if (poolType() == PoolType.TRADE && tradeFeeAmount != 0) {
            address payable _feeRecipient = getFeeRecipient();
            if (_feeRecipient != _assetRecipient) {
                token().safeTransfer(_feeRecipient, tradeFeeAmount);
            }
        }
    }

    /**
     * @inheritdoc LSSVMPair
     */
    function _refundTokenToSender(uint256 inputAmount) internal override {
        // Do nothing since we transferred the exact input amount
    }

    /**
     * @inheritdoc LSSVMPair
     */
    function _sendTokenOutput(address payable tokenRecipient, uint256 outputAmount) internal override {
        // Send tokens to caller
        if (outputAmount != 0) {
            token().safeTransfer(tokenRecipient, outputAmount);
        }
    }

    /**
     * @inheritdoc LSSVMPair
     */
    function withdrawERC20(ERC20 a, uint256 amount) external override onlyOwner {
        a.safeTransfer(msg.sender, amount);

        if (a == token()) {
            if (address(hook) != address(0)) {
                hook.afterTokenWithdrawal(amount);
            }

            // emit event since it is the pair token
            emit TokenWithdrawal(amount);
        }
    }
}

/**
 * @title LSSVMPairERC721
 * @author boredGenius, 0xmons, 0xCygaar
 * @notice An NFT/Token pair for an ERC721 NFT
 */
abstract contract LSSVMPairERC721 is LSSVMPair {
    using EnumerableSet for EnumerableSet.UintSet;

    error LSSVMPairERC721__PropertyCheckFailed();
    error LSSVMPairERC721__NeedPropertyChecking();

    /**
     * @notice The NFT IDs held by this contract
     */
    EnumerableSet.UintSet private idSet;

    /**
     * External state-changing functions
     */

    /**
     * @inheritdoc LSSVMPair
     */
    function swapTokenForSpecificNFTs(
        uint256[] calldata nftIds,
        uint256 maxExpectedTokenInput,
        address nftRecipient,
        bool isRouter,
        address routerCaller
    ) external payable virtual override returns (uint256) {
        // Store locally to remove extra calls
        factory().openLock();

        // Input validation
        {
            PoolType _poolType = poolType();
            if (_poolType == PoolType.TOKEN) revert LSSVMPair__WrongPoolType();
            if (nftIds.length == 0) revert LSSVMPair__ZeroSwapAmount();
        }

        // Call bonding curve for pricing information
        uint256 protocolFee;
        uint256 tradeFee;
        uint256 inputAmountExcludingRoyalty;
        (tradeFee, protocolFee, inputAmountExcludingRoyalty) =
            _calculateSwapInfoAndUpdatePoolParams(nftIds.length, bondingCurve(), factory(), true);

        // Calculate royalties
        (address payable[] memory royaltyRecipients, uint256[] memory royaltyAmounts, uint256 royaltyTotal) =
            calculateRoyaltiesView(nftIds[0], inputAmountExcludingRoyalty - protocolFee - tradeFee);

        // Revert if the input amount is too large
        if (royaltyTotal + inputAmountExcludingRoyalty > maxExpectedTokenInput) {
            revert LSSVMPair__DemandedInputTooLarge();
        }

        _pullTokenInputs({
            inputAmountExcludingRoyalty: inputAmountExcludingRoyalty,
            royaltyAmounts: royaltyAmounts,
            royaltyRecipients: royaltyRecipients,
            royaltyTotal: royaltyTotal,
            tradeFeeAmount: 2 * tradeFee,
            isRouter: isRouter,
            routerCaller: routerCaller,
            protocolFee: protocolFee
        });

        {
            _sendSpecificNFTsToRecipient(IERC721(nft()), nftRecipient, nftIds);
            syncNFTIds(nftIds);
        }

        _refundTokenToSender(royaltyTotal + inputAmountExcludingRoyalty);

        if (address(hook) != address(0)) {
            _afterSwapNFTOutPairHook(
                afterSwapNFTOutPairArgs({
                    _tokensIn: royaltyTotal + inputAmountExcludingRoyalty,
                    _tokensInProtocolFee: protocolFee,
                    _tokensInRoyalty: royaltyTotal,
                    _nftsOut: nftIds
                })
            );
        }

        factory().closeLock();

        emit SwapNFTOutPair(royaltyTotal + inputAmountExcludingRoyalty, nftIds, royaltyTotal);

        return (royaltyTotal + inputAmountExcludingRoyalty);
    }

    struct afterSwapNFTOutPairArgs {
        uint256 _tokensIn;
        uint256 _tokensInProtocolFee;
        uint256 _tokensInRoyalty;
        uint256[] _nftsOut;
    }

    function _afterSwapNFTOutPairHook(afterSwapNFTOutPairArgs memory args) internal {
        hook.afterSwapNFTOutPair(args._tokensIn, args._tokensInProtocolFee, args._tokensInRoyalty, args._nftsOut);
    }

    /**
     * @inheritdoc LSSVMPair
     */
    function swapNFTsForToken(
        uint256[] calldata nftIds,
        uint256 minExpectedTokenOutput,
        address payable tokenRecipient,
        bool isRouter,
        address routerCaller
    ) external virtual override returns (uint256 outputAmount) {
        if (propertyChecker() != address(0)) revert LSSVMPairERC721__NeedPropertyChecking();

        return _swapNFTsForToken(nftIds, minExpectedTokenOutput, tokenRecipient, isRouter, routerCaller);
    }

    /**
     * @notice Sends a set of NFTs to the pair in exchange for token
     * @dev To compute the amount of token to that will be received, call bondingCurve.getSellInfo.
     * @param nftIds The list of IDs of the NFTs to sell to the pair
     * @param minExpectedTokenOutput The minimum acceptable token received by the sender. If the actual
     * amount is less than this value, the transaction will be reverted.
     * @param tokenRecipient The recipient of the token output
     * @param isRouter True if calling from LSSVMRouter, false otherwise. Not used for
     * ETH pairs.
     * @param routerCaller If isRouter is true, ERC20 tokens will be transferred from this address. Not used for
     * ETH pairs.
     * @param propertyCheckerParams Parameters to pass into the pair's underlying property checker
     * @return outputAmount The amount of token received
     */
    function swapNFTsForToken(
        uint256[] calldata nftIds,
        uint256 minExpectedTokenOutput,
        address payable tokenRecipient,
        bool isRouter,
        address routerCaller,
        bytes calldata propertyCheckerParams
    ) external virtual returns (uint256 outputAmount) {
        if (!IPropertyChecker(propertyChecker()).hasProperties(nftIds, propertyCheckerParams)) {
            revert LSSVMPairERC721__PropertyCheckFailed();
        }

        return _swapNFTsForToken(nftIds, minExpectedTokenOutput, tokenRecipient, isRouter, routerCaller);
    }

    /**
     * View functions
     */

    /**
     * @notice Returns the property checker address
     */
    function propertyChecker() public pure returns (address _propertyChecker) {
        uint256 paramsLength = _immutableParamsLength();
        assembly {
            _propertyChecker := shr(0x60, calldataload(add(sub(calldatasize(), paramsLength), 61)))
        }
    }

    /**
     * Internal functions
     */

    function _swapNFTsForToken(
        uint256[] calldata nftIds,
        uint256 minExpectedTokenOutput,
        address payable tokenRecipient,
        bool isRouter,
        address routerCaller
    ) internal virtual returns (uint256 outputAmount) {
        // Store locally to remove extra calls
        ILSSVMPairFactoryLike _factory = factory();

        _factory.openLock();

        // Input validation
        {
            PoolType _poolType = poolType();
            if (_poolType == PoolType.NFT) revert LSSVMPair__WrongPoolType();
            if (nftIds.length == 0) revert LSSVMPair__ZeroSwapAmount();
        }

        // Call bonding curve for pricing information
        uint256 protocolFee;
        (, protocolFee, outputAmount) = _calculateSwapInfoAndUpdatePoolParams(nftIds.length, bondingCurve(), _factory, false);

        // Compute royalties
        (address payable[] memory royaltyRecipients, uint256[] memory royaltyAmounts, uint256 royaltyTotal) =
            calculateRoyaltiesView(nftIds[0], outputAmount);

        // Deduct royalties from outputAmount
        unchecked {
            // Safe because we already require outputAmount >= royaltyTotal in calculateRoyalties()
            outputAmount -= royaltyTotal;
        }

        if (outputAmount < minExpectedTokenOutput) revert LSSVMPair__OutputTooSmall();

        _takeNFTsFromSender(IERC721(nft()), nftIds, _factory, isRouter, routerCaller);
        syncNFTIds(nftIds);

        _sendTokenOutput(tokenRecipient, outputAmount);
        for (uint256 i; i < royaltyRecipients.length;) {
            _sendTokenOutput(royaltyRecipients[i], royaltyAmounts[i]);
            unchecked {
                ++i;
            }
        }

        _sendTokenOutput(payable(factory().getProtocolFeeRecipient(referralAddress)), protocolFee);

        if (address(hook) != address(0)) {
            _afterSwapNFTInPairHook(
                afterSwapNFTInPairArgs({
                    _tokensOut: outputAmount,
                    _tokensOutProtocolFee: protocolFee,
                    _tokensOutRoyalty: royaltyTotal,
                    _nftsIn: nftIds
                })
            );
        }

        _factory.closeLock();

        emit SwapNFTInPair(outputAmount, nftIds, royaltyTotal);
    }

    struct afterSwapNFTInPairArgs {
        uint256 _tokensOut;
        uint256 _tokensOutProtocolFee;
        uint256 _tokensOutRoyalty;
        uint256[] _nftsIn;
    }

    function _afterSwapNFTInPairHook(afterSwapNFTInPairArgs memory args) internal {
        hook.afterSwapNFTInPair(args._tokensOut, args._tokensOutProtocolFee, args._tokensOutRoyalty, args._nftsIn);
    }

    /**
     * @notice Sends specific NFTs to a recipient address
     * @dev Even though we specify the NFT address here, this internal function is only
     * used to send NFTs associated with this specific pool.
     * @param _nft The address of the NFT to send
     * @param nftRecipient The receiving address for the NFTs
     * @param nftIds The specific IDs of NFTs to send
     */
    function _sendSpecificNFTsToRecipient(IERC721 _nft, address nftRecipient, uint256[] calldata nftIds)
        internal
        virtual
    {
        // Send NFTs to recipient
        for (uint256 i; i < nftIds.length;) {
            _nft.transferFrom(address(this), nftRecipient, nftIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Takes NFTs from the caller and sends them into the pair's asset recipient
     * @dev This is used by the LSSVMPair's swapNFTForToken function.
     * @param _nft The NFT collection to take from
     * @param nftIds The specific NFT IDs to take
     * @param isRouter True if calling from LSSVMRouter, false otherwise. Not used for ETH pairs.
     * @param routerCaller If isRouter is true, ERC20 tokens will be transferred from this address. Not used for ETH pairs.
     */
    function _takeNFTsFromSender(
        IERC721 _nft,
        uint256[] calldata nftIds,
        ILSSVMPairFactoryLike _factory,
        bool isRouter,
        address routerCaller
    ) internal virtual {
        {
            address _assetRecipient = getAssetRecipient();
            uint256 numNFTs = nftIds.length;

            if (isRouter) {
                // Verify if router is allowed
                LSSVMRouter router = LSSVMRouter(payable(msg.sender));
                (bool routerAllowed,) = _factory.routerStatus(router);
                if (!routerAllowed) revert LSSVMPair__NotRouter();

                // Call router to pull NFTs
                // Pull each asset 1 at a time and verify ownership
                for (uint256 i; i < numNFTs;) {
                    router.pairTransferNFTFrom(_nft, routerCaller, _assetRecipient, nftIds[i]);
                    if (_nft.ownerOf(nftIds[i]) != _assetRecipient) revert LSSVMPair__NftNotTransferred();
                    unchecked {
                        ++i;
                    }
                }
            } else {
                // Pull NFTs directly from sender
                for (uint256 i; i < numNFTs;) {
                    _nft.transferFrom(msg.sender, _assetRecipient, nftIds[i]);
                    unchecked {
                        ++i;
                    }
                }
            }
        }
    }

    /**
     * Owner functions
     */

    /**
     * @notice Rescues a specified set of NFTs owned by the pair to the owner address. (onlyOwner modifier is in the implemented function)
     * @param a The NFT to transfer
     * @param nftIds The list of IDs of the NFTs to send to the owner
     */
    function withdrawERC721(IERC721 a, uint256[] calldata nftIds) external virtual override onlyOwner {
        for (uint256 i; i < nftIds.length;) {
            a.safeTransferFrom(address(this), msg.sender, nftIds[i]);
            unchecked {
                ++i;
            }
        }

        if (a == IERC721(nft())) {
            syncNFTIds(nftIds);

            if (address(hook) != address(0)) {
                hook.afterNFTWithdrawal(nftIds);
            }

            emit NFTWithdrawal(nftIds);
        }
    }

    /**
     * @notice Rescues ERC1155 tokens from the pair to the owner. Only callable by the owner.
     * @param a The NFT to transfer
     * @param ids The NFT ids to transfer
     * @param amounts The amounts of each id to transfer
     */
    function withdrawERC1155(IERC1155 a, uint256[] calldata ids, uint256[] calldata amounts)
        external
        virtual
        override
        onlyOwner
    {
        a.safeBatchTransferFrom(address(this), msg.sender, ids, amounts, "");
    }

    /**
     * @notice Syncs the ID set based on ownership checking
     * @param ids The NFT IDs to transfer
     */
    function syncNFTIds(uint256[] calldata ids) public {
        for (uint256 i; i < ids.length;) {
            if (IERC721(nft()).ownerOf(ids[i]) == address(this)) {
                idSet.add(ids[i]);
            } else {
                idSet.remove(ids[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    function numIdsHeld() public view returns (uint256) {
        return idSet.length();
    }

    function hasId(uint256 id) public view returns (bool) {
        return idSet.contains(id);
    }

    function getAllIds() public view returns (uint256[] memory ids) {
        return getIds(0, numIdsHeld());
    }

    function getIds(uint256 start, uint256 end) public view returns (uint256[] memory ids) {
        uint256 length = end - start;
        ids = new uint256[](length);
        for (uint256 i; i < length;) {
            ids[i] = idSet.at(start + i);
            unchecked {
                ++i;
            }
        }
    }
}

/**
 * @title An NFT/Token pair where the token is an ERC20
 * @author boredGenius, 0xmons, 0xCygaar
 */
contract LSSVMPairERC721ERC20 is LSSVMPairERC721, LSSVMPairERC20 {
    uint256 internal constant IMMUTABLE_PARAMS_LENGTH = 101;

    /**
     * Public functions
     */

    /**
     * @inheritdoc LSSVMPair
     */
    function pairVariant() public pure override returns (ILSSVMPairFactoryLike.PairVariant) {
        return ILSSVMPairFactoryLike.PairVariant.ERC721_ERC20;
    }

    /**
     * Internal functions
     */

    /**
     * @inheritdoc LSSVMPair
     * @dev see LSSVMPairCloner for params length calculation
     */
    function _immutableParamsLength() internal pure override returns (uint256) {
        return IMMUTABLE_PARAMS_LENGTH;
    }
}

