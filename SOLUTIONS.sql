-- CREATING DATABASE
CREATE DATABASE SQL_MENTOR;
USE SQL_MENTOR;

-- CREATING TABLE
CREATE TABLE submissions (
    id INT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP,
    username VARCHAR(100) 
);

-- CHECK IF ALL DATA IS EXPORTED
SELECT COUNT(*) FROM SUBMISSIONS;

-- QUERIES TO SOLVE.
-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.

-- SOLUTIONS.
-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
SELECT 
    username,
    COUNT(*) AS total_submissions,
    SUM(points) AS points_earned
FROM
    submissions
GROUP BY username
ORDER BY points_earned DESC;


-- Q.2 Calculate the daily average points for each user.
SELECT 
    DATE_FORMAT(submitted_at, '%d-%m') AS DAY,
    USERNAME,
    AVG(points) AS daily_avg_points
FROM
    SUBMISSIONS
GROUP BY DAY , USERNAME
ORDER BY DAY;



-- Q.3 Find the top 3 users with the most positive submissions for each day.
SELECT daily, username, correct_submissions
FROM (
        SELECT 
            DATE_FORMAT(submitted_at, '%d-%m') AS daily,
            username,
            SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions,
            DENSE_RANK() OVER(
                PARTITION BY DATE_FORMAT(submitted_at, '%d-%m')
                ORDER BY SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) DESC
            ) AS rank_no
        FROM submissions
        GROUP BY daily, username
     ) AS ranked_users
WHERE rank_no <= 3
AND correct_submissions > 0
ORDER BY daily, correct_submissions DESC;


-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- WE ALSO FOUND :-
	-- INCORRECT_SUBMSSION_POINTS,
    -- CORRECT_SUBMISSIONS,
    -- CORRECT_SUBMISSION_POINTS,
    -- TOTAL_POINTS.
SELECT * FROM SUBMISSIONS;
 
SELECT 
    USERNAME,
    SUM(CASE
        WHEN POINTS < 0 THEN 1
        ELSE 0
    END) AS INCORRECT_SUBMISSIONS,
    SUM(CASE
        WHEN POINTS < 0 THEN POINTS
        ELSE 0
    END) AS INCORRECT_SUBMSSION_POINTS,
    SUM(CASE
        WHEN POINTS > 0 THEN 1
        ELSE 0
    END) AS CORRECT_SUBMISSIONS,
    SUM(CASE
        WHEN POINTS > 0 THEN POINTS
        ELSE 0
    END) AS CORRECT_SUBMISSION_POINTS,
    SUM(POINTS) AS TOTAL_POINTS
FROM
    SUBMISSIONS
GROUP BY 1
ORDER BY INCORRECT_SUBMISSIONS DESC
LIMIT 5;


-- Q.5 Find the top 10 performers for each week.
SELECT *
FROM (
    SELECT 
        WEEK(submitted_at) AS week_no,
        username,
        SUM(points) AS total_points_earned,

        DENSE_RANK() OVER(
            PARTITION BY WEEK(submitted_at)
            ORDER BY SUM(points) DESC
        ) AS rank_no

    FROM submissions
    GROUP BY WEEK(submitted_at), username
) AS weekly_ranked_users
WHERE rank_no <= 10
ORDER BY week_no, total_points_earned DESC;


-- Q.6 Find TOP 5 days that had the highest overall performance.
SELECT 
    DATE(submitted_at) AS submission_date,
    SUM(points) AS total_points_for_day
FROM submissions
GROUP BY DATE(submitted_at)
ORDER BY total_points_for_day DESC
LIMIT 5;

-- Q.7 Find users with the most incorrect submissions, only if total submissions > 5
SELECT
    username,
    COUNT(*) AS TOTAL_COUNT,
    SUM(points) AS TOTAL_POINTS,
    SUM(points < 0) AS INCORRECT_COUNT,
    CASE 
        WHEN SUM(points < 0) > SUM(points > 0) THEN 'Possible Spammer'
        ELSE 'Normal User'
    END AS user_flag
FROM submissions
GROUP BY username
HAVING TOTAL_COUNT > 10
ORDER BY INCORRECT_COUNT DESC;

