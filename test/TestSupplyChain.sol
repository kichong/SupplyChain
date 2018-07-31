pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
  SupplyChain supply = SupplyChain(DeployedAddresses.SupplyChain());
  uint public initialBalance = 10 ether;

    // Test for failing conditions in this contracts
    // test that every modifier is working
    function testOwnerIsMessageSender() {
      //  modifier verifyCaller (address _address) { require (msg.sender == _address); _;}
      Assert.equal(supply.owner(), msg.sender, "message sender and address should be equal");
    }


    // buyItem
    // test for failure if user does not send enough funds
    function testBuyItemNotEnoughFunds() {
      supply.addItem("cheddar", 1 ether);
      bool result = helperBuyItem(10 ether, 0);
      Assert.isFalse(result, "Should send enough funds");
    }

    // test for purchasing an item that is not for Sale
    function testBuyItemNotForSale() {
      supply.addItem("cheddar", 1 ether);
      helperBuyItem(1 ether, 0);
      bool result = helperBuyItem(1 ether, 0);
      Assert.isFalse(result, "should only buy item that is for sale");
    }

    // shipItem
    // test for calls that are made by not the seller
    function testCallsMadeByNotSeller() {
      SupplyChain sc = new SupplyChain();
      supply.addItem("cheddar", 1 ether);
      helperBuyItem(1 ether, 0);
      bool result = helperShipItem(address(sc), 0);
      Assert.isFalse(result, "Only seller can ship");

    }
    // test for trying to ship an item that is not marked Sold
    function testShipItemNotMarkedSold() {
      supply.addItem("cheddar", 1 ether);
      bool result = helperShipItem(address(supply), 0);
      Assert.isFalse(result, "Should not ship if not Sold");

    }

    // receiveItem
    // test calling the function from an address that is not the buyer
    function testOnlyBuyerCanReceiveItem() public {
      supply.shipItem(0);
      //buyer is this contract.
      //create new addr (new sc contract)
      //and call receiveItem() for sku =0 from testShipItemNotMarkedSold
      SupplyChain sc = new SupplyChain();
      bool result = helperReceiveItem(address(sc),0);
      Assert.isFalse(result, "Only buyer can receive the sold item");
    }

    // test calling the function on an item not marked Shipped
    function testReceiveItemNotShipped() {
      bool result = helperReceiveItem(address(supply), 0);
      Assert.isFalse(result, "Should not receive if not shipped");
    }


// HELPER METHODS
  function helperBuyItem(uint price, uint sku) public returns (bool r) {
    r = address(supply).call.value(price)(bytes4(keccak256("buyItem(uint)", uint(sku))));
  }

  function helperShipItem(address addr, uint sku) public returns (bool r) {
    r = address(addr).call(bytes4(sha3("shipItem(uint)", uint(sku))));
  }

  function helperReceiveItem(address addr, uint sku) public returns (bool r) {
    r = address(addr).call(bytes4(keccak256("receiveItem(uint)", uint(sku))));

  }



}
// Proxy contract for testing throws
/*
contract ThrowProxy {
  address public target;
  bytes data;

  function ThrowProxy(address _target) {
    target = _target;
  }

  //prime the data using the fallback function.
  function() {
    data = msg.data;
  }

  function execute(uint price) public returns (bool) {
    return target.call.value(price)(data);
  }
}*/
