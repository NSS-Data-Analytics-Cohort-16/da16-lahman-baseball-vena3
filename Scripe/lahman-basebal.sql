-- 1. What range of years for baseball games played does the provided database cover? 

select max(yearid), min(yearid) 
from appearances 



-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
---shorter player - peepole 
---name and height- peaple
---how maney game plaerr - appearances
---name of team - team

select *
from people;

select *
from appearances;

select *
from teams;

select concat(namefirst, ' ', namelast) as full_name, p.height,
       a.g_all as total_games, t.name as team_name
from people as p
left join appearances as a
on p.playerid = a.playerid
inner join teams as t
using (teamid)
order by p.height
limit 1



-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
--- NAME OF PLAYERS - PEOPLE
--- total salary - salaries
---

select *
from salaries

select *
from collegeplaying
where schoolid = 'vandy'


select concat(namefirst, ' ', namelast) as full_name, 
       sum(s.salary::numeric)::money as total_salary
from people as p 
inner join salaries as s
on p.playerid = s.playerid
where p.playerid in (select
                     playerid
					 from collegeplaying
					 where schoolid = 'vandy')
group by full_name
order by total_salary DESC;



-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery".
---Determine the number of putouts made by each of these three groups in 2016.

---fielding table
---group players into 3 groups 
---label players on poition as 'outfield'

select *
from fielding

select 
       case when pos in ('of') then  'outfield'
	        when pos in ('ss', '1B', '2B', 'B3') then 'Infield'
			when pos in  ('P', 'C') then 'Battery'
			end as position_group,
			sum (po) as total_po
from fielding as p
where yearid = 2016 
group by position_group



-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
---Do the same for home runs per game. Do you see any trends?

--- yearid
--- strikeouts per game 
--- pitching (Strikeouts) as so
--- teams (Strikeouts by batters) as so
----g game 

select *
from pitching

select *
from teams

select yearid / 10 * 10 as decades,
       round(sum(so)::numeric / sum(g)::numeric,2) as so_per_game,
	   round(sum(hr)::numeric / sum(g)::numeric,2) as hr_per_game
from teams
where yearid >= 1920
group by decades
order by decades 

       

-- 6. Find the player who had the most success stealing bases in 2016,
--where __success__ is measured as the percentage of stolen base attempts which are successful.
--(A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

select yearid, sb, cs
from Batting
where yearid = 2016

with stolen_base as(
                 select  playerid,
			             round (sum(sb)::numeric / sum(sb)::numeric + sum (cs)::numeric) 
                  from  batting 
				  where  yearid = 2016
				  group by playerid
				  having sum(sb + cs) > 19
				  
   
				  
-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
---What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year.
---How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

with most_wins as (
	          select yearid, max(w) as w
	          from teams
	          where yearid >= 1970
	          group by yearid
	          order by yearid),
	
most_win_teams as (
	          select yearid, name, wswin
	          from teams
	          inner join most_wins
	          using(yearid, w))
	 select 
	 (select count(*)
	 from most_win_teams
	 where wswin = 'N') * 100.0 /
	 (select count(*)
	 from most_win_teams);

	
-- 8. Using the attendance figures from the homegames table, 
-- find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games).
-- Only consider parks where there were at least 10 games played.
-- Report the park name, team name, and average attendance. 
-- Repeat for the lowest 5 average attendance.

select *
from homegames

select avg(attendance::numeric)
from homegames

with top_avg as
             select p.park_name, t.name,
			 round(sum(h.attendance::numeric) / sum(h.games::numeric), 0) as avg_attendance
			 from  homegames as h
			 inner join parks as p
			 on h.park = p.park
			 inner join teams as t
			 on h.team = t.teamid  and h.year = t.yearid
			 where year = 2016
			 group by p.park_name, t.name
			 order by avg_attendance DESC
			 limit 5

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

