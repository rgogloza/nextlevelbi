-- 02. data types

-- Zamiana kolumny Przebieg, przeliczenie mil na kilometry
   -- zaokrąglenie do pełnych kilometrów
   -- https://docs.microsoft.com/en-us/sql/t-sql/functions/functions?view=sql-server-ver15
-- dodanie na końcu kolumny Liczba_miejsc. 
   -- Połączenie ze sobą, ciągu znaków Miejsca: i kolumny Seat_num 

SELECT 
    va.Adv_date AS Data_ogloszenia
    , va.Price AS Cena
    , va.Reg_year AS Pierwsza_rejestracja 
    , va.Fuel_type + ' ('+ Engine_size +')' AS Paliwo_silnik 
    , Round(va.Runned_Miles*1.6,0) AS Przebieg 
    , va.Color AS Kolor 
    , 'Miejsca: ' + CAST(va.Seat_num AS varchar(2)) AS Liczba_miejsc 
FROM dbo.VehicleAdv va ;


SELECT * FROM INFORMATION_SCHEMA.COLUMNS c 