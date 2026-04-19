-- 1. A query that gets the 10 most recent albums from different artist
WITH RankedAlbums AS (
    SELECT 
        album_id,
        artist_id,
        title AS album_title,
        release_date,
        ROW_NUMBER() OVER(PARTITION BY artist_id ORDER BY release_date DESC) as rn
    FROM Album
)
SELECT 
    a.album_title,
    art.name AS artist_name,
    a.release_date
FROM RankedAlbums a
JOIN Artist art ON a.artist_id = art.artist_id
WHERE a.rn = 1
ORDER BY a.release_date DESC
LIMIT 10;

-- 2. A query that gets the user and the artist they include most frequently in a playlist
WITH UserArtistCounts AS (
    SELECT 
        u.user_id,
        u.username,
        art.name AS artist_name,
        COUNT(ps.song_id) AS appearance_count,
        RANK() OVER(PARTITION BY u.user_id ORDER BY COUNT(ps.song_id) DESC) as rnk
    FROM User u
    JOIN Playlist p ON u.user_id = p.user_id
    JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
    JOIN Song s ON ps.song_id = s.song_id
    JOIN Album a ON s.album_id = a.album_id
    JOIN Artist art ON a.artist_id = art.artist_id
    GROUP BY 
        u.user_id, 
        u.username, 
        art.artist_id, 
        art.name
)
SELECT 
    username,
    artist_name,
    appearance_count
FROM UserArtistCounts
WHERE rnk = 1;


-- 3. A query that gets the most frequently added artist in playlists per region
WITH RegionArtistCounts AS (
    SELECT 
        r.region AS region_name,
        art.name AS artist_name,
        COUNT(ps.song_id) AS add_count,
        RANK() OVER(PARTITION BY r.region_id ORDER BY COUNT(ps.song_id) DESC) as rnk
    FROM Region r
    JOIN UserRegion ur ON r.region_id = ur.region_id
    JOIN Playlist p ON ur.user_id = p.user_id
    JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
    JOIN Song s ON ps.song_id = s.song_id
    JOIN Album a ON s.album_id = a.album_id
    JOIN Artist art ON a.artist_id = art.artist_id
    GROUP BY 
        r.region_id, 
        r.region, 
        art.artist_id, 
        art.name
)
SELECT 
    region_name,
    artist_name,
    add_count
FROM RegionArtistCounts
WHERE rnk = 1;

-- 4. A query that gets the count of subcripton type, per region
SELECT 
    r.region AS region_name,
    sp.type AS subscription_type,
    COUNT(us.user_subscription_id) AS total_subscriptions
FROM Region r
JOIN UserRegion ur ON r.region_id = ur.region_id
JOIN UserSubscription us ON ur.user_id = us.user_id
JOIN SubscriptionPlan sp ON us.subscription_id = sp.subscription_id
GROUP BY 
    r.region_id,
    r.region,
    sp.subscription_id,
    sp.type
ORDER BY 
    r.region, 
    total_subscriptions DESC;

-- 5. A query that gets the users that has 3 or less playlists created
SELECT 
    u.user_id,
    u.username,
    COUNT(p.playlist_id) AS playlist_count
FROM User u
LEFT JOIN Playlist p ON u.user_id = p.user_id
GROUP BY 
    u.user_id,
    u.username
HAVING 
    COUNT(p.playlist_id) <= 3
ORDER BY 
    playlist_count DESC;

-- 6. A query that gets the popular genre per region
WITH RegionGenreCounts AS (
    SELECT 
        r.region AS region_name,
        g.name AS genre_name,
        COUNT(ps.song_id) AS appearance_count,
        RANK() OVER(PARTITION BY r.region_id ORDER BY COUNT(ps.song_id) DESC) as rnk
    FROM Region r
    JOIN UserRegion ur ON r.region_id = ur.region_id
    JOIN Playlist p ON ur.user_id = p.user_id
    JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
    JOIN SongGenre sg ON ps.song_id = sg.song_id
    JOIN Genre g ON sg.genre_id = g.genre_id
    GROUP BY 
        r.region_id, 
        r.region, 
        g.genre_id, 
        g.name
)
SELECT 
    region_name,
    genre_name,
    appearance_count
FROM RegionGenreCounts
WHERE rnk = 1;

-- 7. A query that gets the artist that performs more than one genre
SELECT 
    art.artist_id,
    art.name AS artist_name,
    COUNT(DISTINCT sg.genre_id) AS genre_count
FROM Artist art
JOIN Album a ON art.artist_id = a.artist_id
JOIN Song s ON a.album_id = s.album_id
JOIN SongGenre sg ON s.song_id = sg.song_id
GROUP BY 
    art.artist_id,
    art.name
HAVING 
    COUNT(DISTINCT sg.genre_id) > 1
ORDER BY 
    genre_count DESC;

-- 8. A query that gets the monthly revenue per region
SELECT 
    r.region AS region_name,
    ROUND(SUM(sp.price), 2) AS total_monthly_revenue
FROM Region r
JOIN UserRegion ur ON r.region_id = ur.region_id
JOIN UserSubscription us ON ur.user_id = us.user_id
JOIN SubscriptionPlan sp ON us.subscription_id = sp.subscription_id
GROUP BY 
    r.region_id,
    r.region
ORDER BY 
    total_monthly_revenue DESC;

-- 9. A query that gets the average number of devices per subscriber type
WITH UserDeviceCounts AS (
    SELECT 
        u.user_id,
        us.subscription_id,
        COUNT(ud.device_id) AS device_count
    FROM User u
    JOIN UserSubscription us ON u.user_id = us.user_id
    LEFT JOIN UserDevice ud ON u.user_id = ud.user_id
    GROUP BY 
        u.user_id, 
        us.subscription_id
)
SELECT 
    sp.type AS subscription_type,
    ROUND(AVG(udc.device_count), 0) AS avg_devices_per_user
FROM UserDeviceCounts udc
JOIN SubscriptionPlan sp ON udc.subscription_id = sp.subscription_id
GROUP BY 
    sp.type,
    sp.subscription_id
ORDER BY 
    avg_devices_per_user DESC;

-- 10. A query that gets the most used device type
SELECT 
    d.type AS device_type,
    COUNT(ud.user_device_id) AS usage_count
FROM Device d
JOIN UserDevice ud ON d.device_id = ud.device_id
GROUP BY 
    d.type
ORDER BY 
    usage_count DESC
LIMIT 1;