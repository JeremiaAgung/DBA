SELECT 
    p.ProductID, 
    p.ProductName, 
    p.MinimumStockLevel, 
    SUM(s.Quantity) AS TotalStock
FROM 
    Stock s
JOIN 
    Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName, p.MinimumStockLevel
HAVING 
    SUM(s.Quantity) < p.MinimumStockLevel
ORDER BY 
    TotalStock ASC;
