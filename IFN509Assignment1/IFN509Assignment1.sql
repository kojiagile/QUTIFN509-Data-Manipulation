-- Create my database 
create database IF NOT EXISTS moviesdb_9239855;

-- To create tables in the database above
use moviesdb_9239855;

--
-- Create three tables
--

-- drop tables
DROP TABLE IF EXISTS moviesdb_9239855.Ratings_9239855;
DROP TABLE IF EXISTS moviesdb_9239855.movies_9239855;
DROP TABLE IF EXISTS moviesdb_9239855.Reviewers_9239855;

-- 1. Movies table
Create table Movies_9239855 (
	movieID INT(3),
	title varchar(100) NOT NULL,
	year INT(4) NOT NULL,
	primary key (movieID)
);

-- 2. Reviewers table
Create table Reviewers_9239855 (
	reviewerID INT(3),
	name varchar(50) NOT NULL,
	yearJoined INT(4) NOT NULL,
	trustRating INT(1) NOT NULL,
	primary key (reviewerID)
);

-- 3. Ratings table
Create table Ratings_9239855 (
	reviewerID INT(3),
	movieID INT(3) ,
	rating INT(1) NOT NULL,
	comment varchar(200) default null,
	primary key (reviewerID, movieID),
	foreign key (reviewerID) references Reviewers_9239855(reviewerID),
	foreign key (movieID) references Movies_9239855(movieID)
);


--
-- Provided data importing
--

-- 1. Import movie data
LOAD DATA INFILE './movies_movies.csv' INTO table moviesdb_9239855.Movies_9239855
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 2. Import reviewer data
LOAD DATA INFILE './movies_reviewers.csv' INTO table moviesdb_9239855.Reviewers_9239855
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 3. Import ratings data
LOAD DATA INFILE './movies_ratings.csv' INTO table moviesdb_9239855.Ratings_9239855
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


--
-- Question 2: Simple SQL queries (5 marks total, 1 each)  
--

-- 2.a Write a query to list the names of the reviewers.
SELECT name FROM reviewers_9239855;

-- 2.b Write a query to list the movies released after a given year: 1980 
select movieid, title, year from movies_9239855 where year > 1980;

-- 2.c   Write a query to list the movies in alphabetical order of their title  
select movieid, title, year from movies_9239855 order by title asc;

-- 2.d  Write a query to give the average rating of reviewer with a given ID: 541 
-- select avg(rating) from ratings_9239855 group by reviewerID having reviewerID = 541;
select avg(rating) from ratings_9239855 where reviewerID = 541;

-- 2.e   Write a query to  list the average ratings of each reviewer 
select avg(rating) from ratings_9239855 group by reviewerID;


--
-- Question 3 : Complex SQL queries  (5 marks  total, 1 each)  
--

-- 3.a Write a query to know the average rating of a movie given its title: Dumbo 
select avg(rating)
from movies_9239855 mv 
join ratings_9239855 rt on mv.movieid = rt.movieID
where title = 'Dumbo';


-- 3.b Write a query  to list the average  rating of all the movies for each year before  a given year: 1980 
-- (and write NIL if there are no  ratings for that movie)  
select  avg(rating) 
from movies_9239855 mv 
left outer join ratings_9239855 rt on mv.movieid = rt.movieID
group by year
having year < 1980;
 

-- 3.c Write a query to list the movies that have at least 1 numerical rating in common with a given  movie: Dumbo 
select distinct mv2.movieID, title 
from movies_9239855 mv2
join ratings_9239855 rt2 on mv2.movieID = rt2.movieID
where rating in (
	select distinct rating from movies_9239855 as mv
	join ratings_9239855 rt on mv.movieID = rt.movieID
	where title = 'Dumbo'
    );


-- 3.d Write a query to give the average year of movies that received at least once a given rating:  5 
select avg(year) 
from movies_9239855
where movies_9239855.movieid in (
	select distinct mv.movieID from movies_9239855 mv
	join ratings_9239855 rt on mv.movieID = rt.movieID
	where rating = 5
    );


-- 3.e Write a query to give the  name of the favorite movie of the reviewer that gives th e highest average rating.
select title
from movies_9239855 mv
join ratings_9239855 rt on mv.movieID = rt.movieID
join (
	select reviewerID as rid, max(rating) as highest
    from ratings_9239855
	group by reviewerID
	having avg(rating) >= all(
		select avg(rating)
		from ratings_9239855
		group by reviewerID
		)
	) as temp on rt.reviewerID = temp.rid
where rating >= highest;


--
-- Question 4 : SQL Functions (3 marks total, 1 each) 
--
 
-- 4.a Write a query to count the number of movies in the database. 
select count(movieid) from movies_9239855;

-- 4.b Write a query to list the names of the reviewers who have been active for longer than a given duration: 10 years
select name
from reviewers_9239855 
where year(current_date()) - yearJoined > 10;

-- 4.c Write a query to get the difference between the normal aver age and the weighted average of 
-- a given movie: Ratatouille. The weighted average is obtained by considering the trustRating 
-- of a reviewer as the weight of their review score for the movie. You shou ld also include the 
-- average and weighted average in the output. 
select 
	avg(rating) as normal, 
	(sum(rating * trustrating) / sum(trustrating)) as weighted,
	avg(rating) - ( sum((rating * trustrating)) / sum(trustrating)) as diff
from ratings_9239855 rt
join reviewers_9239855 rvw on rt.reviewerID = rvw.reviewerID 
where rt.movieid in (
	select movieid from movies_9239855 
	where title = 'Ratatouille'
	) 
group by rt.movieID;


--
-- Question 5: Regular Expressions (2  marks  total,  1  each)   
-- 

-- 5.a Write a query with a regular expression to list the names of movies that start with a certain word: Pirates
select title from movies_9239855 where title regexp '^Pirates';

-- 5.b Write a qu ery with a regular expression to list the comments of ratings of at least 4 that don't 
-- feature any of the following words : great, like, nice, fantastic. 
select comment from ratings_9239855 
where comment not regexp 'great+|like+|nice+|fantastic+'
and rating >= 4;

