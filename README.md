# SQL Data Warehouse Project

##  Overview

This project implements a comprehensive **Data Warehouse solution** using the **Medallion Architecture** (Bronze-Silver-Gold) with SQL Server. The solution processes customer, product, and sales data from multiple sources (CRM and ERP systems) and transforms them into a structured, analytics-ready format.

##  Architecture

The project follows the **Medallion Architecture** pattern with three distinct layers:

```
        
    BRONZE              SILVER                  GOLD       
   Raw Data           Cleansed Data        Business Ready  
   Ingestion          Standardized         Star Schema     
─        
```

###  Bronze Layer (Raw Data Ingestion)
- **Purpose**: Raw data ingestion from external sources
- **Data Sources**: 
  - CRM System: Customer info, product details, sales transactions
  - ERP System: Customer demographics, location data, product categories
- **Format**: Exact replica of source data with minimal processing

###  Silver Layer (Cleansed & Standardized)
- **Purpose**: Data cleansing, validation, and standardization
- **Transformations**:
  - Data type conversions
  - NULL value handling
  - Standardization of categorical values
  - Data quality validation
  - Deduplication logic

###  Gold Layer (Business-Ready Analytics)
- **Purpose**: Business-ready dimensional model (Star Schema)
- **Structure**:
  - **Fact Table**: `fact_sales` - Sales transactions with metrics
  - **Dimension Tables**: 
    - `dim_customers` - Customer master data
    - `dim_products` - Product catalog with categories

##  Project Structure

```
sql_datawarehouse-project/
  datasets/                    # Source data files
     source_crm/             # CRM system data
       cust_info.csv          # Customer information (18,495 records)
       prd_info.csv           # Product information (399 records)
       sales_details.csv      # Sales transactions (60,400 records)
     source_erp/             # ERP system data
        CUST_AZ12.csv          # Customer demographics
        LOC_A101.csv           # Location/Country data
        PX_CAT_G1V2.csv        # Product categories
  scripts/                    # SQL scripts organized by layer
    Create_DataWarehouse_Schemas.sql  # Database & schema setup
     bronze/                 # Bronze layer scripts
       Create_Bronze_Tables.sql      # DDL for raw tables
       Load_Bronze_Layer.sql         # Data ingestion procedures
     silver/                 # Silver layer scripts
       Create_Silver_Tables.sql      # DDL for cleansed tables
       Load_Silver_Procedure.sql     # ETL transformations
     gold/                   # Gold layer scripts
        DDL_Create_Gold_Views.sql     # Business views (Star Schema)
 LICENSE                        # MIT License
 README.md                      # Project documentation
```

##  Data Schema

### CRM System Data
| Table | Records | Description |
|-------|---------|-------------|
| `cust_info.csv` | 18,495 | Customer master data with demographics |
| `prd_info.csv` | 399 | Product catalog with pricing and categories |
| `sales_details.csv` | 60,400 | Sales transactions and order details |

### ERP System Data
| Table | Records | Description |
|-------|---------|-------------|
| `CUST_AZ12.csv` | - | Customer demographics (birthdate, gender) |
| `LOC_A101.csv` | - | Customer location and country information |
| `PX_CAT_G1V2.csv` | - | Product categories and maintenance info |

##  Getting Started

