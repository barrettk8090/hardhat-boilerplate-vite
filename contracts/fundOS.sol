//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

// We import this library to be able to use console.log
import "hardhat/console.sol";

contract fundOS {
    //Define a struct to hold project details
    struct Project {
        address payable owner; //Owners address who has created the project
        uint fundingGoal; //Funding goal for the project
        uint deadline; //Deadline for the project - when it must be funded by
        uint totalFunded; //Total amount of funds collected for the project
        bool isFunded; //Flag indicating whether the project has been funded
    }

    //Map to associate each project with a unique identifier 
    mapping(uint => Project) public projects;
    //Counter to keep track of the total number of projects
    uint public projectCount = 0;

    //Function to create a new project
    function createProject(uint _fundingGoal, uint _deadline) public{
        //Add a new project to the mappingwith the incremented project count as the key
        projects[projectCount++] = Project({
            owner: payable(msg.sender), // Set the owner of the project to the sender of the transaction
            fundingGoal: _fundingGoal, //Set the funding goal for the project
            deadline: _deadline, //Set the project deadline
            totalFunded: 0, //Initialise the totalFunded to 0
            isFunded: false //Initialise the isFunded flag to false- sets the project to indicate that it has not yet been funded.
        });
    }

    //Function to fund a project
    function fundProject(uint _projectId) public payable {
        //Get a reference to a project in storage
        Project storage project = projects[_projectId];
        //Require that the project is not yet funded and the current time is before the deadline 
        require(!project.isFunded && block.timestamp <= project.deadline, "Cannot fund this project.");
        //Require that the total funded plus the current contribution does not exceed the funding goal
        require(project.totalFunded + msg.value >= project.fundingGoal, "Exceeds funding goal");
        // Add the current contribution to the total funded for the project
        project.totalFunded += msg.value;
        //If the total dunded amount equals the funding goal, set the project to funded and TRANSFER THE FUNDS TO THE PROJECT OWNER.
        if (project.totalFunded == project.fundingGoal){
            project.owner.transfer(project.totalFunded); //Transfer the total amount to the project owner
            project.isFunded = true; //Mark the project as funded 
        } 
    }

    //Function to return funds to contributors if a project does not meet its funding goal by the deadline 
    function returnFunds(uint _projectId) public {
        //Get a reference to a project in storage
        Project storage project = projects[_projectId];
        //Require that the project is not funded and the current time is past the deadline 
        require(project.isFunded == false && block.timestamp > project.deadline, "Cannot return funds at this time.");
        // Store the total amount of funds that will be returned to contributors
        uint amount = project.totalFunded;
        // Reset the total funded amount of the project to 0
        project.totalFunded = 0;
        // Transfer the total amount to the caller 
        payable(msg.sender).transfer(amount);
    }
}
