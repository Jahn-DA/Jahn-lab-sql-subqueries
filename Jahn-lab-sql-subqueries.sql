-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(*) AS num_copies
FROM sakila.film AS f
JOIN sakila.inventory AS i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';
-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length
FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film);
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT actor_id, first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
    SELECT actor_id
    FROM sakila.film_actor
    WHERE film_id = (
        SELECT film_id
        FROM sakila.film
        WHERE title = 'Alone Trip'
    )
);

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT film_id, title
FROM sakila.film
WHERE film_id IN (
    SELECT film_id
    FROM sakila.film_category
    WHERE category_id = (
        SELECT category_id
        FROM sakila.category
        WHERE name = 'Family'
    )
);
-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN (
    SELECT address_id
    FROM sakila.address
    WHERE city_id IN (
        SELECT city_id
        FROM sakila.city
        WHERE country_id = (
            SELECT country_id
            FROM sakila.country
            WHERE country = 'Canada'
        )
    )
);
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT f.title
FROM sakila.film AS f
JOIN sakila.film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM sakila.actor
    ORDER BY (
        SELECT COUNT(*)
        FROM sakila.film_actor
        WHERE sakila.film_actor.actor_id = sakila.actor.actor_id
    ) DESC
    LIMIT 1
);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.title
FROM sakila.film AS f
JOIN sakila.inventory AS i ON f.film_id = i.film_id
JOIN sakila.rental AS r ON i.inventory_id = r.inventory_id
JOIN (
    SELECT p.customer_id
    FROM sakila.payment AS p
    GROUP BY p.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 1
) AS pc ON r.customer_id = pc.customer_id;
-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, total_amount_spent
FROM (
    SELECT c.customer_id, SUM(p.amount) AS total_amount_spent
    FROM customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
) AS subquery
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT c.customer_id, SUM(p.amount) AS total_amount_spent
        FROM customer AS c
        JOIN payment AS p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id
    ) AS avg_subquery
);