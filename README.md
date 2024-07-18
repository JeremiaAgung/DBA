# DBA
**1. Diagram ERD (Entity-Relationship Diagram)**
+-----------------+       +-----------------+       +-----------------+
|    Products     |       |   Warehouses    |       |    Suppliers    |
|-----------------|       |-----------------|       |-----------------|
| ProductID (PK)  |       | WarehouseID (PK)|       | SupplierID (PK) |
| ProductName     |       | WarehouseName   |       | SupplierName    |
| Description     |       | Location        |       | ContactName     |
| Category        |       +-----------------+       | ContactEmail    |
| Price           |                                   | ContactPhone    |
| MinimumStockLevel|                                 | Address         |
+-----------------+                                 +-----------------+
        |                                                      |
        |                                                      |
        |                                                      |
        +---------+                                             |
                  |                                             |
                  |                                             |
                  |                                             |
          +-------v---------+                      +------------v------------+
          |      Stock      |                      |      Restock_Orders     |
          |-----------------|                      |-------------------------|
          | StockID (PK)    |                      | RestockOrderID (PK)     |
          | ProductID (FK)  +----------------------+ ProductID (FK)          |
          | WarehouseID (FK)|                      | SupplierID (FK)         |
          | Quantity        |                      | OrderQuantity           |
          +-----------------+                      | OrderDate               |
                                                   | ExpectedArrivalDate      |
                                                   | Status                   |
                                                   +-------------------------+
                                                              |
                                                              |
                                                              |
                                                     +--------v---------+
                                                     |    Transactions   |
                                                     |-------------------|
                                                     | TransactionID (PK)|
                                                     | ProductID (FK)    |
                                                     | WarehouseID (FK)  |
                                                     | TransactionType   |
                                                     | Quantity          |
                                                     | TransactionDate   |
                                                     +-------------------+
**2. Query SQL dan Langkah-Langkah Optimisasi**

   **Menampilkan stok produk yang tersedia di semua gudang**
SELECT 
    p.ProductID, 
    p.ProductName, 
    p.Category, 
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


**Langkah-Langkah Optimisasi:**
Indeks pada Stock(ProductID, WarehouseID).
Indeks pada Products(ProductID).
Indeks pada Warehouses(WarehouseID).

**Menampilkan stok produk yang ada di bawah level minimum dan perlu di-restock**

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

**Langkah-Langkah Optimisasi:**
Indeks pada Stock(ProductID).
Indeks pada Products(ProductID, MinimumStockLevel).

**Menghitung total nilai inventaris di setiap gudang berdasarkan harga produk**
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

**Langkah-Langkah Optimisasi:**
Indeks pada Stock(ProductID).
Indeks pada Stock(WarehouseID).
Indeks pada Products(ProductID, Price).
Indeks pada Warehouses(WarehouseID).

**Menghasilkan laporan transaksi masuk dan keluar per bulan untuk satu tahun terakhir**
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
    
**Langkah-Langkah Optimisasi:**
Indeks pada Transactions(TransactionDate).
Indeks pada Transactions(ProductID).
Indeks pada Products(ProductID).
Indeks pada Products(ProductName).

**3. Contoh Pengaturan Indeks dan Strategi Performance Tuning**
Pengaturan Indeks
-- Indeks pada tabel Stock
CREATE INDEX idx_product_warehouse ON Stock(ProductID, WarehouseID);
CREATE INDEX idx_quantity ON Stock(Quantity);

-- Indeks pada tabel Products
CREATE INDEX idx_product_id ON Products(ProductID);
CREATE INDEX idx_product_name ON Products(ProductName);

-- Indeks pada tabel Warehouses
CREATE INDEX idx_warehouse_id ON Warehouses(WarehouseID);

-- Indeks pada tabel Transactions
CREATE INDEX idx_transaction_date_product ON Transactions(TransactionDate, ProductID);
CREATE INDEX idx_transaction_warehouse ON Transactions(WarehouseID);

-- Indeks pada tabel Restock_Orders
CREATE INDEX idx_restock_product ON Restock_Orders(ProductID);
CREATE INDEX idx_restock_supplier ON Restock_Orders(SupplierID);

**Strategi Performance Tuning**
**Indeksasi:**
Gunakan indeks pada kolom yang sering digunakan dalam query untuk mempercepat pencarian dan join.

**Partisi Tabel:**
Bagi tabel besar menjadi partisi berdasarkan kolom yang relevan untuk meningkatkan performa.

**Query Optimisasi:**
Gunakan alat analisis seperti EXPLAIN untuk mengidentifikasi dan mengoptimalkan query yang lambat.

**Caching:**
Implementasi caching untuk query yang sering dijalankan dan tidak memerlukan data real-time.

**Reindexing:**
Lakukan reindexing secara berkala untuk mengatasi fragmentasi indeks.

**4. Pengaturan Table Partitioning dan Rencana Pemeliharaan Database**
Pengaturan Table Partitioning

**Partitioning pada Tabel Transactions Berdasarkan Range pada TransactionDate:**
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    WarehouseID INT,
    TransactionType ENUM('IN', 'OUT'),
    Quantity INT,
    TransactionDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
) PARTITION BY RANGE (YEAR(TransactionDate)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pFuture VALUES LESS THAN MAXVALUE
);

**Partitioning pada Tabel Stock Berdasarkan Hash pada ProductID:**
CREATE TABLE Stock (
    StockID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    WarehouseID INT,
    Quantity INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
) PARTITION BY HASH (ProductID) PARTITIONS 8;

**Rencana Pemeliharaan Database**
Backup Reguler:
Lakukan backup penuh secara mingguan dan backup inkremental setiap hari.

Reindexing:
Rebuild indeks secara berkala untuk mengatasi fragmentasi, misalnya setiap bulan.
Monitoring Kesehatan Database:
Gunakan alat monitoring untuk memantau performa dan kesehatan database.
Pantau KPI seperti latensi query, penggunaan CPU, penggunaan memori, I/O disk, dan penggunaan ruang disk.

Optimisasi Query:
Profiling query secara berkala untuk mengidentifikasi dan mengoptimalkan query yang lambat.
Implementasi caching untuk query yang sering diakses.

Pembersihan Data:
Arsipkan data lama yang tidak sering diakses tetapi masih perlu disimpan.
Pindahkan data arsip ke tabel atau database lain yang dioptimalkan untuk penyimpanan.

Manajemen Koneksi:
Gunakan pooling koneksi untuk mengelola jumlah koneksi yang dibuka ke database.
Atur timeout pada koneksi untuk menghindari koneksi yang menggantung dan menghabiskan sumber daya.

Pembaruan dan Patching:
Pastikan server database dan semua dependensi terkait selalu diperbarui dengan patch keamanan terbaru.
Uji pembaruan di lingkungan staging sebelum diterapkan di lingkungan produksi.

Audit dan Logging:
Log semua aktivitas penting seperti perubahan skema, perubahan data sensitif, dan akses pengguna.
Tinjau log secara berkala untuk mendeteksi dan menangani masalah keamanan atau kinerja yang muncul.
