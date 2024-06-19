use Music_StoreDB
go


/* Q1 - Who is the senior most employee based on job title? */

select top 1* from employee order by levels desc

/* Q2  -Which countries have the most Invoices? */


select count(*) as total_count, billing_country from invoice
group by billing_country
order by total_count desc

/* Q3 - What are top 3 values of total invoice? */

select top 3 round(total,2) as total from invoice order by total desc

/* Q4 - Which city has best customer ? we would like to throw a promotional music festival in the city. we made the most moey.
write a query that returns one city that has the highest sum of invoices totals. return both the city and invoices total. */

select * from invoice

select top 1 sum(round(total,2))as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc

/* Q5 - Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


select top 1 s.customer_id, s.first_name, s.last_name, s.total from(
select c.customer_id, c.first_name, c.last_name, sum(round(total,2)) as total from customer C
inner join
invoice I
on C.customer_id = I.customer_id
group by c.customer_id, c.first_name, c.last_name) as s
order by total desc

/* Q6 - Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select c.first_name, c.last_name, c.email from customer C
inner join invoice I
on C.customer_id = I.customer_id
inner join invoice_line IL
on I.invoice_id = IL.invoice_id
where track_id in (select track_id from track T inner join genre G on T.genre_id = G.genre_id
where g.name like 'rock')
group by c.first_name, c.last_name, c.email
order by c.email

/* Q7 - Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


select top 10 s.artist_id, s.name, s.numberofsongs from 
(
select a.artist_id, a.name, count(a.artist_id) as numberofsongs
from artist A
inner join
album1 AL
on A.artist_id = AL.artist_id
inner join
track T 
on AL.album_id = T.album_id
inner join
genre G
on
T.genre_id = G.genre_id
where g.name = 'Rock'
group by a.artist_id, a.name) as s
group by s.artist_id, s.name, s.numberofsongs
order by numberofsongs desc


/* Q8 - Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_milliseconds from track)
order by milliseconds desc

/* Q8: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


with best_selling_artist as

(
select top 1 b.artist_id, b.artist_name, b.total_sales from
(select ar.artist_id as artist_id, ar.name as artist_name, sum(round(il.unit_price*il.quantity,2)) as total_sales
from invoice_line Il
inner join 
track T
on Il.track_id = T.track_id
inner join
album1 A
on T.album_id = A.album_id
inner join
artist AR
on 
A.artist_id = AR.artist_id
group by ar.artist_id, ar.name) as B
order by b.total_sales desc

)

select c.customer_id, c.first_name, c.last_name, sum(il.unit_price*il.quantity) as total_sales, bsa.artist_name from
customer C
inner join
invoice I
on c.customer_id = i.customer_id
inner join
invoice_line  IL
on 
i.invoice_id = il.invoice_id
inner join
track T
on 
il.track_id = t.track_id
inner join
album1 AL
on
t.album_id = al.album_id
inner join
best_selling_artist bsa
on
al.artist_id = bsa.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by total_sales desc

/* Q9 - We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with popular_genre as 
(
    select count(il.quantity) as purchases, c.country, g.name, g.genre_id, 
	row_number() over(partition by c.country order by count(il.quantity) desc) as rowno 
    from invoice_line il
	inner join 
	invoice i on i.invoice_id = il.invoice_id
	inner join 
	customer c on c.customer_id = i.customer_id
	inner join 
	track t on t.track_id = il.track_id
	inner join
	genre g on g.genre_id = t.genre_id 
	group by c.country, g.name, g.genre_id
	
)
select name as genre_name, country, purchases from popular_genre where rowno <= 1
order by country asc, purchases desc

/* Q10 - Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customter_spent as 
(
		select c.customer_id, c.first_name,c.last_name,i.billing_country,sum(i.total) as total_spending,
	    row_number() over(partition by i.billing_country order by sum(i.total) desc) as rowno 
		from invoice i
		inner join
		customer c on c.customer_id = i.customer_id
		group by c.customer_id, c.first_name, c.last_name,i.billing_country
		
		)
select first_name, last_name, billing_country, total_spending from customter_spent where rowno <= 1
order by billing_country asc, total_spending desc