### Prerequisites
- SQL Server 2019 or later
- SQL Server Management Studio (SSMS)
- Read/Write access to data source files

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/hakkache/sql_datawarehouse-project.git
   cd sql_datawarehouse-project
   ```

2. **Create Database & Schemas**
   ```sql
   -- Execute in SSMS
   :r scripts/Create_DataWarehouse_Schemas.sql
   ```

3. **Set Up Bronze Layer**
   ```sql
   -- Create Bronze tables
   :r scripts/bronze/Create_Bronze_Tables.sql
   
   -- Load raw data (update file paths as needed)
   EXEC bronze.load_bronze;
   ```

4. **Set Up Silver Layer**
   ```sql
   -- Create Silver tables
   :r scripts/silver/Create_Silver_Tables.sql
   
   -- Transform and load cleansed data
   EXEC silver.load_silver;
   ```

5. **Set Up Gold Layer**
   ```sql
   -- Create business views
   :r scripts/gold/DDL_Create_Gold_Views.sql
   ```

##  Configuration

### File Path Configuration
Update the file paths in the BULK INSERT statements within:
- `scripts/bronze/Load_Bronze_Layer.sql`

Example:
```sql
-- Update these paths to match your environment
FROM 'C:\Your\Path\To\datasets\source_crm\cust_info.csv'
```

### Data Loading Process

The ETL process follows this sequence:

1. **Bronze Layer Loading** (`bronze.load_bronze`)
   - Truncates existing bronze tables
   - Performs BULK INSERT from CSV files
   - Logs execution time for each table

2. **Silver Layer Processing** (`silver.load_silver`)
   - Applies data transformations and cleansing rules
   - Handles data type conversions
   - Implements business logic for standardization
   - Removes duplicates and validates data quality

3. **Gold Layer Views**
   - Creates analytical views combining Silver layer data
   - Implements Star Schema design
   - Provides business-ready datasets

##  Business Intelligence & Analytics

### Key Metrics Available

The Gold layer provides these business-ready datasets:

####  Sales Analytics
- **Fact Table**: `gold.fact_sales`
- **Metrics**: Sales amount, quantity sold, pricing
- **Dimensions**: Customer, Product, Time

####  Customer Analytics  
- **Dimension**: `gold.dim_customers`
- **Attributes**: Demographics, location, marital status, gender
- **Unified View**: Combines CRM and ERP customer data

####  Product Analytics
- **Dimension**: `gold.dim_products`
- **Attributes**: Product details, categories, cost, product lines
- **Categories**: Mountain, Road, Touring, Other Sales

### Sample Queries

```sql
-- Sales performance by product category
SELECT 
    p.category,
    p.subcategory,
    SUM(f.sales_amount) as total_sales,
    COUNT(*) as transaction_count
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_sales DESC;

-- Customer analysis by country
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) as customer_count,
    SUM(f.sales_amount) as total_revenue
FROM gold.dim_customers c
JOIN gold.fact_sales f ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;
```

##  Data Quality & Transformations

### Silver Layer Transformations

#### Customer Data Cleansing
- **Marital Status**: Standardized (`S`  `Single`, `M`  `Married`)
- **Gender**: Normalized (`M`/`MALE`  `Male`, `F`/`FEMALE`  `Female`)
- **Name Fields**: Trimmed whitespace
- **Deduplication**: Latest record by creation date

#### Product Data Processing
- **Category IDs**: Extracted from product keys
- **Product Lines**: Expanded abbreviations (`M`  `Mountain`, `R`  `Road`)
- **Date Handling**: Proper date type conversion
- **Cost Validation**: NULL handling with defaults

#### Sales Data Validation
- **Date Conversion**: Integer date formats to proper DATE types
- **Sales Amount Validation**: Recalculated as `quantity * price` when inconsistent
- **Price Correction**: Derived from sales amount when missing

##  Performance Considerations

- **Indexing Strategy**: Recommended indexes on key columns for optimal query performance
- **Partitioning**: Consider date-based partitioning for large fact tables
- **Bulk Loading**: Uses TABLOCK for efficient data loading
- **Error Handling**: Comprehensive error logging in all procedures

##  Security & Compliance

- **Schema Separation**: Clear boundaries between Bronze, Silver, and Gold layers
- **Access Control**: Implement role-based access to different layers
- **Data Lineage**: Full traceability from source to analytics layer
- **Audit Trail**: ETL execution logging with timestamps

##  Monitoring & Maintenance

### ETL Execution Monitoring
- All procedures include execution time logging
- Error handling with detailed error messages
- Progress indicators for long-running operations

### Maintenance Tasks
- Regular data quality checks
- Performance monitoring and optimization
- Backup and recovery procedures
- Data archival strategies

##  Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Author

**HAKKACHE MOHAMED**
- GitHub: [@hakkache](https://github.com/hakkache)
- Project: [SQL Data Warehouse Project](https://github.com/hakkache/sql_datawarehouse-project)

##  Acknowledgments

- Microsoft SQL Server documentation and best practices
- Medallion Architecture design patterns
- Data warehouse dimensional modeling principles

---

*Last Updated: October 28, 2025*
