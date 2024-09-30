# Business Questions - Chinook SQL Analysis 🎶

This document outlines the key business questions addressed in the **Chinook SQL Analysis** project. Each question is answered using specific SQL queries provided in the main SQL file.

---

### 1. **Are there any albums owned by multiple artists?**

- **Objective**: Identify albums that have more than one associated artist.
- **SQL Query**:

    ```sql
    SELECT AlbumId, COUNT(1) 
    FROM album
    GROUP BY AlbumId
    HAVING COUNT(1) > 1;
    ```

---

### 2. **Is there any invoice issued to a non-existing customer?**

- **Objective**: Check for invoices that do not correspond to existing customers.
- **SQL Query**:

    ```sql
    SELECT * 
    FROM invoice i 
    LEFT JOIN customer c ON i.CustomerId = c.CustomerId
    WHERE c.CustomerId IS NULL;
    ```

---

### 3. **Is there any invoice line for a non-existing invoice?**

- **Objective**: Identify invoice lines that do not belong to any existing invoices.
- **SQL Query**:

    ```sql
    SELECT * 
    FROM invoiceline il 
    WHERE NOT EXISTS (SELECT * FROM invoice i WHERE i.InvoiceId = il.InvoiceId);
    ```

---

### 4. **Are there albums without a title?**

- **Objective**: Find albums that do not have a title.
- **SQL Query**:

    ```sql
    SELECT * 
    FROM album 
    WHERE Title IS NULL;
    ```

---

### 5. **Are there invalid tracks in the playlist?**

- **Objective**: Identify tracks that do not belong to any existing playlist.
- **SQL Query**:

    ```sql
    SELECT * 
    FROM playlisttrack t 
    WHERE NOT EXISTS (SELECT * FROM playlist p WHERE p.PlaylistId = t.PlaylistId);
    ```

---

### 6. **Find the artist who has contributed the maximum number of songs.**

- **Objective**: Display the artist name and the number of albums.
- **SQL Query**:

    ```sql
    SELECT ar.Name, COUNT(t.TrackId) AS no_of_songs
    FROM track t 
    JOIN album a ON t.AlbumId = a.AlbumId
    JOIN artist ar ON ar.ArtistId = a.ArtistId
    GROUP BY ar.Name 
    ORDER BY no_of_songs DESC
    LIMIT 1;
    ```

---

### 7. **Display the name, email, and country of all listeners who love Jazz, Rock, and Pop music.**

- **Objective**: List customers who have purchased Jazz, Rock, or Pop tracks.
- **SQL Query**:

    ```sql
    SELECT CONCAT(c.FirstName, ' ', c.LastName) AS Name, c.Email, c.Country
    FROM genre g
    JOIN track t ON g.GenreId = t.GenreId
    JOIN invoiceline il ON t.TrackId = il.TrackId
    JOIN invoice i ON i.InvoiceId = il.InvoiceId
    JOIN customer c ON i.CustomerId = c.CustomerId
    WHERE g.Name IN ('Jazz', 'Rock', 'Pop');
    ```

---

### 8. **Find the employee who has supported the most number of customers.**

- **Objective**: Display the employee name and designation.
- **SQL Query**:

    ```sql
    SELECT CONCAT(e.FirstName, ' ', e.LastName) AS Name, e.Title, COUNT(c.CustomerId) AS no_of_customers 
    FROM customer c
    JOIN employee e ON c.SupportRepId = e.EmployeeId
    GROUP BY e.FirstName, e.LastName, e.Title
    ORDER BY no_of_customers DESC
    LIMIT 1;
    ```

---

### 9. **Which city corresponds to the best customers?**

- **Objective**: Find the city with the highest sales.
- **SQL Query**:

    ```sql
    WITH cte AS 
    (
        SELECT c.City, SUM(i.Total) AS total_sales, RANK() OVER (ORDER BY total_sales DESC) AS rnk
        FROM customer c 
        JOIN invoice i ON c.CustomerId = i.CustomerId
        GROUP BY c.City
    )
    SELECT City 
    FROM cte 
    WHERE rnk = 1;
    ```

