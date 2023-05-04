Select * from sample.job_data;

Select Count(job_id)/(30*24) as Total_Jobs_PerHour_PerDay_Nov2020
from Sample.Job_data;
-- group by ds;

Select Count(distinct job_id)/(30*24) as Distinct_Jobs_PerHour_PerDay_Nov2020
from Sample.Job_data;

Select ds , Count(job_id) as Jobs_count
from Sample.Job_data group by ds;

Select ds as Date_reviewed, Jobs_count, avg(jobs_count) 
over(order by ds rows between 6 preceding and current row) as Throughput
from(
Select ds, Count(job_id) as Jobs_count
from Sample.job_data group by ds) as JC;

-- SELECT ds as date_of_review, jobs_reviewed, AVG(jobs_reviewed) 
-- OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 
-- throughput_7_rolling_average
-- FROM 
-- ( 
-- SELECT ds, COUNT( DISTINCT job_id) AS jobs_reviewed
-- FROM sample.job_data
-- GROUP BY ds ORDER BY ds 
-- ) a;
Select ds,Job_count, Total_time_spent, Sum(Job_Count) over (order by ds rows between 6 preceding and current row)/Sum(Total_time_spent) over (order by ds rows between 6 preceding and current row)
  as Throughput_7DayRollingAvg 
from (Select ds,count(job_id) as Job_count , Sum(time_spent) as Total_time_spent from Sample.Job_data group by ds order by ds ) Sub;

Select ds,Distinct_Job_count, Total_time_spent, Sum(Distinct_Job_Count) over (order by ds rows between 6 preceding and current row)/Sum(Total_time_spent) over (order by ds rows between 6 preceding and current row)
  as Throughput_7DayRollingAvg 
from (Select ds,count(distinct job_id) as Distinct_Job_count , Sum(time_spent) as Total_time_spent from Sample.Job_data group by ds order by ds ) Sub;

Select Language,count(language) as Language_Count from sample.job_data group by language;

Select Language,count(language) as Language_Count , 
(count(language)/(select count(*) from Sample.Job_data))*100 as Percentage_share_ofEach_language
from Sample.Job_data
Group by language; 

Select count(language) as Language_Count , Count(language) over () 
from sample.job_data
group by language;

Select count(language) 
from sample.job_data;

Select Language,count(language) as Language_Count , 
(count(language)/(select count(*) from Sample.Job_data))*100 as Percentage_share_ofEach_language
from Sample.Job_data
Group by language; 

Select * , row_number() over (partition by  Job_ID ) Row_Num 
from Sample.job_data;

Select *
from (
Select * , row_number() over (partition by  Job_ID ) Row_Num 
from Sample.job_data) R
where Row_num > 1;
/* 2. Investigating Metric spike */

Select * from Sample.Users;

-- Select  Extract (WEEK FROM created_at) as Week_num , Count(user_id) as User_Num 
-- from sample.users  
-- group by week_num;
Select * from sample.events;

SELECT EXTRACT(MONTH FROM created_at) from sample.users;

Select Extract(Week from occurred_at) as Week_number , Count(distinct user_id) as Num_of_users
from Sample.events 
where event_type = 'engagement'
group by Week_number;

Select distinct event_type from Sample.events;

Select Extract(Year from activated_at) as activation_year , 
	Extract(Month from activated_at) as activation_month ,
    Extract(Week from activated_at) as activation_week
from Sample.users ;

Select Count(distinct user_id)
from Sample.users where state = 'Active';

Select activation_year, 
activation_month ,
activation_week, 
Active_users, 
Sum(Active_users) over (order by activation_year, activation_month, activation_week rows between unbounded preceding and current row ) as Cummulative_active_users
from  (
Select Extract(Year from activated_at) as activation_year , 
	Extract(Month from activated_at) as activation_month , 
    Extract(Week from activated_at) as activation_week,
    Count(distinct user_id) as Active_users 
    from Sample.users 
    where state='Active'
    Group by activation_year , activation_month, activation_week ) Sub;
    
    Select distinct event_name from Sample.Events;
    -- signup 
    select User_id , extract( Week from occurred_at) as Week_Signup
    from Sample.Events 
    where event_type= 'signup_flow' and event_name = 'complete_signup' ;
    -- engagement
    select user_id , extract( Week from occurred_at) as Week_Engagement
    from Sample.Events 
    where event_type = 'Engagement';
    
    
    
    Select signUp.user_id, Engagement.Week_engagement , Signup.week_signup , 
    Engagement.Week_engagement - Signup.week_signup as retention_week
    from (
    (
    select distinct User_id , extract( Week from occurred_at) as Week_Signup
    from Sample.Events 
    where event_type= 'signup_flow' and event_name = 'complete_signup' ) SignUp
    left join 
    (select distinct user_id , extract( Week from occurred_at) as Week_Engagement
    from Sample.Events 
    where event_type = 'Engagement' ) Engagement
    on signUp.user_id = Engagement.user_id 
    )  ;
    -- weekly retention 
    Select user_id , count(user_id) as users_count ,
    Sum(case when retention_week = 1 then 1 else 0 end) as per_week_retention
    from(
    Select signUp.user_id, Engagement.Week_engagement , Signup.week_signup , 
    Engagement.Week_engagement - Signup.week_signup as retention_week
    from (
    (select distinct User_id , extract( Week from occurred_at) as Week_Signup
    from Sample.Events 
    where event_type= 'signup_flow' and event_name = 'complete_signup' ) SignUp
    left join 
    (select distinct user_id , extract( Week from occurred_at) as Week_Engagement
    from Sample.Events 
    where event_type = 'Engagement' ) Engagement
    on signUp.user_id = Engagement.user_id 
    ) 
    ) sub
    group by user_id 
    order by user_id;
    
    Select Extract(Year from occurred_at) as Year_num,
    Extract(week from occurred_at) as Week_num, device,
    count(distinct user_id) as Distinct_User_count
    from sample.events 
    where event_type = 'engagement'
    group by year_num, week_num ,device 
    order by week_num, Distinct_User_count ;
    
    Select * from sample.email_events;
    
    select distinct action from sample.email_events;
    
-- select extract(year from occurred_at) from sample.email_events;

    Select *, case 
		when action in ('sent_weekly_digest','sent_reengagement_email') then 'email_sent'
        when action = 'email_open' then 'email_opened'
		when action = 'email_clickthrough' then 'email_clicked'
		else 'None'
        end as Email_Action_Type
	from sample.email_events;
    
    Select 
    Sum(case when email_status = 'email_opened' then 1 else 0 end)/
		Sum(case when email_status = 'email_sent' then 1 else 0 end) *100.0 as Email_opening_Percentage,
	Sum(case when email_status = 'email_clicked' then 1 else 0 end)/
		Sum(case when email_status = 'email_sent' then 1 else 0 end) *100.0 as Email_clicking_Percentage
	from(
    Select *, case 
		when action in ('sent_weekly_digest','sent_reengagement_email') then 'email_sent'
        when action = 'email_open' then 'email_opened'
		when action = 'email_clickthrough' then 'email_clicked'
		else 'None'
        end as email_status
	from sample.email_events) Sub;

        
    
    
        
        
    
    
    
    
    
    
    
    
    

    






