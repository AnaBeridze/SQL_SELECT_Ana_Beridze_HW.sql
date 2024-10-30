
SELECT f.title
FROM category AS c
RIGHT JOIN film_category AS fc ON c.category_id = fc.category_id
RIGHT JOIN film AS f ON fc.film_id = f.film_id
WHERE c.name = 'Animation'
   AND f.rental_rate > 1
   AND f.release_year > 2017
   AND f.release_year < 2019
ORDER BY f.title ASC;



SELECT CONCAT(a.address, ' ', a.address2) AS full_address, SUM(p.amount) AS revenue
FROM payment AS p
RIGHT JOIN rental AS r ON p.rental_id = r.rental_id
RIGHT JOIN inventory AS i ON r.inventory_id = i.inventory_id
RIGHT JOIN store AS s ON i.store_id = s.store_id
RIGHT JOIN address AS a ON s.address_id = a.address_id
WHERE p.payment_date >= '2017-03-01'
GROUP BY full_address;


SELECT a.first_name, a.last_name, COUNT(f.film_id) AS number_of_movies
FROM actor AS a
INNER JOIN film_actor AS fa ON a.actor_id = fa.actor_id
INNER JOIN film AS f ON fa.film_id = f.film_id
WHERE f.release_year >= 2015
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY number_of_movies DESC
LIMIT 5;

SELECT 
    COALESCE(f.release_year, 0) AS release_year,
    SUM(CASE WHEN c.name = 'Drama' THEN 1 ELSE 0 END) AS number_of_drama_movies,
    SUM(CASE WHEN c.name = 'Travel' THEN 1 ELSE 0 END) AS number_of_travel_movies,
    SUM(CASE WHEN c.name = 'Documentary' THEN 1 ELSE 0 END) AS number_of_documentary_movies
FROM film AS f
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
WHERE COALESCE(f.release_year, 0) >= 2015  -- Adjusted to handle potential NULLs in release_year
GROUP BY release_year
ORDER BY release_year DESC;


SELECT 
    c.first_name AS customer_name,
    c.last_name AS customer_surname,
    STRING_AGG(f.title, ', ') AS rented_horror_movies,
    SUM(p.amount) AS money_paid
FROM payment AS p
INNER JOIN customer AS c ON p.customer_id = c.customer_id
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Horror'
GROUP BY c.customer_id, c.first_name, c.last_name;

---- Task: 2 ----

WITH total_amounts AS (
    SELECT 
        p.staff_id,
        SUM(p.amount) AS total_amount
    FROM payment AS p
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY p.staff_id
),
latest_store AS (
    SELECT 
        p.staff_id,
        COALESCE(i.store_id, 0) AS store_id,  -- Use 0 if store_id is NULL
        p.payment_date
    FROM payment AS p
    INNER JOIN rental AS r ON p.rental_id = r.rental_id
    INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
    WHERE p.payment_date = (
        SELECT MAX(payment_date)
        FROM payment
        WHERE staff_id = p.staff_id
    )
)
SELECT 
    s.first_name,
    s.last_name,
    s.staff_id,
    ls.store_id AS place_of_work,
    ls.payment_date AS latest_payment_date,
    ta.total_amount
FROM staff AS s
INNER JOIN total_amounts AS ta ON s.staff_id = ta.staff_id
INNER JOIN latest_store AS ls ON s.staff_id = ls.staff_id 
ORDER BY ta.total_amount DESC
LIMIT 3;




-----Task 3 ------

--- break from the last release is calculated ---

SELECT 
    a.first_name,
    a.last_name,
    EXTRACT(YEAR FROM CURRENT_DATE) - latest_films.latest_release_year AS years_on_a_break
FROM actor AS a
INNER JOIN (
    SELECT fa.actor_id, MAX(f.release_year) AS latest_release_year
    FROM film_actor AS fa
    INNER JOIN film AS f ON fa.film_id = f.film_id
    GROUP BY fa.actor_id
) AS latest_films ON a.actor_id = latest_films.actor_id
ORDER BY years_on_a_break DESC
LIMIT 1;