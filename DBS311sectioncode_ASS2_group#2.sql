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

-- Add_Order
CREATE OR REPLACE PROCEDURE add_order(
    customer_id IN NUMBER,
    new_order_id OUT NUMBER
) AS
BEGIN
    -- Generate a new order ID
    new_order_id := generate_order_id();

    -- Add a new order with the generated ID, provided customer ID, and other default values
    INSERT INTO Orders (order_id, customer_id, status, salesman_id, order_date)
    VALUES (new_order_id, customer_id, 'Shipped', 56, SYSDATE);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Order ID already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END add_order;
/

-- Add_Order_Item
CREATE OR REPLACE PROCEDURE add_order_item(
    orderId IN order_items.order_id%type,
    itemId IN order_items.item_id%type, 
    productId IN order_items.product_id%type, 
    quantity IN order_items.quantity%type,
    price IN order_items.unit_price%type
) AS
BEGIN
    -- Insert the provided values into the order_items table
    INSERT INTO order_items (order_id, item_id, product_id, quantity, unit_price)
    VALUES (orderId, itemId, productId, quantity, price);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Order item already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END add_order_item;
/

-- Customer_Order
CREATE OR REPLACE PROCEDURE customer_order(
    customerId IN NUMBER,
    orderId IN OUT NUMBER
) AS
BEGIN
    -- Check if an order with the provided order ID exists for the customer
    SELECT COUNT(*)
    INTO orderId
    FROM Orders
    WHERE customer_id = customerId AND order_id = orderId;

    -- If no order was found, set orderId to 0
    IF orderId = 0 THEN
        orderId := 0;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        orderId := 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END customer_order;
/

-- Display_Order_Status
CREATE OR REPLACE PROCEDURE display_order_status(
    orderId IN NUMBER,
    status OUT orders.status%type
) AS
BEGIN
    -- Get the status of the order with the provided ID
    SELECT status
    INTO status
    FROM Orders
    WHERE order_id = orderId;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        status := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END display_order_status;
/

-- Cancel_order
CREATE OR REPLACE PROCEDURE cancel_order(
    orderId IN NUMBER,
    cancelStatus OUT NUMBER
) AS
    orderStatus orders.status%type;
BEGIN
    -- Get the status of the order with the provided ID
    SELECT status
    INTO orderStatus
    FROM Orders
    WHERE order_id = orderId;

    -- Check the status of the order and set cancelStatus accordingly
    IF orderStatus IS NULL THEN
        cancelStatus := 0;
    ELSIF orderStatus = 'Canceled' THEN
        cancelStatus := 1;
    ELSIF orderStatus = 'Shipped' THEN
        cancelStatus := 2;
    ELSE
        UPDATE Orders
        SET status = 'Canceled'
        WHERE order_id = orderId;
        cancelStatus := 3;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        cancelStatus := 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END cancel_order;
/