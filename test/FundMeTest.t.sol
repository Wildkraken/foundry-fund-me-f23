//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {

    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100e18);
    }

    function testDemo() public {

        assertEq(fundMe.getOwner(), msg.sender);

    }

    function testPriceFeedVersionIsAccurate() public {
        
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFunFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDatataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18);

    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testOnlyOwnerCanWithraw() public funded {

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithrawWithASingleFunder() public funded {
        //Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalence = address(fundMe).balance;

        //Act

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalence + startingOwnerBalance, endingOwnerBalance
        );
    }

    function testWithrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i<numberOfFunders; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
         uint256 startingFundMeBalence = address(fundMe).balance;

         vm.startPrank(fundMe.getOwner());
         fundMe.withdraw();
         vm.stopPrank();
         assert(address(fundMe).balance == 0);
         assert(
            startingFundMeBalence + startingOwnerBalance == fundMe.getOwner().balance
         );




    }

     function testWithrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i<numberOfFunders; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
         uint256 startingFundMeBalence = address(fundMe).balance;

         vm.startPrank(fundMe.getOwner());
         fundMe.cheaperWithraw();
         vm.stopPrank();
         assert(address(fundMe).balance == 0);
         assert(
            startingFundMeBalence + startingOwnerBalance == fundMe.getOwner().balance
         );




    }
}
