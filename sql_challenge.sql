#* 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select upper(concat(last_name, ', ', first_name)) as FULL_NAME from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where upper(first_name) = 'JOE';

#2b. Find all actors whose last name contain the letters `GEN`:
select first_name, last_name from actor
where upper(last_name) like '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select first_name, last_name from actor
where upper(last_name) like '%LI%'
order by last_name, first_name;

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country in ( 'Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add description blob;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop description;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) from actor
group by last_name
order by last_name, first_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) from actor
group by last_name
having count(*)>=2
order by last_name, first_name;

SET SQL_SAFE_UPDATES = 0;

#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor 
set first_name = "HARPO" 
where first_name = 'GROUCHO' 
and last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor 
set first_name = "GROUCHO" 
where first_name = 'HARPO';

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address from staff s
join address a on s.address_id = a.address_id;

#use sakila;

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select sum(p.amount) as total_rung, s.staff_id, s.first_name, s.last_name  from payment p
join staff s on s.staff_id = p.staff_id
group by s.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, count(a.actor_id) as number_of_actors from film f
inner join film_actor a on a.film_id = f.film_id
group by f.film_id;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*) from inventory i
inner join film f on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select sum(p.amount) as total_paid, c.first_name, c.last_name from payment p
join customer c on c.customer_id = p.customer_id
group by p.customer_id
order by c.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film 
where film_id in (
select f.film_id from film f
join language l on l.language_id = f.language_id
where l.name = 'English')
and (title like "K%" or title like "Q%");

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name from actor
where actor_id in (
select a.actor_id from film_actor a 
join film f on f.film_id = a.film_id
where f.title = 'Alone Trip');

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cu.first_name, cu.last_name, cu.email from customer cu
inner join address a on a.address_id = cu.address_id
inner join city ct on ct.city_id = a.city_id
inner join country co on co.country_id = ct.country_id
where co.country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select f.title from film f 
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
where c.name = 'Family';

#7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) as rental_frequency from rental r 
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by f.film_id
order by count(r.rental_id) desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(f.rental_rate) as business from store s
join inventory i on i.store_id = s.store_id
join film f on f.film_id = i.film_id
group by s.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ct.city, co.country from store s
inner join address a on a.address_id = s.address_id
inner join city ct on ct.city_id = a.city_id
inner join country co on co.country_id = ct.country_id;


#* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount) as revenue from inventory i
join film_category f on f.film_id = i.film_id
join category c on c.category_id = f.category_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by c.category_id
order by sum(p.amount);

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as 
select c.name as genre, sum(p.amount) as revenue from inventory i
join film_category f on f.film_id = i.film_id
join category c on c.category_id = f.category_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by c.category_id
order by sum(p.amount)
limit 5;

#8b. How would you display the view that you created in 8a?
#Bar chart 

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;