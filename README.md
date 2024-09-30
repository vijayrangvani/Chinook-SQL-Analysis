
# Chinook SQL Analysis

This repository contains SQL analysis performed on the **Chinook Digital Music Store** database to answer several business questions related to customer behavior, artist performance, and sales trends.

## Project Overview

The **Chinook Database** is a sample database used to represent a digital music store. This project involves querying the database to gain insights into customer activity, artist contributions, sales performance, and more. The insights drawn from this analysis can help improve business decisions in the digital music industry.

## Table of Contents
1. [Business Tasks](#business-tasks)
2. [Dataset](#dataset)
3. [SQL Queries and Analysis](#sql-queries-and-analysis)
4. [Conclusion](#conclusion)
5. [Files in the Repository](#files-in-the-repository)

## Business Tasks

This analysis aims to answer the following key business questions:
1. Are there albums owned by multiple artists?
2. Are there invoices issued to non-existing customers?
3. Which artist has contributed the maximum number of tracks?
4. Which city has the best customers based on purchases?
5. Who is the best customer based on total spending?
6. ... (Add more business questions as needed)

For the detailed business questions and SQL queries used, refer to the [`business_questions.md`](./business_questions.md) file.

## Dataset

The Chinook database contains the following tables:
- **Artist**: Information on artists.
- **Album**: Details of albums by artists.
- **Track**: Tracks from various albums.
- **Customer**: Customer details including location.
- **Invoice**: Invoices generated from customer purchases.
- **InvoiceLine**: Line items associated with each invoice.
- **Genre**: Genre information for tracks.

For more details about the dataset, you can check the [Chinook Database](https://github.com/lerocha/chinook-database) official repository.

## SQL Queries and Analysis

The SQL queries are designed to address the business questions posed in the project. Some examples include:
1. **Are there albums owned by multiple artists?**
   ```sql
   SELECT AlbumId, COUNT(ArtistId) AS no_of_artists
   FROM album
   GROUP BY AlbumId
   HAVING COUNT(ArtistId) > 1;
   ```
2. **Who is the best customer based on total spending?**
   ```sql
   SELECT c.CustomerId, CONCAT(c.FirstName, ' ', c.LastName) AS Name, SUM(i.Total) AS money_spent
   FROM invoice i
   JOIN customer c ON i.CustomerId = c.CustomerId
   GROUP BY c.CustomerId, c.FirstName, c.LastName
   ORDER BY money_spent DESC;
   ```

For the complete list of queries, see [`chinook_analysis.sql`](./chinook_analysis.sql).

## Conclusion

Through this SQL analysis of the Chinook digital music store database, we’ve gained important insights into customer behaviors, artist performance, and purchasing trends. These findings can help inform business strategies and decision-making in the digital music industry.

## Files in the Repository

- **chinook_analysis.sql**: Contains all SQL queries used for the analysis.
- **business_questions.md**: Explains the business questions and corresponding SQL queries.
- **Chinook_Sqlite.sqlite**: The Chinook database used for analysis (downloadable).

## How to Use This Repository

1. Download the `Chinook_Sqlite.sqlite` file from this repository.
2. Use the SQL queries in the `chinook_analysis.sql` file to run analysis in your preferred SQL environment.
3. Review the business questions in `business_questions.md` for a detailed understanding of the queries used.

## Insights Delivered
- **Multiple Artists**: Identified albums owned by multiple artists.
- **Non-Existing Customers**: Found invoices issued to non-existing customers.
- **Invalid Invoices**: Detected invoice lines associated with non-existing invoices.
- **Untitled Albums**: Discovered albums without titles.
- **Invalid Tracks**: Identified invalid tracks in playlists.
- **Top Artist**: Found the artist with the maximum number of songs.
- **Jazz, Rock, and Pop Fans**: Displayed listeners who love Jazz, Rock, and Pop music.
- **Customer Support**: Identified the employee supporting the most customers.
- **Best Customers**: Analyzed cities corresponding to the best customers.
- **Invoice Analysis**: Found the country with the highest number of invoices.
- **Top Spender**: Identified the best customer based on spending.
- **Rock Concert Locations**: Suggested top cities for hosting a rock concert.
- **Albums with Few Tracks**: Identified albums with less than five tracks.
- **Unpurchased Tracks**: Listed tracks that were never purchased.
- **Multi-Genre Artists**: Found artists who have performed in multiple genres.
- **Popular Genres**: Identified the most and least popular genres based on purchases.
- **Expensive Tracks**: Discovered tracks that are more expensive than others.
- **Popular Artists**: Identified the five most popular artists for the most popular genre.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Contact
**Vijay Rangvani**  
[LinkedIn](https://www.linkedin.com/in/vijayrangvani/) | [Portfolio](https://mavenanalytics.io/profile/Vijay-Rangvani/132085571)
