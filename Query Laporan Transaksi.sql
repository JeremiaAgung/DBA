SELECT 
    DATE_FORMAT(t.TransactionDate, '%Y-%m') AS Month, 
    p.ProductID, 
    p.ProductName, 
    t.TransactionType, 
    SUM(t.Quantity) AS TotalQuantity
FROM 
    Transactions t
JOIN 
    Products p ON t.ProductID = p.ProductID
WHERE 
    t.TransactionDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY 
    Month, p.ProductID, p.ProductName, t.TransactionType
ORDER BY 
    Month DESC, p.ProductName, t.TransactionType;
