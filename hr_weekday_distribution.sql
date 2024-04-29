
use mavenfuzzyfactory;

-- 1 -- pulling only /cart and /shipping pages in a curtain period of time
drop temporary table cart_shop_pageview_funnel;
create temporary table cart_shop_pageview_funnel
select
	website_pageviews.website_session_id,
	min(case when created_at <'2013-09-25' then 'pre' else 'post' end) as time_period,
    max(case when pageview_url = '/cart' then 1 else 0 end) as cart_page,
    max(case when pageview_url = '/shipping' then 1 else 0 end) as shipping_page
from website_pageviews
	where pageview_url in('/cart' ,
     '/shipping')
   and created_at between '2013-08-25' and '2013-10-25' 
group by 1;
    
-- 2 -- joining orders
drop table funnel_joins_orders;
create temporary table funnel_joins_orders
select
	cart_shop_pageview_funnel.website_session_id as cart_sessions,
    time_period,
    cart_page,
    shipping_page,
	orders.order_id,
	orders.items_purchased,
    orders.price_usd,
    orders.cogs_usd
from cart_shop_pageview_funnel
	left join orders
		on cart_shop_pageview_funnel.website_session_id = orders.website_session_id;

-- 3 -- searching metrics, final output
select
	time_period,
	sum(cart_page) as cart_sessions,
	sum(shipping_page) as clickthroughs,
    sum(shipping_page)/sum(cart_page) as cart_ctr,
    avg(items_purchased),
    avg(price_usd) as aov,
    sum(price_usd)/count(distinct cart_sessions) as rev_per_cart_session
from funnel_joins_orders
group by time_period

