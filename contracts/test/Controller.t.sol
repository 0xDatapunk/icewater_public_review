// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./utils/vm.sol";
import "./console.sol";
import "../Controller.sol";
import "../tokens/H2OToken.sol";
import "../tokens/IceToken.sol";
import "../tokens/SteamToken.sol";

contract ControllerTest is DSTest {
    using UFixedPoint for uint256;
    using SFixedPoint for int256;

    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address constant admin = address(uint160(uint256(keccak256('icewater admin'))));
    
    IceToken iceToken;
    H2OToken h2oToken;
    SteamToken stmToken;
    Controller controller;
    function setUp() public {                
        // console.log("here"); 
        h2oToken = new H2OToken(admin);
        iceToken = new IceToken(admin);
        stmToken = new SteamToken(admin);
        controller = new Controller(iceToken, h2oToken, stmToken);

        vm.startPrank(admin);    
        h2oToken.grantRole(h2oToken.DEFAULT_ADMIN_ROLE(), address(controller));
        iceToken.grantRole(iceToken.DEFAULT_ADMIN_ROLE(), address(controller));
        stmToken.grantRole(stmToken.DEFAULT_ADMIN_ROLE(), address(controller));
        vm.stopPrank();  
        controller.initTokenRoles();
    }

    function testInitial() public {       
        console.log(controller.getTargetICEPrice(), D_INITIAL_ICE_PRICE, "getTargetICEPrice <-> initial");

        console.log(controller.getICEPoolH2OSize(), D_INITIAL_ICE_POOL_H2O_SIZE, "getICEPoolH2OSize <-> initial");
        console.log(controller.getICEPoolICESize(), D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_PRICE), "getICEPoolICESize <-> initial");
        console.log(controller.getICEPrice(), D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_PRICE)), "getICEPrice <-> initial");
        
        console.log(controller.getSTMPoolH2OSize(), D_INITIAL_STM_POOL_H2O_SIZE, "getSTMPoolH2OSize <-> initial");
        console.log(controller.getSTMPoolSTMSize(), D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_PRICE), "getSTMPoolSTMSize <-> initial");
        console.log(controller.getSTMPrice(), D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_PRICE)), "getSTMPrice <-> initial");
        assertTrue(true);
    }

    function testPreviewSwapICEForH2O(uint256 dAmount) public {
        vm.assume(dAmount < 1 ether);
        uint256 a;
        uint256 b;
        a = controller.previewSwapH2OForICE(dAmount);
        b = controller.getICEPoolICESize().mul(dAmount).div(controller.getICEPoolH2OSize() + dAmount);
        console.log(a, b, "testPreviewSwapICEForH2O");

        a = controller.previewSwapICEForH2O(dAmount);
        b = controller.getICEPoolH2OSize().mul(dAmount).div(controller.getICEPoolICESize() + dAmount);
        console.log(a, b, "testPreviewSwapICEForH2O");

        a = controller.previewSwapH2OForSTM(dAmount);
        b = controller.getSTMPoolSTMSize().mul(dAmount).div(controller.getSTMPoolH2OSize() + dAmount);
        console.log(a, b, "testPreviewSwapICEForH2O");

        a = controller.previewSwapSTMForH2O(dAmount);
        b = controller.getSTMPoolH2OSize().mul(dAmount).div(controller.getSTMPoolSTMSize() + dAmount);
        console.log(a, b, "testPreviewSwapICEForH2O");

        require(a==b);
    }

    function testSwapH2OForICE(uint256 dAmount) public {   
        vm.assume(dAmount < h2oToken.balanceOf(address(this)));

        console.log(h2oToken.balanceOf(address(this)), "sender balance");
        uint _poolSizeA = controller.getICEPoolH2OSize();
        console.log(_poolSizeA, "_poolSizeA");
        uint _poolSizeB = controller.getICEPoolICESize();
        console.log(_poolSizeB, "_poolSizeB");

        // uint dAmount = 10000000000000000000000000;
        uint a = controller.getICEPoolICESize().mul(dAmount).div(controller.getICEPoolH2OSize() + dAmount);
        uint b = controller.swapH2OForICE(dAmount);         

        console.log(dAmount, "dAmount");
        console.log(a, "a");
        console.log(b, "b");

        uint poolSizeA_ = controller.getICEPoolH2OSize();
        console.log(poolSizeA_, _poolSizeA+dAmount, "poolSizeA_");
        uint poolSizeB_ = controller.getICEPoolICESize();
        console.log(poolSizeB_, _poolSizeB-a, "poolSizeB_");

        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_PRICE)), "getICEPrice <-> target <-> initial");

        require(a==b);
        require(poolSizeA_ == _poolSizeA+dAmount);
        require(poolSizeB_ == _poolSizeB-a);
    }

    // function testSwapICEForH2O() public {   
    function testSwapICEForH2O(uint256 dAmount) public {   
        vm.assume(dAmount < iceToken.balanceOf(address(this)));

        console.log(iceToken.balanceOf(address(this)), "sender balance");
        uint _poolSizeA = controller.getICEPoolH2OSize();
        console.log(_poolSizeA, "_poolSizeA");
        uint _poolSizeB = controller.getICEPoolICESize();
        console.log(_poolSizeB, "_poolSizeB");

        // uint dAmount = 1 ether;
        uint a = controller.getICEPoolH2OSize().mul(dAmount).div(controller.getICEPoolICESize() + dAmount);
        uint b = controller.swapICEForH2O(dAmount);         

        console.log(dAmount, "dAmount");
        console.log(a, "a");
        console.log(b, "b");

        uint poolSizeA_ = controller.getICEPoolH2OSize();
        console.log(poolSizeA_, _poolSizeA-a, "poolSizeA_");
        uint poolSizeB_ = controller.getICEPoolICESize();
        console.log(poolSizeB_, _poolSizeB+dAmount, "poolSizeB_");

        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_POOL_H2O_SIZE.div(D_INITIAL_ICE_PRICE)), "getICEPrice <-> target <-> initial");

        require(a==b);
        require(poolSizeA_ == _poolSizeA-a);
        require(poolSizeB_ == _poolSizeB+dAmount);
    }

    function testSwapH2OForSTM(uint256 dAmount) public {   
        vm.assume(dAmount < h2oToken.balanceOf(address(this)));

        console.log(h2oToken.balanceOf(address(this)), "sender balance");
        uint _poolSizeA = controller.getSTMPoolH2OSize();
        console.log(_poolSizeA, "_poolSizeA");
        uint _poolSizeB = controller.getSTMPoolSTMSize();
        console.log(_poolSizeB, "_poolSizeB");

        // uint dAmount = 10000000000000000000000000;
        uint a = controller.getSTMPoolSTMSize().mul(dAmount).div(controller.getSTMPoolH2OSize() + dAmount);
        uint b = controller.swapH2OForSTM(dAmount);         

        console.log(dAmount, "dAmount"); 
        console.log(a, "a");
        console.log(b, "b");

        uint poolSizeA_ = controller.getSTMPoolH2OSize();
        console.log(poolSizeA_, _poolSizeA+dAmount, "poolSizeA_");
        uint poolSizeB_ = controller.getSTMPoolSTMSize();
        console.log(poolSizeB_, _poolSizeB-a, "poolSizeB_");

        console.log(controller.getSTMPrice(), D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_PRICE)), "getSTMPrice <-> initial");

        require(a==b);
        require(poolSizeA_ == _poolSizeA+dAmount);
        require(poolSizeB_ == _poolSizeB-a);
    }

    // function testSwapSTMForH2O() public {   
    function testSwapSTMForH2O(uint256 dAmount) public {   
        vm.assume(dAmount < stmToken.balanceOf(address(this)));

        console.log(stmToken.balanceOf(address(this)), "sender balance");
        uint _poolSizeA = controller.getSTMPoolH2OSize();
        console.log(_poolSizeA, "_poolSizeA");
        uint _poolSizeB = controller.getSTMPoolSTMSize();
        console.log(_poolSizeB, "_poolSizeB");

        // uint dAmount = 1 ether;
        uint a = controller.getSTMPoolH2OSize().mul(dAmount).div(controller.getSTMPoolSTMSize() + dAmount);
        uint b = controller.swapSTMForH2O(dAmount);         

        console.log(dAmount, "dAmount");
        console.log(a, "a");
        console.log(b, "b");

        uint poolSizeA_ = controller.getSTMPoolH2OSize();
        console.log(poolSizeA_, _poolSizeA-a, "poolSizeA_");
        uint poolSizeB_ = controller.getSTMPoolSTMSize();
        console.log(poolSizeB_, _poolSizeB+dAmount, "poolSizeB_");

        console.log(controller.getSTMPrice(), D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_POOL_H2O_SIZE.div(D_INITIAL_STM_PRICE)), "getSTMPrice <-> initial");

        require(a==b);
        require(poolSizeA_ == _poolSizeA-a);
        require(poolSizeB_ == _poolSizeB+dAmount);
    }

    function testUpdateError() public {
        uint dAmount = 1 ether;
    }

    function testSwapH2OForICE_flashloan() public {  
    // function testSwapH2OForICE_backNforth(uint256 dAmount) public {  
        uint256 dAmount;
        dAmount = 400000000000000000;
        console.log(controller.getICEPoolICESize()/dAmount, "getICEPoolICESize");

        dAmount = controller.swapICEForH2O(dAmount);              
        console.log(dAmount, "swaped to");

        dAmount = controller.swapH2OForICE(dAmount);  
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");

        // flashloan
        dAmount = 50000000000000000000000;
        console.log(controller.getICEPoolH2OSize()/dAmount, "getICEPoolH20Size");
        // dAmount = controller.swapICEForH2O(dAmount);              
        uint256 dAmount_H2O = controller.swapH2OForICE(dAmount);              
        
        dAmount = 400000000000000000;
        uint256 dAmount1 = controller.swapICEForH2O(dAmount);              
        console.log(dAmount1, "swaped to");
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");
        
        dAmount = controller.swapICEForH2O(dAmount_H2O);  
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");
            
        console.log(controller.getICEPoolH2OSize(), controller.getICEPoolICESize());

        console.log(block.timestamp);
        vm.warp(block.timestamp + 10);
        console.log(block.timestamp);
    }
    function testSwapICEForH2O_flashloan() public {  
    // function testSwapH2OForICE_backNforth(uint256 dAmount) public {  
        uint256 dAmount;
        dAmount = 10000000000000000000;
        console.log(controller.getICEPoolH2OSize()/dAmount, "getICEPoolH2OSize");

        dAmount = controller.swapH2OForICE(dAmount);             
        console.log(dAmount, "swaped to");

        dAmount = controller.swapICEForH2O(dAmount);  
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");

        // flashloan
        dAmount = 2000000000000000000000;
        console.log(controller.getICEPoolICESize()/dAmount, "getICEPoolICESize");
        uint256 dAmount_H2O = controller.swapICEForH2O(dAmount);              

        dAmount = 10000000000000000000;
        dAmount = controller.swapH2OForICE(dAmount);             
        console.log(dAmount, "swaped to");
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");
        
        dAmount = controller.swapH2OForICE(dAmount_H2O); 
        console.log(controller.getICEPrice(), controller.getTargetICEPrice(), "icePrice <-> targetPrice");
            
        console.log(controller.getICEPoolH2OSize(), controller.getICEPoolICESize());

        console.log(block.timestamp);
        vm.warp(block.timestamp + 10);
        console.log(block.timestamp);
    }


    function testSwapH2OForSTM_flashloan() public {  
    // function testSwapH2OForICE_backNforth(uint256 dAmount) public {  
        uint256 dAmount;
        dAmount = 2000000000000000000;
        console.log(controller.getSTMPoolSTMSize()/dAmount, "getSTMPoolSTMSize");

        dAmount = controller.swapSTMForH2O(dAmount);              
        console.log(dAmount, "swaped to");

        dAmount = controller.swapH2OForSTM(dAmount);  
        console.log(controller.getSTMPrice(), "stmPrice");

        // flashloan
        dAmount = 50000000000000000000000;
        console.log(controller.getSTMPoolH2OSize()/dAmount, "getSTMPoolH2OSize");
        // dAmount = controller.swapICEForH2O(dAmount);              
        uint256 dAmount_H2O = controller.swapH2OForSTM(dAmount);              

        dAmount = 2000000000000000000;
        dAmount = controller.swapSTMForH2O(dAmount);              
        console.log(dAmount, "swaped to");
        console.log(controller.getSTMPrice(), "stmPrice");
        
        dAmount = controller.swapSTMForH2O(dAmount_H2O);  
        console.log(controller.getSTMPrice(), "stmPrice");
            
        console.log(controller.getSTMPoolH2OSize(), controller.getSTMPoolSTMSize());

        console.log(block.timestamp);
        vm.warp(block.timestamp + 10);
        console.log(block.timestamp);
    }
    function testSwapSTMForH2O_flashloan() public {  
    // function testSwapH2OForSTM_backNforth(uint256 dAmount) public {  
        uint256 dAmount;
        dAmount = 10 ether;
        console.log(controller.getSTMPoolH2OSize()/dAmount, "getSTMPoolH2OSize");
        console.log(dAmount);

        dAmount = controller.swapH2OForSTM(dAmount);             
        console.log(dAmount, "swaped to");

        dAmount = controller.swapSTMForH2O(dAmount);  
        console.log(controller.getSTMPrice(), "stmPrice");

        // flashloan
        dAmount = 10000 ether;
        console.log(controller.getSTMPoolSTMSize()/dAmount, "getSTMPoolSTMSize");
        uint256 dAmount_H2O = controller.swapSTMForH2O(dAmount);              

        dAmount = 10 ether;
        dAmount = controller.swapH2OForSTM(dAmount);             
        console.log(dAmount, "swaped to");
        console.log(controller.getSTMPrice(), "stmPrice <-> targetPrice");
        
        dAmount = controller.swapH2OForSTM(dAmount_H2O); 
        console.log(controller.getSTMPrice(), "stmPrice <-> targetPrice");
            
        console.log(controller.getSTMPoolH2OSize(), controller.getSTMPoolSTMSize());

        console.log(block.timestamp);
        vm.warp(block.timestamp + 10);
        console.log(block.timestamp);
    }

    function testSTMPriceChange() public {
        int256 dSTMPrice = int256(controller.getSTMPrice()) - 0 ether;
        int256 dICEPrice = int256(controller.getICEPrice()) - 5 ether;
        console.logInt(dSTMPrice);
        console.logInt(dICEPrice);
        int256 dError = int256(dSTMPrice) - int256(controller.getTargetICEPrice());
        console.logInt(dError);
        int256 dPriceChange = dError.mul(D_STEAM_PRICE_FACTOR);
        console.logInt(dPriceChange);
        console.logInt(dPriceChange.mul(dSTMPrice).div(dICEPrice));
        int256 dPriceRatio = dSTMPrice.div(dICEPrice);
        console.logInt(dPriceRatio);
        dPriceChange = dPriceChange.mul(dPriceRatio);
        console.logInt(dPriceChange);
        uint256 iTimeDelta = 1 days;
        iTimeDelta = iTimeDelta.min(I_STM_PRICE_CHANGE_PERIOD);
        console.log(iTimeDelta.toDecimal());
        console.log(I_STM_PRICE_CHANGE_PERIOD);
        int256 dTimeRatio = int256(iTimeDelta.toDecimal() / I_STM_PRICE_CHANGE_PERIOD);
        dPriceChange = dTimeRatio.mul(dPriceChange);
        // calculate the target price
        uint256 dTargetSTMPrice = uint256(dSTMPrice + dPriceChange);
        console.logInt(dPriceChange);
        console.logUint(dTargetSTMPrice);
    }

    // dAccumError ^ -> dTargetCondensationRate ^
    function testCondensationRate() public {
        // conversions
        int256 dBaseCondensationRate = int256(D_INITIAL_CONDENSATION_RATE);
        int256 dCurrentCondensationRate = int256(D_INITIAL_CONDENSATION_RATE) - int256(D_INITIAL_CONDENSATION_RATE / 10);
        console.logUint(D_INITIAL_CONDENSATION_RATE);
        console.logInt(dCurrentCondensationRate);

        int256 dAccumError = 1000000000000000000000;
        //compute the change in the condensation rate
        int256 dVariableCondensationRate = dAccumError.mul(
            D_CONDENSATION_FACTOR);
        console.logInt(dVariableCondensationRate);

        // compute the target condensation rate
        int256 dTargetCondensationRate = dBaseCondensationRate +
            dVariableCondensationRate;
        console.logInt(dTargetCondensationRate);

        // compute the target change in condensation rate
        int dRateChange =  dTargetCondensationRate - dCurrentCondensationRate;
        console.logInt(dRateChange);

        uint256 iTimeDelta = 1 days;
        iTimeDelta = iTimeDelta.min(I_CONDENSATION_RATE_CHANGE_PERIOD);

        // compute the time ratio
        int256 dTimeRatio = int256(iTimeDelta.toDecimal() / I_CONDENSATION_RATE_CHANGE_PERIOD / 10);
        dRateChange = dTimeRatio.mul(dRateChange);
        console.logInt(dRateChange);

        // compute condensation rate
        int256 dNewCondensationRate = dCurrentCondensationRate + dRateChange;

        // prevent the condensation rate from going below 0
        dNewCondensationRate = dNewCondensationRate.max(0);
        console.logInt(dNewCondensationRate);
    }

    // function updateError() internal {
    //     //Avoid running PID multiple times in a block
    //     if (_iLastTime == block.timestamp) {
    //         return;
    //     }

    //     int256 iTimeDelta = int256(block.timestamp - _iLastTime);
    //     //Update last time (update before updating dAccumError to prevent reentrancy attack)
    //     _iLastTime = block.timestamp;

    //     // Calculate the errors.
    //     int256 dError = calculateError();
    //     int256 dAccumError = _dAccumError + dError * iTimeDelta;

    //     // Update errors
    //     _dLastError = dError;
    //     _dAccumError = dAccumError;     

    //     // Call the virtual function that applies the control variable.        
    //     applyError(dError, dAccumError, uint256(iTimeDelta));
    // }

    // function calculateError() internal override view returns (int256) {
    //     return int256(_icePool.priceB()) - int256(_dTargetICEPrice);
    // }

    // function applyError(
    //     int256 dError,
    //     int256 dAccumError,
    //     uint256 iTimeDelta
    // )
    //     internal override
    // {
    //     _updateSTMPrice(dError, iTimeDelta);
    //     _updateCondensationRate(dAccumError, iTimeDelta);
    //     _updateTargetICEPrice(dError, iTimeDelta);
    // }
}
