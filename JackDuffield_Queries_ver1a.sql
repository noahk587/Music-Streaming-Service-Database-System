-- Jack Duffield SQL Queries

-- 1. Count of Subscribers per Plan Type

SELECT sp.type, sp.price, COUNT(us.user_id) AS subscribers
FROM SubscriptionPlan sp
LEFT JOIN UserSubscription us ON sp.subscription_id = us.subscription_id
GROUP BY sp.subscription_id
ORDER BY subscribers DESC;

-- 2. Top 10 Biggest Playlists and their Authors

SELECT p.name AS playlist, u.name AS owner, COUNT(ps.song_id) AS songs
FROM Playlist p
JOIN User u ON p.user_id = u.user_id
LEFT JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
GROUP BY p.playlist_id
ORDER BY songs DESC
LIMIT 10;

-- 3. Most Eclectic Artists (Artists whose music span the most Genres)

SELECT ar.name AS artist, COUNT(DISTINCT sg.genre_id) AS genre_count,
       GROUP_CONCAT(DISTINCT g.name) AS genres
FROM Artist ar
JOIN Album al ON ar.artist_id = al.artist_id
JOIN Song s ON al.album_id = s.album_id
JOIN SongGenre sg ON s.song_id = sg.song_id
JOIN Genre g ON sg.genre_id = g.genre_id
GROUP BY ar.artist_id
ORDER BY genre_count DESC;

-- 4. Top 10 Most Eclectic Playlists (Playlists whose music span the most Genres)

SELECT p.name AS playlist, u.name AS owner,
       COUNT(DISTINCT sg.genre_id) AS unique_genres,
       COUNT(ps.song_id) AS total_songs
FROM Playlist p
JOIN User u ON p.user_id = u.user_id
JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
JOIN SongGenre sg ON ps.song_id = sg.song_id
GROUP BY p.playlist_id
ORDER BY unique_genres DESC
LIMIT 10;

-- 5. Subscription Plans according to Device Type

SELECT d.type AS device_type, sp.type AS plan, COUNT(DISTINCT u.user_id) AS users
FROM User u
JOIN UserDevice ud ON u.user_id = ud.user_id
JOIN Device d ON ud.device_id = d.device_id
JOIN UserSubscription us ON u.user_id = us.user_id
JOIN SubscriptionPlan sp ON us.subscription_id = sp.subscription_id
GROUP BY d.type, sp.type
ORDER BY d.type, users DESC;

-- 6. Monthly Revenue according to each Subscription Plan

SELECT sp.type, sp.price, sp.duration_months,
       COUNT(us.user_id) AS subscribers,
       ROUND(COUNT(us.user_id) * sp.price / sp.duration_months, 2) AS monthly_revenue
FROM SubscriptionPlan sp
LEFT JOIN UserSubscription us ON sp.subscription_id = us.subscription_id
GROUP BY sp.subscription_id
ORDER BY monthly_revenue DESC;

-- 7. Lifetime Subscription Payment Value per User

SELECT u.name, u.email,
       COUNT(us.user_subscription_id) AS total_plans,
       ROUND(SUM(sp.price), 2) AS lifetime_value
FROM User u
JOIN UserSubscription us ON u.user_id = us.user_id
JOIN SubscriptionPlan sp ON us.subscription_id = sp.subscription_id
GROUP BY u.user_id
ORDER BY lifetime_value DESC;

-- 8. Songs with greater than Average Duration

SELECT s.title, ar.name AS artist, al.title AS album, s.duration
FROM Song s
JOIN Album al ON s.album_id = al.album_id
JOIN Artist ar ON al.artist_id = ar.artist_id
WHERE s.duration > (SELECT AVG(duration) FROM Song)
ORDER BY s.duration DESC;

-- 9. Mobile Only Users + Count of Devices

SELECT u.name, u.email,
       COUNT(ud.device_id) AS mobile_devices
FROM User u
JOIN UserDevice ud ON u.user_id = ud.user_id
JOIN Device d ON ud.device_id = d.device_id
GROUP BY u.user_id
HAVING COUNT(DISTINCT CASE WHEN d.type != 'Mobile' THEN d.device_id END) = 0
ORDER BY mobile_devices DESC;

-- 10. Average Songs per Playlist by Subscription Plan

SELECT sp.type AS plan,
       COUNT(DISTINCT p.playlist_id) AS total_playlists,
       COUNT(ps.song_id) AS total_songs,
       ROUND(COUNT(ps.song_id) * 1.0 / COUNT(DISTINCT p.playlist_id), 1) AS avg_songs_per_playlist
FROM SubscriptionPlan sp
JOIN UserSubscription us ON sp.subscription_id = us.subscription_id
JOIN Playlist p ON us.user_id = p.user_id
LEFT JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
GROUP BY sp.type
ORDER BY avg_songs_per_playlist DESC;