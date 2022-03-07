/*
This query shows how the total trip distances and average trip distance relate to the number of passengers.
*/

SELECT PassengerCount,
      SUM(TripDistanceMiles) as SumTripDistance,
      AVG(TripDistanceMiles) as AvgTripDistance
FROM  dbo.Trip
WHERE TripDistanceMiles > 0 AND PassengerCount > 0
GROUP BY PassengerCount
ORDER BY PassengerCount