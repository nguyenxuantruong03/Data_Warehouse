/*
========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from  external CSV files.
  It performs the following actions:
    - Truncates the bronze tables before loading data 
    - Use the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
  None.
This stored procedure does not accpet any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
========================================================================
*/


/* 
---------------------------------Chạy Container mới với tham số Volume (-v)----------------------------------
                            
                docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=xuanTruong261103" \
                    -p 1433:1433 --name sql_server_container \
                    -v /Users/xuantruong/explore_and_learn_more/sql-data-warehouse-project/datasets:/var/opt/mssql/datasets \
                    -d mcr.microsoft.com/mssql/server:2025-latest

*/

/* 
---------------------------------Chạy lệnh này để xem Docker có thấy file đó không----------------------------------

                            docker exec -it sql_server_container ls /var/opt/mssql/datasets
*/

USE DataWarehouse;
EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME;
        DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
        PRINT'=============================='
        PRINT 'Loading Bronze Layer...'
        PRINT'=============================='

        PRINT'-------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT'-------------------------------'

        SET @start_time = GETDATE();
        SET @batch_start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Insearting Data Into Table: bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/datasets/source_crm/cust_info.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
       
        --Dùng để xoá dữ liệu cũ trước khi nạp dữ liệu mới vào bảng
        PRINT '>> Truncating Table: bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Insearting Data Into Table: bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/datasets/source_crm/prd_info.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        --Dùng để xoá dữ liệu cũ trước khi nạp dữ liệu mới vào bảng
        PRINT '>> Truncating Table: bronze.crm_sales_detail'
        TRUNCATE TABLE bronze.crm_sales_detail;

        PRINT '>> Insearting Data Into Table: bronze.crm_sales_detail'
        BULK INSERT bronze.crm_sales_detail
        FROM '/var/opt/mssql/datasets/source_crm/sales_details.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        PRINT'-------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT'-------------------------------'

        --Dùng để xoá dữ liệu cũ trước khi nạp dữ liệu mới vào bảng
        PRINT '>> Truncating Table: bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Insearting Data Into Table: bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/datasets/source_erp/loc_a101.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        --Dùng để xoá dữ liệu cũ trước khi nạp dữ liệu mới vào bảng
        PRINT '>> Truncating Table: bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Insearting Data Into Table: bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/datasets/source_erp/cust_az12.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        --Dùng để xoá dữ liệu cũ trước khi nạp dữ liệu mới vào bảng
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Insearting Data Into Table: bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/datasets/source_erp/px_cat_g1v2.csv' -- Đường dẫn trong Docker
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
         SET @end_time = GETDATE();
        PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------'
        
        SET @batch_end_time = GETDATE();
        PRINT '-----------------------------------'
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '      - Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------------------------------'
    END TRY
    BEGIN CATCH
        PRINT '========================================='
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Message: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '========================================='
    END CATCH
END
