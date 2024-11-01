--EDA--
SELECT COUNT(*) FROM public.spotify;
SELECT COUNT(DISTINCT(artist)) FROM public.spotify;
SELECT * FROM public.spotify;
SELECT MAX(duration_min) FROM public.spotify;
SELECT MIN(duration_min) FROM public.spotify;

DELETE FROM public.spotify WHERE duration_min = 0;
SELECT * FROM public.spotify WHERE artist = 'Selena Gomez';

-- Easy Level
-- Retrieve the names of all tracks that have more than 1 billion streams.
-- List all albums along with their respective artists.
-- Get the total number of comments for tracks where licensed = TRUE.
-- Find all tracks that belong to the album type single.
-- Count the total number of tracks by each artist.


-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM public.spotify 
WHERE stream > 1000000000;

-- 2.List all albums along with their respective artists.
SELECT DISTINCT album,
artist FROM public.spotify
ORDER BY 1;

-- 3.Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) AS total_comments
FROM public.spotify WHERE licensed = 'true';

-- 4.Find all tracks that belong to the album type single.
SELECT * FROM public.spotify WHERE album_type = 'single';

-- 5.Count the total number of tracks by each artist.
SELECT 
DISTINCT artist,
COUNT(*) AS total_tracks
FROM public.spotify
GROUP BY artist;
		
-- Medium Level
-- Calculate the average danceability of tracks in each album.
-- Find the top 5 tracks with the highest energy values.
-- List all tracks along with their views and likes where official_video = TRUE.
-- For each album, calculate the total views of all associated tracks.
-- Retrieve the track names that have been streamed on Spotify more than YouTube.

-- 1.Calculate the average danceability of tracks in each album.
SELECT  album,
AVG(danceability) AS avg_danceability
FROM public.spotify
GROUP BY 1
ORDER BY 2 DESC;

-- 2.Find the top 5 tracks with the highest energy values.
SELECT track, MAX(energy) AS highest_energy_values
FROM public.spotify
GROUP BY track
ORDER BY 2 DESC
LIMIT 5;

-- 3.List all tracks along with their views and likes where official_video = TRUE.
SELECT track,
SUM(views) AS total_views,
SUM(likes) AS total_likes
FROM public.spotify WHERE official_video = 'true'
GROUP BY track
ORDER BY 2 DESC; 

-- 4.For each album, calculate the total views of all associated tracks
SELECT 
album,
track,
SUM(views) AS total_views FROM public.spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- 5.Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM (
SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS most_played_spotify,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS most_played_youtube
FROM public.spotify
GROUP BY 1 
) AS most_played 
WHERE most_played_spotify > most_played_youtube
AND most_played_youtube<>0;
	
-- Advanced Level
-- Find the top 3 most-viewed tracks for each artist using window functions.
-- Write a query to find tracks where the liveness score is above the average.
-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
-- Find tracks where the energy-to-liveness ratio is greater than 1.2.
-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

-- 1.Find the top 3 most-viewed tracks for each artist using window functions.
WITH CTE AS(
    SELECT 
        artist,
        track,
        DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
    FROM public.spotify
    GROUP BY artist, track
	ORDER BY 1, 3
) 
SELECT * FROM CTE WHERE rank <= 3;

-- 2. Write a query to find tracks where the liveness score is above the average.
SELECT * FROM public.spotify
WHERE liveness > (SELECT AVG(liveness) FROM public.spotify) ;

-- 3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH difference as(
SELECT 
	album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy
	FROM public.spotify
	GROUP BY album
) 
SELECT album,(highest_energy-lowest_energy) AS energy_difference
FROM difference ORDER BY 2 DESC;

-- 4.Find tracks where the energy-to-liveness ratio is greater than 1.2.
WITH CTE AS (
SELECT 
	track,
	(energy/liveness) AS energy_to_liveness_ratio
	FROM public.spotify
)
SELECT track, energy_to_liveness_ratio FROM CTE
WHERE energy_to_liveness_ratio>1.2 ORDER BY 2 DESC;

--5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT
	track,
	views,
	likes,
	SUM(likes) OVER (ORDER BY views ) AS cumulative_sum
FROM public.spotify
ORDER BY 4 DESC;









