WITH InvoiceTotals AS (
    SELECT 
        i.InvoiceId,
        i.CustomerId,
        i.BillingCity,
        IFNULL(i.BillingState,'State is Unknown') AS billingState,
        i.BillingCountry,
		CASE strftime("%m",i.InvoiceDate) 
		WHEN "01" THEN "January"
		WHEN "02" THEN "Febuary"
		WHEN "03" THEN "March"
		WHEN "04" THEN "April"
		WHEN "05" THEN "May"
		WHEN "06" THEN "June"
		WHEN "07" THEN "July"
		WHEN "08" THEN "August"
		WHEN "09" THEN "September"
		WHEN "10" THEN "October"
		WHEN "11" THEN "November"
		WHEN "12" THEN "December"
		END AS monthBucket,
		
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
    SUM(it.InvoiceTotal) AS invoiceSales,it.monthBucket
FROM InvoiceLine il
JOIN InvoiceTotals it ON il.InvoiceId = it.InvoiceId
JOIN Customer c ON it.CustomerId = c.CustomerId
JOIN topSales ts ON c.SupportRepId = ts.EmployeeId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY 
    c.FirstName,
    c.LastName,
    it.BillingCountry,
    it.BillingCity,
    it.billingState,
    ar.Name,
    a.Title,
    g.Name,it.monthBucket
ORDER BY 
    trackSales DESC,
    invoiceSales DESC,ts.salesMade DESC,it.monthBucket DESC;

