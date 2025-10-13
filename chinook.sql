WITH InvoiceTotals AS (
    SELECT
        i.InvoiceId,
        i.CustomerId,
        i.BillingCity,
        IFNULL(i.BillingState,'State is Unknown') AS billingState,
        i.BillingCountry,
        i.Total AS InvoiceTotal
    FROM Invoice i
),
topSales AS (
    SELECT
        e.EmployeeId,
        e.FirstName,
        e.LastName,
        SUM(i.Total) AS salesMade
    FROM Employee e
    JOIN Customer c ON e.EmployeeId = c.SupportRepId
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY e.EmployeeId
    ORDER BY salesMade DESC
),
CustomerStats AS (
  SELECT
       c.CustomerID,
       CASE
         WHEN COUNT(i.InvoiceId) > 1 THEN 'Repeat'
         ELSE 'One-Time'
         END AS CustomerType,
         SUM(i.Total) AS totalSpend
         FROM Customer c
         JOIN Invoice i ON c.CustomerId = i.CustomerId
         GROUP BY c.CustomerId

)

SELECT
    c.FirstName,
    c.LastName,
    it.BillingCountry,
    it.BillingCity,
    it.billingState,
	ts.FirstName,ts.LastName,ts.salesMade,
    ar.Name AS ArtistName,
    a.Title AS AlbumName,
    g.Name AS GenreName,
    SUM(il.Quantity * il.UnitPrice) AS trackSales,
    SUM(DISTINCT it.InvoiceTotal) AS invoiceSales
FROM InvoiceLine il
JOIN InvoiceTotals it ON il.InvoiceId = it.InvoiceId
JOIN Customer c ON it.CustomerId = c.CustomerId
JOIN topSales ts ON c.SupportRepId = ts.EmployeeId
JOIN CustomerStats cs ON c.CustomerId = cs.CustomerId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY
    c.FirstName,
    c.LastName,
    cs.CustomerType,
    cs.totalSpend,
    it.BillingCountry,
    it.BillingCity,
    it.billingState,
    ar.Name,
    a.Title,
    g.Name
ORDER BY
    trackSales DESC,
    invoiceSales DESC,ts.salesMade DESC,cs.totalSpend;
