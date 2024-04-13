-- find_customer (customer_id IN NUMBER, DISCOVERED NUMBER);
CREATE OR REPLACE PROCEDURE find_customer(
    customer_id IN NUMBER,
    found OUT NUMBER
) AS
    -- Declare a variable to store the query result
    customer_count NUMBER;
BEGIN
    -- Initialize the variable
    customer_count := 0;
    
    -- Count the number of customers with the provided ID
    SELECT COUNT(*)
    INTO customer_count
    FROM Customers  -- Replace 'Customers' with the actual name of your customer table
    WHERE Customer_id = customer_id;

    -- If a customer was found, set 'found' to 1
    IF customer_count > 0 THEN
        found := 1;
    ELSE
        found := 0;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: More than one customer with the same ID found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END find_customer;
/

-- find_product (productId IN NUMBER, 
-- price OUT products.list_price%TYPE,
-- productName OUT products.product_name%TYPE);


