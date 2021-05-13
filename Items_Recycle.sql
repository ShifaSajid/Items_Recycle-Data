

/* 1.Find the item_name with maximum #transactions and item_name generating maximum revenue . */
select top 1  Item_Name, COUNT(Transaction_ID) as no_of_transaction
from [dbo].[Items Recycle Data (1)]
group by Item_Name
order by COUNT(Transaction_ID) desc

select top 1 Item_Name
       , sum(cast(cost as float)) as max_revenue
from   [dbo].[Items Recycle Data (1)]
group by Item_Name
order by sum(cast(cost as float)) desc

/* 2.Find top 3 item_name based on number of days items were available. */
select top 3 Item_Name 
       ,COUNT(distinct[Date]) as no_of_days
from   [dbo].[Items Recycle Data (1)]
group by  Item_Name
order by COUNT(distinct[Date]) desc


/* 3.For item_id = 466520510, find the #transactions on Monthly, Weekly, Daily and Hourly level 
Hint – Use function dateadd(S, Timestamp, '1970-01-01') to convert Unix Timestamp to Standard Timestamp
Eg, SELECT dateadd(S, 1548077839, '1970-01-01') FROM table will return 2019-01-21 13:37:19.000 . */
with base_cte as (
select Item_ID
       ,[month]
	   , [week]
	   ,[day]
	   ,[hour]
	   , sum ([transaction]) AS [total_transaction]
from
(
select Item_ID,
       datepart(MONTH,[timestamp]) as [month],
       datepart(WEEK,[timestamp]) as [week],
       datepart(DAY,[timestamp]) as [day],
       datepart(HOUR,[timestamp]) as [hour],
       [transaction]
       from
(
select Item_ID,
       dateadd(s,cast([timestamp]as float),'1970-01-01') as [timestamp],
       cast(cost as float) as [transaction]
FROM [dbo].[Items Recycle Data (1)]
where  Item_ID= 406520510
) A
) B
GROUP BY Item_ID,[month], [week],[day],[hour]
)
select *,
       SUM( [total_transaction]) over (partition by [month]) as monthly_transaction,
       SUM( [total_transaction]) over (partition by [week]) as weekly_transaction,
       SUM( [total_transaction]) over (partition by [day]) as daily_transaction,
       SUM( [total_transaction]) over (partition by [hour]) as hour_transaction
       from base_cte
	    order by [month], [week],[day],[hour]


/* 4.Find Unique Users who purchased only Item Categories ‘Sticker’ and ‘Tags’ . */
select [User_ID]
 from
(
select  [User_ID]
		,sum(case when Item_Name like '%Tag%' then 1 else 0 end) as Tag_named_items
		,sum(case when Item_Name like '%Sticker%' then 1 else 0 end) as Sticker_named_items
		,sum(case when Item_Name not like '%Tag%' AND Item_Name not like '%Sticker%' then 1 else 0 end)
		 as not_sticker_tag_named_items
from [dbo].[1562748044_Items Recycle Data (1)]
group by [User_ID]
)as X
 where 
	(Tag_named_items >0 or Sticker_named_items>0)
	and not_sticker_tag_named_items=0
      
/* 5.Find the User_IDs with 
Unique Items >= 3
AND
NOT Purchased any Item_Category = ‘Tag’
AND
Made Purchase on atleast 2 dates
AND
Total Revenue generated >= 300. */
select [User_ID] 
from
(
			select		distinct [User_ID],
						count(distinct(Item_ID))as unique_items,
						sum(cast([Cost] as float))as revenue,
						count(distinct(Timestamp))as count_UNIQUE_DATES
			from		[dbo].[1562748044_Items Recycle Data (1)]
			group by	[User_ID]
			having		count(distinct(Item_ID))>=3
						and sum(cast([Cost] as float))>=300 
						and User_ID not in(select distinct [User_ID]
											from [dbo].[1562748044_Items Recycle Data (1)]
											where Item_Name like '%Tag%')				
							and count(distinct(Timestamp))>=2
)as X


/* 6.For User_ID = ‘__Fe152eaLAzCFwby1MOvzwdfxu3biv2huv-J6hquSg=’,
 find his inventory on day level (i.e. cumulative list of Items on each date).. */

select A.[user_id],
	   B.[Item_id],A.DATES 
	 
	   FROM 
(
select [user_id],
	   [Item_id], 
	   CONVERT( DATE , [DATE],103) AS [DATES],
       ROW_NUMBER() over (order by CONVERT( DATE , [DATE],103) ) as rownumber
FROM  [dbo].[Items Recycle Data (1)]
where  [user_id]='__Fe152eaLAzCFwby1MOvzwdfxu3biv2huv-J6hquSg='
 )A
 inner join
 (
select [user_id],
	   [Item_id], 
	   CONVERT( DATE , [DATE],103) AS [DATES],
       ROW_NUMBER() over (order by CONVERT( DATE , [DATE],103) ) as rownumber
FROM  [dbo].[Items Recycle Data (1)] 
where  [user_id]='__Fe152eaLAzCFwby1MOvzwdfxu3biv2huv-J6hquSg='
 )B
on A.rownumber>= B.rownumber

 
