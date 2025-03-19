-- Create Agent Table
CREATE TABLE Agent (
    AgentID INT PRIMARY KEY,
    Name NVARCHAR(255),
    Department NVARCHAR(255),
    Shift NVARCHAR(255)
);

-- Create CustomerService Table
CREATE TABLE CustomerService (
    InteractionID INT PRIMARY KEY,
    CustomerID INT,
    DateTime DATETIME,
    AgentID INT,
    IssueType NVARCHAR(255),
    ResolutionStatus NVARCHAR(255),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID)
);

-- Create Transaction Table
CREATE TABLE StoreTransaction (
    TransactionID INT PRIMARY KEY,
    CustomerID INT,
    StoreID INT,
    DateTime DATETIME,
    Amount DECIMAL(18, 2),
    PaymentMethod NVARCHAR(255)
);

-- Create Loyalty Table
CREATE TABLE Loyaltyacc (
    LoyaltyID INT PRIMARY KEY,
    CustomerID INT,
    PointsEarned INT,
    TierLevel NVARCHAR(255),
    JoinDate DATETIME
);

-- Create Loyalty Points Change Table
CREATE TABLE Loyaltytrans (
    LoyaltyID INT,
    DateTime DATETIME,
    PointsChange INT,
    Reason NVARCHAR(255),
    PRIMARY KEY (LoyaltyID, DateTime),
    FOREIGN KEY (LoyaltyID) REFERENCES Loyaltyacc(LoyaltyID)
);

-- Create Order Table
CREATE TABLE [Order] (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    DateTime DATETIME,
    PaymentMethod NVARCHAR(255),
    Amount DECIMAL(18, 2),
    Status NVARCHAR(255)
);

-- Create Product Table
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(255),
    Category NVARCHAR(255),
    Price DECIMAL(18, 2)
);

-- Create Store Table
CREATE TABLE Store (
    StoreID INT PRIMARY KEY,
    Location NVARCHAR(255),
    Manager NVARCHAR(255),
    OpenHours NVARCHAR(255)
);

-- Create Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    Name NVARCHAR(255),
    Email NVARCHAR(255),
    Address NVARCHAR(255)
);