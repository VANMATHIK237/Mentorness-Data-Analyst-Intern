#Q1) Extract P_ID,Dev_ID,PName and Difficulty_level of all players at level 0
SELECT P_ID, DEV_ID,P_Name,Difficulty FROM game.det
WHERE level="0"

#Q2) Find Level1_code wise Avg_Kill_Count where lives_earned is 2 and atleast 3 stages are crossed
SELECT L1_Code, Avg(Kill_Count) FROM game.det
WHERE Lives_Earned = "2" AND Stages_crossed > 3
GROUP BY L1_Code

#Q3) Find the total number of stages crossed at each diffuculty level where for Level2 with players use zm_series devices. Arrange the result in decsreasing order of total number of stages crossed.
SELECT Difficulty, SUM(Stages_crossed) FROM game.det
WHERE level="2" AND Dev_ID LIKE "zm%"
GROUP BY Difficulty
ORDER BY SUM(Stages_crossed) DESC

# Q4) Extract P_ID and the total number of unique dates for those players  who have played games on multiple days.
SELECT P_ID, COUNT(DISTINCT DATE(Date)) FROM game.detv
GROUP BY P_ID
HAVING COUNT(DISTINCT DATE(Date)) > 1;


#Q5) Find P_ID and level wise sum of kill_counts where kill_count is greater than avg kill count for the Medium difficulty.
SELECT P_ID,level, SUM(Kill_Count) AS TOTAL_KILL_COUNT FROM game.det
WHERE Kill_Count > (SELECT AVG(Kill_Count) FROM game.det WHERE Difficulty = "Medium")
GROUP BY P_ID,level

#Q6)Find Level and its corresponding Level code wise sum of lives earned  excluding level 0. Arrange in asecending order of level.
SELECT level,L1_Code,L2_Code, SUM(Lives_Earned) FROM game.det
WHERE level != "0"
GROUP BY level,L1_Code,L2_Code
ORDER BY level ASC

#Q7) Find Top 3 score based on each dev_id and Rank them in increasing order using Row_Number. Display difficulty as well. 
WITH ranked_results AS (
    SELECT Score, Dev_ID, Difficulty, ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Score DESC) AS ranks 
    FROM game.det
)
SELECT * FROM ranked_results 
WHERE ranks <= 3;


#Q8)Find first_login datetime for each device id
SELECT Dev_ID, MIN(TimeStamp)  FROM game.det
GROUP BY Dev_ID

##Q9)Find Top 5 score based on each difficulty level and Rank them in increasing order using Rank. Display dev_id as well.
WITH temp AS(
SELECT Dev_ID,Difficulty, Score, RANK() OVER (PARTITION BY Dev_ID, Difficulty  ORDER BY score ASC) AS rk FROM game.det)
SELECT Dev_ID, Difficulty, Score FROM temp
WHERE rk <= 5

#Q10) Find the device ID that is first logged in(based on start_datetime)  for each player(p_id). Output should contain player id, device id and first login datetime.
SELECT DISTINCT(P_ID),Dev_ID, MIN(TimeStamp)  FROM game.det
GROUP BY Dev_ID,P_ID

#Q11) For each player and date, how many kill_count played so far by the player. That is, the total number of games played by the player until that date.
SELECT P_ID, TimeStamp,SUM(Kill_Count)OVER ( PARTITION BY P_ID ORDER BY TimeStamp) AS Total_Kills FROM game.det

#Q12) Find the cumulative sum of stages crossed over a start_datetime 
SELECT TimeStamp,Stages_crossed, SUM(Stages_crossed) OVER(ORDER BY TimeStamp) AS CUMILATIVE_STAGES FROM game.det

#Q13) Find the cumulative sum of an stages crossed over a start_datetime for each player id but exclude the most recent start_datetime
SELECT P_ID,TimeStamp,Stages_crossed, SUM(Stages_crossed) OVER(ORDER BY TimeStamp) AS CUMILATIVE_STAGES FROM game.det
WHERE TimeStamp != (SELECT MIN(TimeStamp) FROM game.det)

#Q14) Extract top 3 highest sum of score for each device id and the corresponding player_id
WITH Rankscores AS 
(
    SELECT P_ID, Dev_ID, SUM(Score) AS TOTAL_SCORE, ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY SUM(Score) DESC) AS rnk 
    FROM game.det
    GROUP BY P_ID, Dev_ID
)
SELECT P_ID, Dev_ID, TOTAL_SCORE 
FROM Rankscores 
WHERE rnk <= 3;


#Q15) Find players who scored more than 50% of the avg score scored by sum of scores for each player_id
WITH player_totals AS (
    SELECT P_ID, SUM(Score) AS Total_Score
    FROM game.det
    GROUP BY P_ID
),
player_avg_score AS (
    SELECT P_ID, AVG(Total_Score) AS Avg_Total_Score
    FROM player_totals
    GROUP BY P_ID
)
SELECT det.P_ID, det.P_Name, player_totals.Total_Score, player_avg_score.Avg_Total_Score
FROM game.det
INNER JOIN player_totals ON det.P_ID = player_totals.P_ID
INNER JOIN player_avg_score ON det.P_ID = player_avg_score.P_ID
WHERE det.Score > (player_avg_score.Avg_Total_Score * 0.5);





#Q16) Create a stored procedure to find top n headshots_count based on each dev_id and Rank them in increasing order sing Row_Number. Display difficulty as well.

CREATE PROCEDURE Top_N(IN Num INT)
BEGIN
    SELECT Dev_ID, Headshots_Count, Difficulty 
    FROM (
        SELECT Dev_ID, Headshots_Count, Difficulty,
               ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Headshots_Count) AS row_no
        FROM game.det
    ) AS result
    WHERE row_no <= Num;
END//

DELIMITER ;
CALL Top_N(3)
##Q17) Create a function to return sum of Score for a given player_id.
DELIMITER //

CREATE FUNCTION GetTotalScoreForPlayer(P_ID INT) RETURNS INT
BEGIN
    DECLARE total_score INT;
    
    SELECT SUM(Score) INTO total_score
    FROM game.det
    WHERE P_ID = P_ID;
    
    RETURN total_score;
END//

DELIMITER ;
SELECT GetTotalScoreForPlayer(644);




    
    












