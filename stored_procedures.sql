/*
 * PROJECT: E-Commerce Database Logic
 * AUTHOR: Christopher Wilt
 * DESCRIPTION:
 * Contains Stored Procedures and Deterministic Functions for calculating 
 * order totals, inventory checks, and aggregating user profile statistics.
 */

DELIMITER $$

-- =============================================
-- FUNCTION: Inventory Check
-- Description: Returns current stock level for a specific ItemID
-- =============================================
DROP FUNCTION IF EXISTS itemCount$$

CREATE FUNCTION itemCount( t_itemId INT )
RETURNS INT
DETERMINISTIC 
READS SQL DATA
BEGIN
    DECLARE ret INT;
    
    SELECT quantityInStock INTO ret
    FROM Item
    WHERE itemId = t_itemId;
    
    RETURN ret;
END$$


-- =============================================
-- FUNCTION: Calculate Order Total
-- Description: Calculates total revenue for a specific OrderID 
-- (Sum of ItemPrice * Quantity)
-- =============================================
DROP FUNCTION IF EXISTS orderTotalPrice$$

CREATE FUNCTION orderTotalPrice( t_orderId INT )
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE ret DECIMAL(10,2);
    
    SELECT SUM(oi.quantity * i.itemPrice) INTO ret
    FROM orderItem AS oi
    JOIN item AS i ON oi.itemId = i.itemId
    WHERE oi.orderId = t_orderId;
    
    RETURN ret;
END$$


-- =============================================
-- PROCEDURE: User Profile Aggregation
-- Description: Returns a comprehensive profile of a user, including
-- occupation, total orders placed, and assets owned (DVDs/Vehicles).
-- =============================================
DROP PROCEDURE IF EXISTS userInfo$$

CREATE PROCEDURE userInfo(
    IN  p_userId VARCHAR(50),
    OUT p_fullName VARCHAR(255),
    OUT p_occupationName VARCHAR(255),
    OUT p_orderCount INT,
    OUT p_dvdCount INT,
    OUT p_vehicleCount INT
)
BEGIN
    -- 1. Retrieve User Demographics
    SELECT
        CONCAT(u.firstname, ' ', u.lastname),
        o.occupation
    INTO
        p_fullName,
        p_occupationName
    FROM
        users AS u
    LEFT JOIN
        occupation AS o ON u.occupationId = o.occupationId
    WHERE
        u.userId = p_userId;

    -- 2. Aggregate Order History
    SELECT COUNT(*) INTO p_orderCount
    FROM orders
    WHERE userId = p_userId;

    -- 3. Aggregate Digital Assets (DVDs)
    SELECT COUNT(*) INTO p_dvdCount
    FROM userDVD
    WHERE userId = p_userId;

    -- 4. Aggregate Physical Assets (Vehicles)
    SELECT COUNT(*) INTO p_vehicleCount
    FROM uservehicle
    WHERE userId = p_userId;

END$$

DELIMITER ;