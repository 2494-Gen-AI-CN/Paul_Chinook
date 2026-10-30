-- Chinook query activity (week 3, Thursday). Write one query under each question.
-- How to run this file, what the tables are and what each question expects is in
-- README.md beside it. Test each query at the mysql> prompt first, then paste it here.
-- Hand-in: week-03/hackathon/chinook/chinook-questions.sql in your own learner repo.

USE Chinook;


-- ============================================================
-- Part A: one table (SELECT, WHERE, ORDER BY, LIMIT)
-- ============================================================

-- Q01. Every genre name, A to Z.
SELECT Name FROM Genre ORDER BY Name ASC;

-- Q02. The customers who live in Canada: first name, last name and city, sorted by city.
SELECT FirstName,LastName,City FROM Customer
    WHERE country = 'Canada'
    ORDER BY city;

-- Q03. The ten longest tracks that run over 10 minutes: name and length in minutes
--      (one decimal), longest first.
SELECT Name, ROUND(Milliseconds/60000,1) as "Length in minutes" FROM Track
WHERE Milliseconds > 600000
ORDER BY Milliseconds DESC
LIMIT 10;
    
-- Q04. Invoices from 2025 whose total is above 10: invoice id, date and total, highest total first.
SELECT InvoiceId, InvoiceDate, Total FROM Invoice
WHERE YEAR(InvoiceDate) = 2025 AND Total > 10
ORDER BY Total DESC;

-- Q05. Albums whose title contains the word Live, A to Z.
SELECT Title FROM Album
WHERE Title LIKE '%Live%'
ORDER BY Title;

-- Q06. Customers in the USA or Canada who gave a company name: the full name in one
--      column called customer, the company and the country, sorted by company.
SELECT CONCAT(FirstName, ' ', LastName) AS customer, Company, Country FROM Customer
WHERE (Country = 'USA' OR Country = 'Canada') AND Company IS NOT NULL
ORDER BY Company; 

-- ============================================================
-- Part B: aggregates (GROUP BY, HAVING)
-- ============================================================

-- Q07. One row about the whole Track table: how many tracks, and the shortest, longest
--      and average length in minutes (two decimals).
SELECT COUNT(*) AS "Number of Tracks", 
ROUND(MIN(Milliseconds)/60000,2) AS "Shortest Track (min)", 
ROUND(MAX(Milliseconds)/60000,2) AS "Longest Track (min)", 
ROUND(AVG(Milliseconds)/60000,2) AS "Average Track Length (min)"
FROM Track;

-- Q08. How many customers live in each country, most customers first, then country A to Z.
SELECT country, COUNT(*) AS "Number of Customers" FROM Customer
GROUP BY country
ORDER BY COUNT(*) DESC, country ASC;

-- Q09. Total billed per billing country (two decimals), only the countries billed more
--      than 100 in all, highest first.
SELECT BillingCountry, ROUND(SUM(Total),2) AS "Total Billed" FROM Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 100
ORDER BY SUM(Total) DESC;

-- Q10. Albums with more than 25 tracks: the album id and its track count, most tracks first.
--      (Only the id for now. Q13 adds the title.)
SELECT AlbumId, COUNT(*) AS "Track Count" FROM Track
GROUP BY AlbumId
HAVING COUNT(*) > 25
ORDER BY COUNT(*) DESC;

-- Q11. Per customer id: how many invoices and how much they spent in all (two decimals),
--      only the customers who spent more than 45, biggest spender first.
SELECT CustomerId, COUNT(*) AS "Number of Invoices", ROUND(SUM(Total),2) AS "Total Spent" FROM Invoice
GROUP BY CustomerId
HAVING SUM(Total) > 45
ORDER BY SUM(Total) DESC;

-- ============================================================
-- Part C: joins
-- ============================================================

-- Q12. Every album title with the name of its artist, sorted by artist then title.
SELECT Album.Title AS "Album Title", Artist.Name AS "Artist Name" FROM Album
JOIN Artist ON Album.ArtistId = Artist.ArtistId
ORDER BY Artist.Name, Album.Title;

-- Q13. Q10 again, with the album title and the artist name instead of the id.
SELECT Album.Title AS "Album Title", Artist.Name AS "Artist Name", COUNT(*) AS "Track Count"
FROM Track
JOIN Album ON Track.AlbumId = Album.AlbumId
JOIN Artist ON Album.ArtistId = Artist.ArtistId
GROUP BY Album.AlbumId
HAVING COUNT(*) > 25
ORDER BY COUNT(*) DESC;


-- Q14. Every track by Iron Maiden: album title and track name, sorted by album then track.
SELECT Album.Title AS "Album Title", Track.Name AS "Track Name" FROM Track
JOIN Album ON Track.AlbumId = Album.AlbumId
JOIN Artist ON Album.ArtistId = Artist.ArtistId
WHERE Artist.Name = 'Iron Maiden'
ORDER BY Album.Title, Track.Name;

-- Q15. Every Jazz track: track name, album title and media type name, sorted by album then track.
SELECT Track.Name AS "Track Name",Album.Title AS "Album Title", MediaType.Name AS "Media Type"
FROM Track
JOIN Album ON Track.AlbumId = Album.AlbumId
JOIN MediaType ON Track.MediaTypeId = MediaType.MediaTypeId
WHERE GenreId = 2
ORDER BY Album.Title,Track.Name;


