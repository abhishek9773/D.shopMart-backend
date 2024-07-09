
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DshopMart is ReentrancyGuard{
    address public onwer;

    struct Product{
        uint256 id;
        string name;
        string category;
        string image;
        uint256 price;
        uint256 rating;
        uint256 stock;


    }

    struct Order{
        uint256 time;
        Product product;
    }

    mapping (uint256 => Product) public products;
    mapping (address => mapping (uint256 => Order)) public orders;
    mapping (address => uint256) public orderCount;


    event Buy(address customer, uint256 orderId, uint256 productId);
    event List(string name, uint256 price, uint256 quantity);

    modifier onlyOwner(){
        require(msg.sender == onwer,"need owner authority!");
        _;
    }

    constructor(){
        onwer = msg.sender;
    }

    function list( 
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _price,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        products[_id] = Product(_id,_name,_category,_image,_price,_rating,_stock);
        
        emit List(_name, _price, _stock);

    }

    function buy(uint256 _id) public payable {
        Product memory _product = products[_id];

        require(msg.value >= _product.price);
        require(_product.stock >= 1);
        Order memory _order = Order(block.timestamp, _product);
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = _order;

        products[_id].stock = _product.stock- 1;

        emit Buy(msg.sender, orderCount[msg.sender], _product.id);



    }

    function withdraw() public onlyOwner nonReentrant{
        uint256 balance = address(this).balance;
        require(balance > 0, "No found to withdraw ");
        (bool success,) = onwer.call{value:balance}("");
        require(success,"Transfer failed");
        
    }

}