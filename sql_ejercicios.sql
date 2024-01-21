CREATE DATABASE ejercicios;
USE ejercicios;

SELECT * FROM athlete_events;

-- cuantos juegos olimpicos se han celebrado?
SELECT COUNT(distinct Year) AS JO_total FROM athlete_events;

-- enumero todos los juegos olimpicos celebrados hasta ahora
SELECT distinct Games AS JO_total FROM athlete_events;

-- menciona el numero total de naciones que participaron en cada juego olimpico
SELECT Games, COUNT(distinct Team) AS naciones FROM athlete_events
GROUP BY Games;

-- en q año se vio el mayor y menor numero de paises participando los JO
(SELECT Year, COUNT(distinct Team) AS numero_paises
FROM athlete_events
group by Year
ORDER BY numero_paises DESC
LIMIT 1)
UNION
(SELECT Year, COUNT(distinct Team) AS numero_paises
FROM athlete_events
group by Year
ORDER BY numero_paises ASC
LIMIT 1);

-- q nacion ha participado en todos los juegos olimpicos
SELECT * FROM athlete_events;

SELECT Team, count(DISTINCT Year) AS cant_total_JO 
FROM athlete_events
GROUP BY Team
HAVING cant_total_JO = (SELECT COUNT(distinct Year) FROM athlete_events);

-- identifica el deporte que se jugo en todas las olimpiadas de verano
CREATE TEMPORARY TABLE t1 (select COUNT(DISTINCT Games) AS total_juegos_verano
FROM athlete_events
WHERE Season = 'Summer'
ORDER BY Games);

SELECT * FROM t1

SELECT * FROM athlete_events;

CREATE TEMPORARY TABLE t3 (select Sport, COUNT(Games) AS num_juegos
FROM (SELECT DISTINCT Sport, Games FROM athlete_events
WHERE Season = 'Summer'
ORDER BY Games) AS X
)
SELECT Sport, COUNT(Games) AS num_juegos
FROM (SELECT DISTINCT Sport, Games FROM athlete_events
WHERE Season = 'Summer'
ORDER BY Games) AS X
GROUP BY Sport);

SELECT * FROM t3

-- 8 obten el numero total de deportes jugados en cada JO 
SELECT * FROM athlete_events;

SELECT Games, COUNT(distinct(Sport)) as cant_de_veces FROM athlete_events
GROUP BY Games


-- 9 encuentra la proporcion de atletas Mas y Fem que participan en los juegos olimpicos
SELECT * FROM athlete_events;

SELECT Year, 
	ROUND(MaleCount/TotalCount,2) AS Male_proportion,
    ROUND(FemaleCount/TotalCount,2) AS Female_proportion
FROM(
SELECT YEAR,
	COUNT(*) AS TotalCount,
    SUM(CASE WHEN SEX = 'M' THEN 1 ELSE 0 END) AS MaleCount,
	SUM(CASE WHEN SEX = 'F' THEN 1 ELSE 0 END) AS FemaleCount
    FROM athlete_events
    GROUP BY Year) AS sq
ORDER BY Year;
    
-- 10 busque los mejores atletas que han ganado
-- la mayor cantidad de medalla de oro

drop table s1

CREATE TEMPORARY TABLE s1(
SELECT Name, COUNT(*) AS Total_medalla_oro FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name 
ORDER BY Total_medalla_oro DESC
);

SELECT * FROM s1;

SELECT *
FROM (SELECT s1.*,
	DENSE_RANK () OVER(ORDER BY s1.Total_medalla_oro DESC) AS DRK
FROM s1) AS ranked
WHERE DRK <= 5;

-- 11 obten los 5 mejores atletas q han ganado
-- la mayoria de las medallas (bronce, plata, oro)

SELECT * FROM athlete_events;

SELECT
	Name,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze,
	COUNT(*) AS total_medals
FROM athlete_events
where Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Name
ORDER BY total_medals DESC
LIMIT 5;

-- 12 obten los 5 paises mas existosos de los juegos olimpicos
-- el exito se define por el numero de medallas ganadas

SELECT
	Team AS Country,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze,
	COUNT(*) AS total_medals
FROM athlete_events
where Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Team
ORDER BY total_medals DESC
LIMIT 5;

-- 13 enumeraa el numero total de medallas de oro, plata
-- y bronce ganadas por cada pais
SELECT
	Team AS Country,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze,
	COUNT(*) AS total_medals
FROM athlete_events
where Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Team
ORDER BY Country;

-- 14 enumera el numero total de medallas de oro, planta y bronce
-- ganadas por cada pais en relacion con cada juego olimpico
SELECT
	Team AS Country,
    Year,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze,
	COUNT(*) AS total_medals
FROM athlete_events
where Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Team, Year
ORDER BY Country;

-- 15 identifica q pais gano la mayoria de las medallas
-- de oro, plata, bronce en cada juego olimpico
SELECT
	Year,
    Medal_type,
    winning_country,
    medal_count,
    RANK() OVER (PARTITION BY Year, Medal_type ORDER BY medal_count desc) AS country_rank
    from (
			SELECT
				Year,
				Team AS winning_country,
				Medal, 
				COUNT(*) AS medal_count,
				CASE
					WHEN Medal = 'Gold' THEN 'Gold'
					WHEN Medal = 'Silver' THEN 'Silver'
					WHEN Medal = 'Bronze' THEN 'Bronze'
				END AS medal_type
			FROM athlete_events
			WHERE Medal IN ('Gold', 'Silver', 'Bronze')
			GROUP BY Year, winning_country, Medal
            ) as medalCounts
            
-- 16 en q deportes india ha ganado la mayor cantidad de medallaa
SELECT
	Sport,
    Event,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze,
	COUNT(*) AS total_medals
FROM athlete_events
where Team = 'India' and Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Sport, Event
ORDER BY Gold DESC, Silver DESC, Bronze DESC;

-- 17 DESGLOSA TODOS LOS jo EN LOS Q INDIA GANO
-- MEDALLAS DE HOCKEY Y CUANTAS MEDALLAS GANO EN CADA UNO DE ELLOS
SELECT
	Year AS  olimpic_year,
    COUNT(*) AS total_medals,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM athlete_events
where Team = 'India' and Medal IN ('Gold', 'Silver', 'Bronze') AND Sport = 'Hockey'
GROUP BY Year
ORDER BY olimpic_year;  