-- Q16. Each customer with the employee who supports them: customer full name and rep full
--      name (one column each), sorted by rep then customer.
SELECT CONCAT(Customer.FirstName,' ', Customer.LastName) AS "Customer's Full Name", 
CONCAT(Employee.FirstName,' ', Employee.LastName) AS "Rep's Full Name"
FROM Customer
JOIN Employee ON Customer.SupportRepId = Employee.EmployeeId
ORDER BY Employee.FirstName,Customer.FirstName;

-- Q17. Every employee and how many customers they support, including the employees who
--      support nobody (they show 0), most customers first, then last name.
SELECT CONCAT(Employee.FirstName,' ', Employee.LastName) AS "Employee's Full Name", 
COUNT(Customer.CustomerId) AS "Number of Customers supported"
FROM Employee
LEFT JOIN Customer ON Employee.EmployeeId = Customer.SupportRepId
GROUP BY Employee.EmployeeId
ORDER BY COUNT(Customer.CustomerId) DESC, Employee.LastName;

-- Q18. The five genres that earned the most: genre name and revenue (the sum of unit price
--      times quantity over every invoice line, two decimals), highest first.
SELECT Genre.Name AS "Genre Name", ROUND(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),2) AS "Revenue"
FROM Genre
JOIN Track ON Genre.GenreId = Track.GenreId
JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId
GROUP BY Genre.GenreId
ORDER BY SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) DESC
LIMIT 5;

-- Q19. How many tracks have never been sold? One number, found with a LEFT JOIN
--      from Track to InvoiceLine and a test for NULL.
SELECT COUNT(*) AS "Number of Unsold Tracks"
FROM Track
LEFT JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId
WHERE InvoiceLine.TrackId IS NULL;

-- ============================================================
-- Part D: subqueries
-- ============================================================

-- Q20. Every track on the album called Let There Be Rock: name and length in milliseconds,
--      in track order (by TrackId). Use a subquery for the album id, not a join.
SELECT Name, Milliseconds FROM Track
WHERE AlbumId = (SELECT AlbumId FROM Album WHERE Title = 'Let There Be Rock')
ORDER BY TrackId;

-- Q21. Tracks that cost more than the average track price: name and unit price,
--      the first ten alphabetically.
SELECT Name, UnitPrice FROM Track
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Track)
ORDER BY Name
LIMIT 10;

-- Q22. Artists with no album at all, A to Z. Write it with NOT IN and a subquery.
SELECT Name FROM Artist
WHERE ArtistId NOT IN (SELECT ArtistId FROM Album)
ORDER BY Name;

-- Q22b. Same question, written as a LEFT JOIN. Same rows?
SELECT Artist.Name AS "Artist Name" FROM Artist
LEFT JOIN Album ON Artist.ArtistId = Album.ArtistId
WHERE Artist.ArtistId NOT IN (SELECT ArtistId FROM Album)
ORDER BY Artist.Name;

-- Q23. The invoice with the highest total: invoice id, customer id, date and total.
SELECT InvoiceId, CustomerId, InvoiceDate, Total FROM Invoice
WHERE Total = (SELECT MAX(Total) FROM Invoice);

-- Q24. Customers who bought at least one Metal track: full name and country, sorted by
--      name. The list of customer ids comes from a subquery that joins Invoice,
--      InvoiceLine, Track and Genre.
SELECT CONCAT(Customer.FirstName,' ', Customer.LastName) AS "Customer's Full Name", Customer.Country
FROM Customer
WHERE Customer.CustomerId IN (
    SELECT DISTINCT Invoice.CustomerId
    FROM Invoice
    JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
    JOIN Track ON InvoiceLine.TrackId = Track.TrackId
    JOIN Genre ON Track.GenreId = Genre.GenreId
    WHERE Genre.Name = 'Metal'
)
ORDER BY Customer.FirstName, Customer.LastName;

-- ============================================================
-- Stretch (for home, or if you finish early)
-- ============================================================

-- Q25. Each employee with the name of the person they report to. The general manager
--      reports to nobody and must still appear, with NULL. Hint: join Employee to
--      itself under two aliases.
SELECT CONCAT(E1.FirstName,' ', E1.LastName) AS "Employee's Full Name",
CONCAT(E2.FirstName,' ', E2.LastName) AS "Reports To"
FROM Employee AS E1
LEFT JOIN Employee AS E2 ON E1.ReportsTo = E2.EmployeeId
ORDER BY E1.FirstName, E1.LastName;

-- Q26. Customers whose total spend is above the average customer's total spend: full name
--      and what they spent (two decimals), biggest first. The average of the per-customer
--      totals needs a subquery in FROM (the notes page calls it a derived table).
SELECT CONCAT(Customer.FirstName,' ', Customer.LastName) AS "Customer's Full Name",
ROUND(SUM(Invoice.Total),2) AS "Total Spent"
FROM Customer
JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
GROUP BY Customer.CustomerId
HAVING SUM(Invoice.Total) > (SELECT AVG(CustomerTotal) FROM (
        SELECT SUM(Invoice.Total) AS CustomerTotal
        FROM Customer
        JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
        GROUP BY Customer.CustomerId
    ) AS CustomerTotals)
ORDER BY SUM(Invoice.Total) DESC;
