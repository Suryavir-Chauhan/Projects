-- Q1. Who is the senior most employee based on job title?
select top 1 * from employee
order by levels desc


-- Q2.  Which countries have the most Invoices?

select top 1
	   billing_country,
	   count(billing_country) as cnt_country
from invoice
group by billing_country
order by cnt_country desc


--Q3. What are top 3 values of total invoice?

select top 3
	   round(cast(total as float),2) as total_invoice
from invoice
order by total desc


/* Q4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/

select top 1
	   billing_city,
	   round(cast (sum(total) as float),2) as city_total 
from invoice
group by billing_city
order by city_total desc


/*Q5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/

select top 1
	   c.customer_id,
	   c.first_name,
	   c.last_name,
	   round(cast(sum(i.total) as float),2) as customer_total
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by customer_total desc



/*Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

select c.email as email,
	   c.first_name as first_name,
	   c.last_name as last_name,
	   g.name
from customer as c
join invoice	  as i  on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track		  as t  on il.track_id = t.track_id
join genre        as g  on t.genre_id = g.genre_id
where g.name like 'Rock'
group by email, first_name, last_name, g.name
order by email, first_name, last_name



/* Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

select Top 10
	   a.artist_id,
	   a.name,
	   count(t.track_id) as Total_tracks
from artist as a
join album as ab on a.artist_id = ab.artist_id
join track as t  on ab.album_id = t.album_id
join genre as g  on t.genre_id  = g.genre_id
where g.name like 'Rock'
group by a.artist_id, a.name
order by Total_tracks desc


/* Q8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first */

select name as Track_Name,
	   milliseconds as Track_Length
from track
where milliseconds > (select avg(milliseconds)
					  from track)
order by Track_Length desc


/* Q9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

select CONCAT(c.first_name,' ',c.last_name) as Customer_name,
	   a.name as Artist,
	   round(sum(cast(i.total as float)),2) as Total_Spent	   
from customer as c
join invoice	  as i  on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id  = il.invoice_id
join track	      as t  on il.track_id   = t.track_id
join album		  as ab on t.album_id	 = ab.album_id
join artist		  as a  on ab.artist_id	 = a.artist_id
group by CONCAT(c.first_name,' ',c.last_name), a.name
order by Customer_name asc,Total_Spent desc, a.name asc


/* Q10. . We want to find out the most popular music Genre for each country. We determine the most popular 
genre as the genre with the highest amount of purchases. Write a query that returns each country along with
the top Genre. For countries where the maximum number of purchases is shared return all Genres */

with cte as
(
		select i.billing_country as Country,
			   count(il.invoice_id) as Purchase_count,
			   g.name as Genre,
			   DENSE_RANK() over(partition by i.billing_country order by count(il.invoice_id) desc) as rnk
	   
		from invoice as i
		join invoice_line as il on i.invoice_id = il.invoice_id
		join track		  as t  on il.track_id  = t.track_id
		join genre		  as g  on t.genre_id = g.genre_id
		group by i.billing_country, g.name
)

select Country,
	   Genre,
	   Purchase_count
from cte
where rnk = 1

 
 /* Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query 
 that returns the country along with the top customer and how much they spent. For countries where the top amount 
 spent is shared, provide all customers who spent this amount */

with cte as 
(
		select c.country,
			   concat (c.first_name,c.last_name) as customer,
			   sum(round(cast(i.total as float),2)) as Amt_Spent,
			   dense_rank() over(partition by c.country order by sum(round(cast(i.total as float),2)) desc) as rnk
		from customer as c
		join invoice as i on c.customer_id = i.customer_id
		group by c.country, concat (c.first_name,c.last_name)
)

select country,
	   customer,
	   Amt_Spent
from cte
where rnk = 1

