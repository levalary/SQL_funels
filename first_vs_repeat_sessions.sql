with cte as (select
website_sessions.website_session_id,
orders.order_id,
is_repeat_session,
price_usd

from website_sessions
	left join orders
		on website_sessions.website_session_id=orders.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-11-08')


select
case when is_repeat_session = 0 then 'first_session' else 'repeat_session' end as type_of_session,
count(website_session_id) as sessions,
count(order_id) as orders,
count(order_id)/count(website_session_id) as Conversion_Rate,
sum(price_usd)/count(website_session_id) as revenue_per_session

from cte
group by 1