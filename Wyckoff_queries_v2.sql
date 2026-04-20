-- =============================================================================
-- CSCE 5350.002 Group 7 - Music Streaming Service Database
-- SQL Queries: Andrew Wyckoff
-- =============================================================================
-- Run after Database_Setup.SQL. The setup script creates all 15 tables and
-- loads the toy dataset; this file contains the CRUD and analytical queries
-- that run against it.
-- Target: SQLite 3
-- =============================================================================


-- =============================================================================
-- SECTION A: CRUD DEMONSTRATIONS
-- =============================================================================

-- A1. INSERT: add a new device type and link it to an existing user
INSERT INTO Device (device_id, name, type) VALUES (11, 'Sonos One', 'Smart Speaker');
INSERT INTO UserDevice (user_device_id, user_id, device_id) VALUES (69, 1, 11);

-- A2. INSERT: create a new playlist for user 1 and add two songs to it
INSERT INTO Playlist (playlist_id, user_id, name) VALUES (31, 1, 'Late Night Coding');
INSERT INTO UserPlaylist (user_playlist_id, user_id, playlist_id) VALUES (106, 1, 31);
INSERT INTO PlaylistSong (playlist_song_id, playlist_id, song_id) VALUES
  (467, 31, 2),
  (468, 31, 15);

-- A3. SELECT: find every playlist a specific user owns, with song counts
SELECT p.playlist_id, p.name AS playlist_name, COUNT(ps.song_id) AS song_count
FROM Playlist p
LEFT JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
WHERE p.user_id = 41
GROUP BY p.playlist_id, p.name;

-- A4. SELECT: find every device registered to a given user
SELECT d.device_id, d.name, d.type
FROM Device d
JOIN UserDevice ud ON d.device_id = ud.device_id
WHERE ud.user_id = 1;

-- A5. SELECT: all songs tagged with a specific genre (search by genre name)
SELECT s.song_id, s.title, s.duration
FROM Song s
JOIN SongGenre sg ON s.song_id = sg.song_id
JOIN Genre g ON sg.genre_id = g.genre_id
WHERE g.name = 'Pop';

-- A6. UPDATE: rename a playlist
UPDATE Playlist SET name = 'Morning Workout Mix' WHERE playlist_id = 1;

-- A7. UPDATE: reassign a genre tag (e.g., fix a mislabeled song)
UPDATE SongGenre SET genre_id = 6 WHERE song_id = 10 AND genre_id = 1;

-- A8. DELETE: remove a song from a playlist (does not delete the song itself)
DELETE FROM PlaylistSong WHERE playlist_id = 31 AND song_id = 15;

-- A9. DELETE: unlink a device from a user (user no longer uses that device)
DELETE FROM UserDevice WHERE user_id = 1 AND device_id = 11;


-- =============================================================================
-- SECTION B: JOIN AND AGGREGATE QUERIES
-- =============================================================================

-- B1. Flagship query from the project description:
-- All songs with artist and album names that appear in a playlist created by
-- a specific user. Joins User, Playlist, PlaylistSong, Song, Album, Artist.
SELECT u.name AS user_name,
       p.name AS playlist_name,
       s.title AS song_title,
       al.title AS album_title,
       ar.name AS artist_name
FROM User u
JOIN Playlist p ON u.user_id = p.user_id
JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
JOIN Song s ON ps.song_id = s.song_id
JOIN Album al ON s.album_id = al.album_id
JOIN Artist ar ON al.artist_id = ar.artist_id
WHERE u.user_id = 41
ORDER BY p.name, s.title;

-- B2. Top 5 genres by number of songs
SELECT g.name AS genre, COUNT(sg.song_id) AS song_count
FROM Genre g
JOIN SongGenre sg ON g.genre_id = sg.genre_id
GROUP BY g.genre_id, g.name
ORDER BY song_count DESC
LIMIT 5;

-- B3. Most popular songs (songs appearing in the most playlists)
SELECT s.song_id, s.title, ar.name AS artist, COUNT(ps.playlist_id) AS times_added
FROM Song s
JOIN Album al ON s.album_id = al.album_id
JOIN Artist ar ON al.artist_id = ar.artist_id
JOIN PlaylistSong ps ON s.song_id = ps.song_id
GROUP BY s.song_id, s.title, ar.name
ORDER BY times_added DESC, s.title
LIMIT 10;

-- B4. Users who own the most playlists
SELECT u.user_id, u.name, COUNT(p.playlist_id) AS playlists_owned
FROM User u
JOIN Playlist p ON u.user_id = p.user_id
GROUP BY u.user_id, u.name
ORDER BY playlists_owned DESC
LIMIT 10;

-- B5. Average playlist length (in songs) per user
SELECT u.user_id, u.name, ROUND(AVG(song_count), 2) AS avg_playlist_length
FROM User u
JOIN Playlist p ON u.user_id = p.user_id
JOIN (
    SELECT playlist_id, COUNT(song_id) AS song_count
    FROM PlaylistSong
    GROUP BY playlist_id
) pc ON p.playlist_id = pc.playlist_id
GROUP BY u.user_id, u.name
ORDER BY avg_playlist_length DESC;

-- B6. Songs that belong to 2 or more genres (cross-genre tracks)
SELECT s.song_id, s.title, COUNT(sg.genre_id) AS genre_count
FROM Song s
JOIN SongGenre sg ON s.song_id = sg.song_id
GROUP BY s.song_id, s.title
HAVING COUNT(sg.genre_id) >= 2
ORDER BY genre_count DESC, s.title;

-- B7. Devices ranked by number of distinct users using them
SELECT d.device_id, d.name, d.type, COUNT(DISTINCT ud.user_id) AS user_count
FROM Device d
JOIN UserDevice ud ON d.device_id = ud.device_id
GROUP BY d.device_id, d.name, d.type
ORDER BY user_count DESC;

-- B8. Playlists that span 3 or more distinct genres (diverse playlists)
SELECT p.playlist_id, p.name, COUNT(DISTINCT sg.genre_id) AS distinct_genres
FROM Playlist p
JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
JOIN SongGenre sg ON ps.song_id = sg.song_id
GROUP BY p.playlist_id, p.name
HAVING COUNT(DISTINCT sg.genre_id) >= 3
ORDER BY distinct_genres DESC;

-- B9. Artists whose songs appear in the most playlists
SELECT ar.artist_id, ar.name, COUNT(DISTINCT ps.playlist_id) AS playlists_featuring_artist
FROM Artist ar
JOIN Album al ON ar.artist_id = al.artist_id
JOIN Song s ON al.album_id = s.album_id
JOIN PlaylistSong ps ON s.song_id = ps.song_id
GROUP BY ar.artist_id, ar.name
ORDER BY playlists_featuring_artist DESC
LIMIT 10;

-- B10. Users and the genres they listen to most (via their playlists)
SELECT u.name AS user_name, g.name AS top_genre, COUNT(*) AS song_count
FROM User u
JOIN Playlist p ON u.user_id = p.user_id
JOIN PlaylistSong ps ON p.playlist_id = ps.playlist_id
JOIN SongGenre sg ON ps.song_id = sg.song_id
JOIN Genre g ON sg.genre_id = g.genre_id
GROUP BY u.user_id, u.name, g.genre_id, g.name
ORDER BY u.name, song_count DESC;
