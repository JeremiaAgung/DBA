SELECT 
    p.ProductID, 
    p.ProductName, 
    w.WarehouseID, 
    w.WarehouseName, 
    s.Quantity
FROM 
    Stock s
JOIN 
    Products p ON s.ProductID = p.ProductID
JOIN 
    Warehouses w ON s.WarehouseID = w.WarehouseID
ORDER BY 
    p.ProductName, w.WarehouseName;
