-- Find Costumers
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

-- Find Product
CREATE OR REPLACE PROCEDURE find_product(
    productId IN NUMBER,
    price OUT products.list_price%TYPE,
    productName OUT products.product_name%TYPE
) AS
BEGIN
    -- Look for the product with the provided ID
    SELECT product_name, list_price
    INTO productName, price
    FROM Products  -- Replace 'Products' with the actual name of your product table
    WHERE Product_id = productId;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        price := 0;
        productName := 'Not Found';
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: More than one product with the same ID found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END find_product;
/

-- Gemerate Order ID
CREATE OR REPLACE FUNCTION generate_order_id
RETURN NUMBER IS
    new_order_id NUMBER;
BEGIN
    -- Find the maximum order ID in the Orders table
    SELECT NVL(MAX(order_id), 0) + 1
    INTO new_order_id
    FROM Orders;  -- Replace 'Orders' with the actual name of your orders table

    -- Return the new order ID
    RETURN new_order_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 1;  -- If there are no orders, start with 1
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        RETURN NULL;
END generate_order_id;
/
