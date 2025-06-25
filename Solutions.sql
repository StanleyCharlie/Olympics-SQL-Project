1. How many olympics games have been held?

    select count(distinct games) as total_olympic_games
    from olympics_history;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

2. List down all Olympics games held so far.

select games, city
from olympics_history
group by games, city
order by games;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

3. Mention the total no of nations who participated in each olympics game?

select games, count(distinct noc) as total_countries
from olympics_history
group by games
order by games;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

4. Which year saw the highest and lowest no of countries participating in olympics?

with all_countries as
			(select games, nr.region
			from olympics_history oh
			join olympic_history_noc_regions nr on oh.noc=nr.noc
			group by games, nr.region),
		tot_countries as
			(select games, count(1) as total_countries
			from all_countries
			group by games)
		select distinct
		concat(first_value(games) over(order by total_countries)
		, ' - '
		, first_value(total_countries) over(order by total_countries)) as Lowest_countries,
		concat(first_value(games) over(order by total_countries desc)
		, ' - '
		, first_value(total_countries) over(order by total_countries desc)) as Highest_countries
		from tot_countries
		order by 1;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

5. Which nation has participated in all of the olympic games?

select count(distinct games) as total_olympic_games
from olympics_history

with t1 as
		(select nr.region, games
		from olympics_history oh
		join olympic_history_noc_regions nr on oh.noc=nr.noc
		group by nr.region, games
		order by games),
	  t2 as
		 (select region, count(1) as no_games_played
	 	  from t1
		  group by region
		  order by no_games_played desc)
select region, no_games_played
from t2
where no_games_played = '51'
order by region;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

6. Identify the sport which was played in all summer olympics.

with t1 as
		(select count(distinct games) total_summer_games
		from olympics_history
		where season = 'Summer')
		
with t2 as
		(select sport, count(distinct games) total_games
		from olympics_history
		group by sport
		order by total_games desc)
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

7. Which Sports were just played only once in the olympics?

select * 
from olympics_history

with t1 as
		(select distinct sport, games
		from olympics_history
		order by games)

select sport, count(1) as no_of_games
from t1
group by sport
order by no_of_games

with t1 as
		(select distinct sport, games
		from olympics_history
		order by games),
     t2 as
		(select sport, count(1) as no_of_games
		from t1
		group by sport
		order by no_of_games)
Select t2.*, t1.games
from t2
join t1 on t1.sport = t2.sport
where t2.no_of_games = 1
order by t2.sport

ALTERNATIVELY

with t1 as
          	(select distinct games, sport
          	from olympics_history),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

8. Fetch the total no of sports played in each of the olympic games.

with t1 as
		(select sport, games 
		from olympics_history
		group by sport, games
		order by games)

	 select games, count(1) 
	 from t1
	 group by games
	 order by count desc

with t1 as
		(select sport, games 
		from olympics_history
		group by sport, games
		order by games)
select games, count(1) 
	 from t1
	 group by games
	 order by count desc
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

9. Fetch details of the oldest athletes to win a gold medal.

with t1 as
		(select name, sex, age, team, city, sport, event, medal 
		from olympics_history
		where medal = 'Gold' and age <> 'NA'
		order by age desc)

		(select max(t1.age) oldest 
		from t1)

with t1 as
		(select name, sex, age, team, city, sport, event, medal 
		from olympics_history
		where medal = 'Gold' and age <> 'NA'
		order by age desc),
	 t2 as
		(select max(t1.age) oldest 
		from t1)
select * 
from t1
join t2 on t2.oldest = t1.age
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

10. Find the Ratio of male and female athletes participated in all olympic games.

(select sex, count(1) as cnt
        	from olympics_history
        	group by sex)

(select *, row_number() over(order by cnt) as rn
        	 from t1),

	ii) [label the row s as max_cnt and min_cnt]
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)