---

### 10. **The highest number of invoices belongs to which country?**

- **Objective**: Identify the country with the most invoices.
- **SQL Query**:

    ```sql
    SELECT BillingCountry AS country, COUNT(1) AS no_of_invoices
    FROM invoice 
    GROUP BY BillingCountry
    ORDER BY no_of_invoices DESC
    LIMIT 1;
    ```

---

### 11. **Name the best customer (who spent the most money).**

- **Objective**: Identify the customer with the highest total spending.
- **SQL Query**:

    ```sql
    SELECT c.CustomerId, CONCAT(c.FirstName, ' ', c.LastName) AS Name, SUM(i.Total) AS money_spent
    FROM invoice i 
    JOIN customer c ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
    ORDER BY money_spent DESC
    LIMIT 1;
    ```

---

### 12. **Identify all the albums that have less than 5 tracks.**

- **Objective**: List albums with fewer than 5 tracks.
- **SQL Query**:

    ```sql
    WITH cte AS 
    (
        SELECT a.AlbumId, COUNT(t.TrackId) AS no_of_tracks
        FROM album a 
        JOIN track t ON a.AlbumId = t.AlbumId
        GROUP BY a.AlbumId
        HAVING no_of_tracks < 5
    )
    SELECT a.Title, ar.Name, c.no_of_tracks
    FROM cte c 
    JOIN album a ON c.AlbumId = a.AlbumId
    JOIN artist ar ON a.ArtistId = ar.ArtistId
    ORDER BY c.no_of_tracks DESC;
    ```

---

### 13. **Display the track, album, artist, and genre for all tracks which are not purchased.**

- **Objective**: Identify tracks that have never been purchased.
- **SQL Query**:

    ```sql
    SELECT t.Name AS 'track', a.Title AS 'album', ar.Name AS 'artist', g.Name AS 'genre'
    FROM track t 
    JOIN album a ON t.AlbumId = a.AlbumId
    JOIN artist ar ON a.ArtistId = ar.ArtistId
    JOIN genre g ON g.GenreId = t.GenreId
    WHERE NOT EXISTS (SELECT * FROM invoiceline il WHERE il.TrackId = t.TrackId);
    ```

---

### 14. **Find artists who have performed in multiple genres.**

- **Objective**: List artists and their genres.
- **SQL Query**:

    ```sql
    WITH temp AS 
    (
        SELECT DISTINCT ar.Name AS artist_name, g.Name AS genre_name
        FROM artist ar
        JOIN album a ON ar.ArtistId = a.ArtistId
        JOIN track t ON t.AlbumId = a.AlbumId
        JOIN genre g ON g.GenreId = t.GenreId
    ),
    multi_genre AS 
    (
        SELECT artist_name, COUNT(genre_name) AS genre_cnt
        FROM temp
        GROUP BY artist_name
        HAVING genre_cnt > 1
    )
    SELECT m.artist_name, t.genre_name
    FROM multi_genre m 
    JOIN temp t ON m.artist_name = t.artist_name
    ORDER BY 1, 2;
    ```

---

### 15. **Identify if there are tracks more expensive than others.**

- **Objective**: Display tracks that are more expensive than the cheapest track.
- **SQL Query**:

    ```sql
    SELECT t.Name AS track_name, a.Title AS album_name, ar.Name AS artist_name
    FROM track t 
    JOIN album a ON a.AlbumId = t.AlbumId
    JOIN artist ar ON ar.ArtistId = a.ArtistId
    WHERE UnitPrice > (SELECT MIN(UnitPrice) FROM track);
    ```

---

This concludes the list of business questions and their respective SQL queries for the Chinook SQL Analysis project.
