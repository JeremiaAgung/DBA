SELECT 
    w.WarehouseID, 
    w.WarehouseName, 
    SUM(s.Quantity * p.Price) AS TotalInventoryValue
FROM 
    Stock s
JOIN 
    Products p ON s.ProductID = p.ProductID
JOIN 
    Warehouses w ON s.WarehouseID = w.WarehouseID
GROUP BY 
    w.WarehouseID, w.WarehouseName
ORDER BY 
    TotalInventoryValue DESC;
