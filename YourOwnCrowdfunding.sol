//SPDX-License-Identifier: GPL:3.0

pragma solidity >=0.7.0 <0.9.0;

contract YourOwnCrowdfunding{

    //By running this contract you can create your own crowdfunding project

    enum enumstate{OPEN,CLOSED}         //This is the tool for pause/continue each project

    struct projectinfo{                 //This struct is going to contain all the info of 
        string name;                    // each project
        uint goal;
        address author;
        uint progress;
        enumstate state;
    }

    projectinfo[] projects;             //A list of all the projects that will be created



    mapping ( string => uint) projectposition;  //Allows to find each project by its name

    uint public ProjectQuantity;                //The quantity of the projects created

    event NewProject(                   //This event will notify us when a new project 
        string Name,                    // is created and its info
        uint Goal,
        address Creator
    );

    function CreateProject(string memory Name,uint Goal) public {   //This function will create 
                                                                    // a new crowdfunding project

        projectinfo memory newproject = projectinfo(Name,Goal,msg.sender,0,enumstate.OPEN);

        projects.push(newproject);

        ProjectQuantity += 1;

        projectposition[Name]= ProjectQuantity - 1;

        emit NewProject(Name,Goal,msg.sender);
    }



    modifier OnlyAuthor{                //The Author of each project will have 
        string memory ProjectName;      // some special permissions.
        require(
            msg.sender==projects[projectposition[ProjectName]].author,
            "Only the author of the project can run this function"
        );
        _;
    }

    modifier NoAutor{                   //For the actions each author shouldn't do
        string memory ProjectName;
        require(
            msg.sender!=projects[projectposition[ProjectName]].author,
            "The author of the project can't run this function"
        );
        _;
    }



    event Contribution(         //Notification of each contribution with its info
        string Project,
        uint Amount,
        uint ReachedAmount,
        uint MissingAmount,
        address Benefactor
    );

    function Contribute(string memory ProjectName) public payable NoAutor{      //Allow people to 
                                                                                // give money to  
                                                                                // each project just
                                                                                // by its name

        require (
            projects[projectposition[ProjectName]].progress < projects[projectposition[ProjectName]].goal,
            "The goal has been reached before"
        );

        require (
            msg.value <= projects[projectposition[ProjectName]].goal - projects[projectposition[ProjectName]].progress,
            "The amount exceeds the project goal"
        );

        require(
            projects[projectposition[ProjectName]].state != enumstate.CLOSED,
            "The project is currently closed"
        );

        address payable recipient = payable (projects[projectposition[ProjectName]].author);

        recipient.transfer(msg.value);

        projects[projectposition[ProjectName]].progress += msg.value;

        emit Contribution(          //Notification of the contribution
            ProjectName,
            msg.value,
            projects[projectposition[ProjectName]].progress,
            projects[projectposition[ProjectName]].goal - projects[projectposition[ProjectName]].progress,
            msg.sender
        );
    }



    event StateChange(              //Notification for every time a 
        string Project,             // creator pauses his project
        string State
    );

    function PauseProject(string memory ProjectName) public OnlyAuthor {        //Allow creators to 
                                                                                // pause/continue 
                                                                                // their projects

        if (projects[projectposition[ProjectName]].state == enumstate.OPEN){

            projects[projectposition[ProjectName]].state = enumstate.CLOSED;

            emit StateChange(ProjectName,"Paused");

        } else if (projects[projectposition[ProjectName]].state == enumstate.CLOSED){

            projects[projectposition[ProjectName]].state = enumstate.OPEN;

            emit StateChange(ProjectName,"Open");

        }
    }

}
