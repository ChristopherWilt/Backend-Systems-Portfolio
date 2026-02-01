/*
 * PROJECT: Vehicle Data Warehouse Optimization
 * AUTHOR: Christopher Wilt
 * DESCRIPTION:
 * This script handles the normalization of a flat-file vehicle dataset into 
 * Third Normal Form (3NF). It separates repeating groups (Make, Model, Drive, Fuel)
 * into lookup tables to reduce redundancy and implements indexing for query performance.
 */

-- =============================================
-- SECTION 1: CREATING LOOKUP TABLES (Normalization)
-- =============================================

-- Table: Vehicle Makes
CREATE TABLE vMake (
    vMakeId INT AUTO_INCREMENT PRIMARY KEY,
    vMake VARCHAR(255)
);

-- Table: Vehicle Models
CREATE TABLE vModel (
    vModelId INT AUTO_INCREMENT PRIMARY KEY,
    vModel VARCHAR(255)
);

-- Table: Drivetrain Types
CREATE TABLE vDrive (
    vDriveId INT AUTO_INCREMENT PRIMARY KEY,
    vDrive VARCHAR(255)
);

-- Table: Fuel Types
CREATE TABLE vFuelType (
    vFuelTypeId INT AUTO_INCREMENT PRIMARY KEY,
    vFuelType VARCHAR(255)
);


-- =============================================
-- SECTION 2: POPULATING LOOKUP TABLES (ETL)
-- =============================================

-- Extract distinct Makes
INSERT INTO vMake (vMake)
SELECT DISTINCT make
FROM vehicle
WHERE make IS NOT NULL AND make != '';

-- Extract distinct Models
INSERT INTO vModel (vModel)
SELECT DISTINCT model
FROM vehicle
WHERE model IS NOT NULL AND model != '';

-- Extract distinct Drive types
INSERT INTO vDrive (vDrive)
SELECT DISTINCT drive
FROM vehicle
WHERE drive IS NOT NULL AND drive != '';

-- Extract distinct Fuel types
INSERT INTO vFuelType (vFuelType)
SELECT DISTINCT fuelType
FROM vehicle
WHERE fuelType IS NOT NULL AND fuelType != '';


-- =============================================
-- SECTION 3: INDEXING FOR PERFORMANCE
-- =============================================

-- Create Unique Indexes to enforce data integrity on lookup tables
CREATE UNIQUE INDEX idx_unique_vMake_name ON vMake (vMake);
CREATE UNIQUE INDEX idx_unique_vModel_name ON vModel (vModel);
CREATE UNIQUE INDEX idx_unique_vDrive_name ON vDrive (vDrive);
CREATE UNIQUE INDEX idx_unique_vFuelType_name ON vFuelType (vFuelType);

-- Create Non-Unique Indexes on the source table to speed up the Join operation below
CREATE INDEX idx_vehicle_make ON vehicle (make);
CREATE INDEX idx_vehicle_model ON vehicle (model);
CREATE INDEX idx_vehicle_drive ON vehicle (drive);
CREATE INDEX idx_vehicle_fuelType ON vehicle (fuelType);


-- =============================================
-- SECTION 4: FACT TABLE CREATION (The Bridge)
-- =============================================

-- Create the normalized Fact Table (vBridge)
CREATE TABLE vBridge (
    vehicleId INT PRIMARY KEY,
    makeId INT,
    modelId INT,
    driveId INT,
    fuelTypeId INT,
    year INT,
    cylinders INT,
    mpgCity DECIMAL(10,2),
    mpgHighway DECIMAL(10,2)
);

-- Populate the Fact Table by joining source data with new Lookup Tables
INSERT INTO vBridge (
    vehicleId, makeId, modelId, driveId, fuelTypeId, 
    year, cylinders, mpgCity, mpgHighway
)
SELECT
    v.vehicleId,
    vm.vMakeId,
    vmo.vModelId,
    vd.vDriveId,
    vf.vFuelTypeId,
    v.year,
    v.cylinders,
    v.mpgCity,
    v.mpgHighway
FROM
    vehicle AS v
JOIN
    vMake AS vm ON v.make = vm.vMake
JOIN
    vModel AS vmo ON v.model = vmo.vModel
JOIN
    vDrive AS vd ON v.drive = vd.vDrive
JOIN
    vFuelType AS vf ON v.fuelType = vf.vFuelType;