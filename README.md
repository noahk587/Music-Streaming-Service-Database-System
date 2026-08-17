# Music-Streaming-Service-Database-System
The application domain we had selected is a music streaming service. Our application
reflects to the current consumer market while subscriptions are more common compared to
owning forms of entertainment. The application of a music streaming for our project is a perfect
example as consumers are opting to subscribe to services such as Apple Music instead of
purchasing individual albums or songs. Our application is useful as it performs the essential
functions that is needed to run a successful streaming service that is done behind the scenes
along with queries for the business. The key components of our database includes but not limited
to the entities of user, artist, album, songs, and playlists. These are the five most important
entities for our database as it stores the critical information about the user and their interaction
with the service via their playlist. Furthermore, the artist, songs, and playlists entities stores the
content for the streaming service.

## Database Details
The database is setup using the `Database_Setup.SQL` file. We created this dataset using real songs and artists. Each member of the group has written queries in a `.SQL` file and implemented the queries with SQLite3 in a Jupyter Notebook.

Our data contains subscriber information for the streaming service including artist
information, music albums and songs and playlist. Our database is normalized in BCNF, which is
a stricter form of 3Nf.

### Entities
 - User: Stores information about users
 - SubscriptionPlan: Stores subscription plan details
 - UserSubscription: Junction table linking users and subscription plans.
 - Region: Stores geographic regions
 - UserRegion: Junction table linking users and regions
 - Device: Stores device types for users
 - UserDevice: Junction table linking users and devices
 - Playlist: Stores playlists created in the system
 - UserPlaylist: Junction table linking users and playlists (for ownership or sharing)
 - Song: Stores song metadata
 - Album: Stores album metadata
 - Artist: Stores artist metadata
 - Genre: Stores music genres
 - SongGenre: Junction table linking songs and genres
 - PlaylistSong: Junction table linking playlists and songs


## Other Files
Queries by William: https://github.com/williamnsambu/academic-work/tree/main/CSCE5350DatabaseSystemsProject
