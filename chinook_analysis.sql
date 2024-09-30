-- 1) Are there any albums owned by multiple artist?
 select AlbumId,count(1) from album
 group by AlbumId
 having count(1)>1;

-- 2) Is there any invoice which is issued to a non existing customer?
select * 
from invoice i 
left join customer c on i.CustomerId = c.CustomerId
where c.CustomerId is not  null;

-- 3) Is there any invoice line for a non existing invoice?
select * 
from invoiceline il 
where not EXISTS (select * from invoice i where i.InvoiceId =il.InvoiceId);

-- 4) Are there albums without a title?
select * from album where title is null;

-- 5) Are there invalid tracks in the playlist?
select * 
from playlisttrack t 
where not EXISTS (select * from playlist p where p.PlaylistId=t.PlaylistId);


-- SQL Queries to answer some questions from the chinook database.
-- 1) Find the artist who has contributed with the maximum no of songs. Display the artist name and the no of albums.

select ar.Name, count(t.TrackId) as no_of_songs
from track t 
join album a on t.AlbumId = a.AlbumId
join artist ar on ar.ArtistId = a.ArtistId
group by ar.name 
order by no_of_songs desc
limit 1;

-- Iron Maiden	213

-- 2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select concat(c.FirstName,' ',c.LastName) as Name,c.Email,c.Country
from genre g
join track t on g.GenreId =t.GenreId
join invoiceline il on t.TrackId =il.TrackId
join invoice i on i.InvoiceId =il.InvoiceId
join customer c on i.CustomerId =c.CustomerId
where g.Name in ('Jazz','Rock','Pop');

-- 943 rows
 
-- 3) Find the employee who has supported the most no of customers. Display the employee name and designation

select concat(e.FirstName,' ',e.LastName) as Name,e.Title,count(c.CustomerId) as no_of_customers 
from customer c
join employee e on c.SupportRepId = e.EmployeeId
GROUP BY e.FirstName,e.LastName,e.Title
order by no_of_customers desc
limit 1;

-- Jane Peacock	Sales Support Agent	21

-- 4) Which city corresponds to the best customers?

with cte as 
(
	select c.City,i.total,rank() over(order by total desc) as rnk
    from customer c 
    join invoice i on c.CustomerId = i.CustomerId
)
select city from cte where rnk = 1;


-- 5) The highest number of invoices belongs to which country?
select BillingCountry as country, count(1) as no_of_invoices
from invoice 
group by BillingCountry
order by no_of_invoices desc
limit 1;

-- USA	91

-- 6) Name the best customer (customer who spent the most money).

select c.CustomerId,concat(c.FirstName,' ',c.LastName) as Name,sum(i.Total) as money_spend
from invoice i 
join customer c on i.CustomerId = c.CustomerId
group by c.CustomerId,c.FirstName,c.LastName
order by money_spend desc;

-- 6	Helena Holý	49.62

-- 7) Suppose you want to host a rock concert in a city and want to know which location should host it.
with cte as (
	select BillingCity as City,count(1) as No_of_songs,
           rank() over (order by count(1) desc) as rnk
	from genre g
	join track t on g.GenreId = t.GenreId
	join invoiceline il on il.TrackId=t.TrackId
	join invoice i on i.InvoiceId =il.InvoiceId
	where g.Name ='Rock'
	GROUP BY BillingCity
)
select City from cte where rnk <=5;

--  São Paulo	40

-- 8) Identify all the albums who have less then 5 track under them.

with cte as 
(
	select a.AlbumId,count(t.TrackId) as no_of_tracks
	from album a 
	join track t on a.AlbumId =t.AlbumId
	group by a.AlbumId
	having no_of_tracks < 5
) 
select a.Title,ar.Name,c.no_of_tracks
from cte c 
join album a on c.AlbumId= a.AlbumId
join artist ar on a.ArtistId=ar.ArtistId
order by no_of_tracks desc;
 
-- 9) Display the track, album, artist and the genre for all tracks which are not purchased.

select t.name as 'track',a.Title as 'album', ar.Name as 'artist',g.Name as 'genre'
from track t 
join album a on t.AlbumId=a.AlbumId
join artist ar on a.ArtistId =ar.ArtistId
join genre g on g.GenreId= t.GenreId
where  not exists ( select * from invoiceline il where il.trackid =t.trackid);

-- 10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

with temp as 
(
	select distinct ar.Name as artist_name, g.Name as genre_name
	from artist ar
	join album a on ar.ArtistId= a.ArtistId
	join track t on t.AlbumId =a.AlbumId
	join genre g on g.GenreId=t.GenreId
),
multi_genre as 
(
	select artist_name,count(genre_name) as genre_cnt
	from temp
	group by artist_name
	having genre_cnt > 1
)
select m.artist_name,t.genre_name
from multi_genre m 
join temp t on m.artist_name=t.artist_name
order by 1,2;

-- 11) Which is the most popular and least popular genre? (Popularity is defined based on how many times it has been purchased.)

with temp as 
(
	select g.Name as genre_name, count(*) as no_of_purchases,
    rank() over(order by count(*) desc) as rnk 
	from invoiceline il 
	join track t on il.TrackId = t.TrackId
	join genre g on t.GenreId =g.GenreId
    group by 1
),
maxrnk as (select max(rnk) as max_rnk from temp)
select genre_name, 
case when rnk = 1 then 'most Popular genre'
when rnk = max_rnk then 'least Popular genre'
end as Popularity 
from temp t 
left join maxrnk m on t.rnk = m.max_rnk
where rnk =1 or rnk =max_rnk;
-- 12) Identify if there are tracks more expensive than others. 
-- If there are then display the track name along with the album title and artist name for these expensive tracks.

select t.Name as track_name, a.Title as album_name, ar.Name as artist_name
from track t 
join album a on a.AlbumId = t.AlbumId
join artist ar on ar.ArtistId = a.ArtistId
where UnitPrice > (select min(UnitPrice) from invoiceline);


-- 13) Identify the 5 most popular artist for the most popular genre. 
-- Display the artist name along with the no of songs.
-- (Popularity is defined based on how many songs an artist has performed in for the particular genre.)

with temp as 
(
	select g.GenreId,g.Name as genre_name , count(*) as no_of_tracks,
    rank () over(order by count(*) desc) as rnk
    from genre g
    join track t on g.GenreId=t.GenreId
    join invoiceline il on il.TrackId = t.TrackId
    group by 1,2
)
,popular_genre as 
(
	select GenreId,genre_name
    from temp where rnk = 1 
)
,cte as 
(
	select ar.Name as artist_name,count(*) as no_of_songs,
    rank() over(order by count(*) desc) as rnk
    from track t 
    join album a on t.AlbumId=a.AlbumId
    join artist ar on ar.ArtistId = a.ArtistId
    join popular_genre p on p.GenreId = t.GenreId
    group by 1
)
select artist_name,no_of_songs from cte where rnk <=5;

-- 14.) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name
select artist_name,no_of_songs 
from (
	select ar.Name as artist_name, count(*) as no_of_songs,
	rank() over(order by count(*) desc) as rnk  
	from artist ar
	join album a on ar.ArtistId = a.ArtistId
	join track t on a.AlbumId = t.AlbumId
    group by 1
) x where rnk =1;

-- 15.) Are there any albums owned by multiple artist?

select a.AlbumId,count(ar.ArtistId) as no_of_artists
from album a 
join artist ar on a.ArtistId = ar.ArtistId
group by 1
having no_of_artists>1;
