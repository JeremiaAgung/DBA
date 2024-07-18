CREATE TABLE Restock_Orders (
    RestockOrderID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    SupplierID INT,
    Quantity INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    Status ENUM('PENDING', 'RECEIVED', 'CANCELLED') NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);
