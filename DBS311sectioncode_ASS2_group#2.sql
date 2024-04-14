-- Find Costumers
CREATE OR REPLACE PROCEDURE find_customer (
    customer_id IN NUMBER,
    found OUT NUMBER
) AS
BEGIN
    SELECT 1 INTO found FROM customers WHERE customer_id = find_customer.customer_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple customers found for the given ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END find_customer;
/

-- Gemerate Order ID
CREATE OR REPLACE FUNCTION generate_order_id
RETURN NUMBER IS
    new_order_id NUMBER;
BEGIN
    -- Find the maximum order ID in the Orders table
    SELECT NVL(MAX(order_id), 0) + 1
    INTO new_order_id
    FROM ORDERS;

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
CREATE OR REPLACE PROCEDURE customer_order (
    customerId IN NUMBER,
    orderId IN OUT NUMBER
) AS
BEGIN
    SELECT order_id INTO orderId FROM orders WHERE customer_id = customer_order.customerId AND order_id = customer_order.orderId;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        orderId := 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END customer_order;
/

-- Display_Order_Status
CREATE OR REPLACE PROCEDURE display_order_status (
    orderId IN NUMBER,
    status OUT orders.status%TYPE
) AS
BEGIN
    SELECT status INTO status FROM orders WHERE order_id = orderId;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        status := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
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

-- Find_Produc
CREATE OR REPLACE PROCEDURE find_product (
    productId IN NUMBER,
    price OUT NUMBER,
    productName OUT VARCHAR2
) AS
    current_month VARCHAR2(20);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'MON') INTO current_month FROM DUAL;

    SELECT list_price, product_name
    INTO price, productName
    FROM products
    WHERE product_id = productId;

    IF current_month IN ('NOV', 'DEC') AND productId IN (2, 5) THEN
        price := price * 0.9; -- 10% discount in Nov and Dec for categories 2 and 5
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        price := 0;
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple products found for the given ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END find_product;
/