with t1 as
        	(select sex, count(1) as cnt
        	from olympics_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

11. Fetch the top 5 athletes who have won the most gold medals.

select *
from olympics_history

Step 1 [Retrieval of data of athletes that have won gold medals]

select *
from olympics_history
where medal = 'Gold'

Step 2 [Determination of number of gold medals won per individual display results in descending order]

select name, count(1) as total_medal
from olympics_history
where medal = 'Gold'
group by name
order by count(1) desc

Step 3 [Single out the top 5 using dense_rank function]

with t1 as
		(select name, count(1) as total_medal
		from olympics_history
		where medal = 'Gold'
		group by name
		order by count(1) desc),
	 t2 as
	    (select *, dense_rank() over(order by total_medal desc) as rnk
	     from t1)
select *
from t2
where rnk <= 5;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

Step 1 [Retrival of medalists data]

select *
from olympics_history
where medal <> 'NA'

Step 2 [Number of medals won per athlete]

select name, team, count(1) as no_of_medals
from olympics_history
where medal <> 'NA'
group by name, team
order by no_of_medals desc

Step 3 [establish the top 5 ranked medalists using dense_rank function and a <= 5 condition]

with t1 as
	(select name, team, count(1) as no_of_medals
	from olympics_history
	where medal <> 'NA'
	group by name, team
	order by no_of_medals desc),
	 t2 as
	(select *, dense_rank() over(order by no_of_medals desc) as pos
	from t1)
select *
from t2
where pos <= 5
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select team, noc, medal
from olympics_history

Step 1 [joining noc to history, and filtering for medals]

with t1 as
	(select team, noc, medal
	from olympics_history
	where medal <> 'NA')
	(select t1.medal, nr.region 
	from t1
	join olympic_history_noc_regions nr on nr.noc = t1.noc)

Step 2 [Determine the number of the medals won per country]

with t1 as
	(select team, noc, medal
	from olympics_history
	where medal <> 'NA'),
	 t2 as
	(select t1.medal, nr.region 
	from t1
	join olympic_history_noc_regions nr on nr.noc = t1.noc)
select region, count(1) as no_of_medals
from t2
group by region
order by no_of_medals desc

Step 3 [Filter out the top 5 ranked countries as per the data]

with t1 as
	(select team, noc, medal
	from olympics_history
	where medal <> 'NA'),
	 t2 as
	(select t1.medal, nr.region 
	from t1
	join olympic_history_noc_regions nr on nr.noc = t1.noc),
	 t3 as
	(select region, count(1) as no_of_medals
	from t2
	group by region
	order by no_of_medals desc),
	 t4 as
	(select *, dense_rank () over(order by no_of_medals desc) rnk
	from t3)
select *
from t4
where rnk <= 5
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

14. List down total gold, silver and broze medals won by each country.

select * 
from olympics_history

select * 
from olympic_history_noc_regions

Step 1 [linking the noc table to the history table filtering out NA records]

select nr.region country, oh.medal
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'

Step 2 [Establishing the count per medal, per country]

with t1 as
	(select nr.region country, oh.medal, count(1) total_medals
	from olympics_history oh
	join olympic_history_noc_regions nr on nr.noc = oh.noc
	where medal <> 'NA'
	group by country, oh.medal
	order by country, oh.medal)

Step 3 [Introduction of crosstab function]
create extension tablefunc; i.e transpose data results

select *
from crosstab('select nr.region as country, oh.medal, count(1) total_medals
			from olympics_history oh
			join olympic_history_noc_regions nr on nr.noc = oh.noc
			where medal <> ''NA''
			group by country, oh.medal
			order by country, oh.medal')
		as result(country varchar, Bronze bigint, Gold bigint, Silver bigint)

Step 4: [Correction of cosstab data]

select country
,coalesce(Bronze, 0) as Bronze
,coalesce(Gold, 0) as Gold
,coalesce(Silver, 0) as Silver
from crosstab('select nr.region as country, oh.medal, count(1) total_medals
			  from olympics_history oh
			  join olympic_history_noc_regions nr on nr.noc = oh.noc
			  where medal <> ''NA''
			  group by country, oh.medal
			  order by country, oh.medal',
			  'values(''Bronze''), (''Gold''), (''Silver'')')
	as result(country varchar, Bronze bigint, Gold bigint, Silver bigint)
order by Bronze desc, Gold desc, Silver desc;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

select *
from olympics_history

select * 
from olympic_history_noc_regions

Step 1 [join tables noc an oh hence retrieving number of medals won per country per game]

select oh.games, nr.region country, oh.medal, count(*) no_of_medals
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by nr.region, oh.medal, oh.games
order by games, country, no_of_medals, medal

select nr.region country, oh.medal, count(*) no_of_medals
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by nr.region, oh.medal
order by country, no_of_medals, medal

Step 2 [Introduce crosstab function to transpose data]
NB: crosstab only uses 3 columns

select *
from crosstab('select concat(games, '' - '', nr.region) as games, oh.medal, count(*) total_medals
			from olympics_history oh
			join olympic_history_noc_regions nr on nr.noc = oh.noc
			where medal <> ''NA''
			group by nr.region, oh.medal, games
			order by games, total_medals, medal')
		as result(games text, gold bigint, silver bigint, bronze bigint)

Step 3 [Correct crosstab results & add games column to table]

select substring(games,1,position(' - ' in games) - 1) as games
     , substring(games,position(' - ' in games) + 3) as country
 	 , coalesce(Gold, 0) as Gold
	 , coalesce(Silver, 0) as Silver
	 , coalesce(Bronze, 0) as Bronze
 	 from crosstab('select concat(games, '' - '', nr.region) as games, oh.medal, count(*) total_medals
					from olympics_history oh
					join olympic_history_noc_regions nr on nr.noc = oh.noc
					where medal <> ''NA''
					group by games,nr.region,medal
					order by games,medal',
					'values(''Gold''), (''Silver''), (''Bronze'')')
	 as FINAL_RESULT(games text, gold bigint, silver bigint, bronze bigint)
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

Step 1 [Determine number of medals won per country per game]

select games, nr.region country, medal, count(1) number_of_medals
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by games,country,medal
order by games,country,number_of_medals desc,medal

Step 2 [Transpose the results of step 1 and introduction of dense_rank function]

select substring(games,1,position(' - ' in games) - 1) as games
     , substring(games,position(' - ' in games) + 3) as country
	 , coalesce(Gold, 0) as Gold
	 , coalesce(Silver, 0) as Silver
	 , coalesce(Bronze, 0) as Bronze
	from crosstab('select concat(games, '' - '', nr.region) games, medal, count(1) number_of_medals
				from olympics_history oh
				join olympic_history_noc_regions nr on nr.noc = oh.noc
				where medal <> ''NA''
				group by games,nr.region,medal
				order by games,number_of_medals,medal',
				'values(''Gold''), (''Silver''), (''Bronze'')')
	as FINAL_RESULT(games text, gold bigint, silver bigint, bronze bigint)
order by games desc, Gold desc, Silver desc, Bronze desc;

Step 3 [Single out top national records per medal]

with temp as
			(select substring(games,1,position(' - ' in games) - 1) as games
			     , substring(games,position(' - ' in games) + 3) as country
				 , coalesce(Gold, 0) as Gold
				 , coalesce(Silver, 0) as Silver
				 , coalesce(Bronze, 0) as Bronze
				from crosstab('select concat(games, '' - '', nr.region) games, medal, count(1) number_of_medals
							from olympics_history oh
							join olympic_history_noc_regions nr on nr.noc = oh.noc
							where medal <> ''NA''
							group by games,nr.region,medal
							order by games,number_of_medals,medal',
							'values(''Gold''), (''Silver''), (''Bronze'')')
				as FINAL_RESULT(games text, gold bigint, silver bigint, bronze bigint)
			order by games desc, Gold desc, Silver desc, Bronze desc)
select distinct games
, concat(first_value (country) over(partition by games order by gold desc)
		 , ' - '
		 ,first_value (gold) over(partition by games order by gold desc)) max_gold
, concat(first_value (country) over(partition by games order by silver desc)
		 , ' - '
		 ,first_value (silver) over(partition by games order by silver desc)) max_silver
, concat(first_value (country) over(partition by games order by bronze desc)
		 , ' - '
		 ,first_value (bronze) over(partition by games order by bronze desc)) max_bronze
from temp
order by games;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games

Step 1 [Determination of number of medals won per country per game]

select games, nr.region country, medal, count(1) total_medals
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc=oh.noc
where medal <> 'NA'
group by games, country, medal
order by games, country, medal

Step 2 [Transposing results of step 1]

select substring(country, 1,position(' - ' in country) -1) games
	  ,substring(country, position(' - ' in country) +3) country
	  ,coalesce(Gold, 0) as Gold
	  ,coalesce(Silver, 0) as Silver
	  ,coalesce(Bronze, 0) as Bronze
	from crosstab('select concat(games, '' - '', nr.region) games_country, medal, count(1) total_medals
				from olympics_history oh
				join olympic_history_noc_regions nr on nr.noc=oh.noc
				where medal <> ''NA''
				group by games,nr.region,medal
				order by games,nr.region,medal',
				'values(''Gold''), (''Silver''), (''Bronze'')')
	as result(country text, gold bigint, silver bigint, bronze bigint)
order by games, gold desc, silver desc, bronze desc

Step 3 [Establishment of top National records per medal]

with temp as
		(select substring(country, 1,position(' - ' in country) -1) games
			   ,substring(country, position(' - ' in country) +3) country
			   , coalesce(Gold, 0) as Gold
			   , coalesce(Silver, 0) as Silver
			   , coalesce(Bronze, 0) as Bronze
			from crosstab('select concat(games, '' - '', nr.region) games_country, medal, count(1) total_medals
						from olympics_history oh
						join olympic_history_noc_regions nr on nr.noc=oh.noc
						where medal <> ''NA''
						group by games,nr.region,medal
						order by games,nr.region,medal',
						'values(''Gold''), (''Silver''), (''Bronze'')')
			as result(country text, gold bigint, silver bigint, bronze bigint)
		order by games, gold desc, silver desc, bronze desc)

Step 4 [Create table for total medals per country per game & join to results in step 3]

with temp as		
		(select substring(country, 1,position(' - ' in country) -1) games
			   ,substring(country, position(' - ' in country) +3) country
			   , coalesce(Gold, 0) as Gold
			   , coalesce(Silver, 0) as Silver
			   , coalesce(Bronze, 0) as Bronze
			from crosstab('select concat(games, '' - '', nr.region) games_country, medal, count(1) total_medals
						from olympics_history oh
						join olympic_history_noc_regions nr on nr.noc=oh.noc
						where medal <> ''NA''
						group by games,nr.region,medal
						order by games,nr.region,medal',
						'values(''Gold''), (''Silver''), (''Bronze'')')
			as result(country text, gold bigint, silver bigint, bronze bigint)
		order by games, gold desc, silver desc, bronze desc),
		tot_medals as
				(select games, nr.region country, count(1) total_medals
				from olympics_history oh
				join olympic_history_noc_regions nr on nr.noc=oh.noc
				where medal <> 'NA'
				group by games, country
				order by 1, 2)
	select distinct t.games
			,concat(first_value(t.country) over(partition by t.games order by t.gold desc)
				, ' - '
				, first_value(t.gold) over(partition by t.games order by t.gold desc)) max_gold
			,concat(first_value(t.country) over(partition by t.games order by t.silver desc)
				, ' - '
				, first_value(t.silver) over(partition by t.games order by t.silver desc)) max_silver
			,concat(first_value(t.country) over(partition by t.games order by t.bronze desc)
				, ' - '
				, first_value(t.bronze) over(partition by t.games order by t.bronze desc)) max_bronze
			,concat(first_value(tm.country) over(partition by tm.games order by total_medals desc nulls last)
				, ' - '
				, first_value(total_medals) over(partition by tm.games order by total_medals desc nulls last)) max_medals
	from temp t
	join tot_medals tm on tm.games=t.games and tm.country=t.country
	order by games;

ALTERNATIVELY

WITH total_medals AS 
				(SELECT Games,NOC,
				COUNT(Medal) AS total_medals
				FROM olympics_history
				WHERE Medal IN ('Gold', 'Silver', 'Bronze')
				GROUP BY Games, NOC),
max_total_medals AS 
				(SELECT Games,MAX(total_medals) AS max_medal_count
				FROM total_medals
				GROUP BY Games),
medal_counts AS 
			(SELECT Games,NOC,
			 SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold_medals,
			 SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
			 SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
			 FROM olympics_history
			WHERE Medal IN ('Gold', 'Silver', 'Bronze')
			GROUP BY Games, NOC),
max_medals_by_type AS 
					(SELECT Games,
					MAX(gold_medals) AS max_gold,
					MAX(silver_medals) AS max_silver,
					MAX(bronze_medals) AS max_bronze
					FROM medal_counts
					GROUP BY Games),
final_results AS 
				(SELECT
				mc.Games,
				MAX(CASE WHEN mc.gold_medals = mt.max_gold THEN CONCAT(mc.NOC, ' (', mc.gold_medals, ')') END) AS max_gold,
				MAX(CASE WHEN mc.silver_medals = mt.max_silver THEN CONCAT(mc.NOC, ' (', mc.silver_medals, ')') END) AS max_silver,
				MAX(CASE WHEN mc.bronze_medals = mt.max_bronze THEN CONCAT(mc.NOC, ' (', mc.bronze_medals, ')') END) AS max_bronze,
				MAX(CASE WHEN tm.total_medals = mmt.max_medal_count THEN CONCAT(tm.NOC, ' (', tm.total_medals, ')') END) AS max_medals
				FROM medal_counts mc
				JOIN max_medals_by_type mt ON mc.Games = mt.Games
				JOIN total_medals tm ON mc.Games = tm.Games AND mc.NOC = tm.NOC
				JOIN max_total_medals mmt ON tm.Games = mmt.Games
				GROUP BY mc.Games)
SELECT Games,max_gold,max_silver,max_bronze,max_medals
FROM final_results
ORDER BY Games;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

18. Which countries have never won gold medal but have won silver/bronze medals?

Step 1 [Establish medals won by countries]

select nr.region country,oh.medal,count(1) total_medals
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc=oh.noc
where medal <> 'NA' 
group by country,medal
order by country,medal

step 2 [Introduction of crosstab to transpose data hence determine countries with 0 gold medals]

with tab as
		(select country 
		, coalesce(Gold, 0) as Gold
		, coalesce(Silver, 0) as Silver
		, coalesce(Bronze, 0) as Bronze
		from crosstab('select nr.region country,oh.medal,count(1) total_medals
					from olympics_history oh
					join olympic_history_noc_regions nr on nr.noc=oh.noc
					where medal <> ''NA'' 
					group by country,medal
					order by country,medal',
					'values (''Gold''), (''Silver''), (''Bronze'')')
				as result(country varchar, Gold bigint, Silver bigint, Bronze bigint)
			order by gold,silver,bronze)
	select *
	from tab
	where gold=0 and (silver>0 or bronze>0)
	order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

19. In which Sport/event, India has won highest medals.

Step 1 [Establish the number of medals won by India in each sport it has participated in]

select nr.region country,sport,count(1) total_medals 
from olympics_history oh
join olympic_history_noc_regions nr on oh.noc=nr.noc
where medal <> 'NA' and nr.region = 'India'
group by country,sport
order by count(1) desc

Step 2 [Single out the highest medals won from step 1]

with m as
			(select nr.region country,sport,count(1) total_medals 
			from olympics_history oh
			join olympic_history_noc_regions nr on oh.noc=nr.noc
			where medal <> 'NA' and nr.region = 'India'
			group by country,sport
			order by count(1) desc),
	 m2 as
			(select max(m.total_medals) most_won
			from m)
select sport,total_medals
from m
join m2 on m2.most_won=m.total_medals;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''

20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

select games,nr.region country,sport,medal,count(1) medals_won
from olympics_history oh
join olympic_history_noc_regions nr on nr.noc=oh.noc
where nr.region='India' and oh.sport='Hockey' and medal <> 'NA'
group by games,country,sport,medal
order by medals_won desc;
'''''''''''''''''''''''''''''''''''''''######################################################'''''''''''