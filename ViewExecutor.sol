contract ViewExecutor {
  function query(address viewLogic, bytes memory payload) public returns (bytes memory) {
    bytes memory callData = abi.encodePacked(bytes4(keccak256("_executeQuery(address,bytes)")), abi.encode(viewLogic, payload));
    uint256 len = callData.length;
    uint256 size;
    bool success;
    assembly {
      success := staticcall(gas, address, callData, len, 0x0, 0x0)
      size := returndatasize
    }
    require(success);
    bytes memory data = new bytes(size);
    assembly {
      returndatacopy(add(data, 0x20), 0x0, size)
    }
    (bytes memory response) = abi.decode(data, (bytes));
    return response;
  }
  function _executeQuery(address delegateTo, bytes memory callData) public returns (bytes memory) {
    require(msg.sender == address(this));
    (bool success, bytes memory retval) = delegateTo.delegatecall(callData);
    require(success);
    return retval;
  }
}
