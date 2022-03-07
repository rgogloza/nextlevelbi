-- https://deepvisualmarketing.github.io/
-- 

-- Pracujesz na tabeli dbo.VehicleAdv 
-- Adv_date jako Data_ogloszenia
-- Price jako Cena
-- Reg_year jako Pierwsza_rejestracja
-- Fuel_type, Engine_size - Rodzaj paliwa a w nawiasie wielko�� silnika - jako Paliwo_silnik
-- Runned_Miles jako Przebieg
-- Color jako Kolor

SELECT 
    va.Adv_date AS Data_ogloszenia
    , va.Price AS Cena
    , va.Reg_year AS Pierwsza_rejestracja 
    , va.Fuel_type + ' ('+ Engine_size +')' AS Paliwo_silnik 
    , va.Runned_Miles AS Przebieg 
    , va.Color AS Kolor 
FROM dbo.VehicleAdv va ;

SELECT * FROM dbo.VehicleAdv va ;

SELECT
    Adv_TK,
    VehicleModel_TK,
    Adv_ID,
    Adv_year,
    Adv_month,
    Adv_date,
    Color,
    Reg_year,
    Bodytype,
    Runned_Miles,
    Engine_size,
    Gearbox,
    Fuel_type,
    Price,
    Seat_num,
    Door_Num
FROM
    VehicleAdv.dbo.VehicleAdv;