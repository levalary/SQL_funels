-- filter only that sessions where 
drop table funnel;
create temporary table funnel
select 
	website_session_id,
	sum(case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end) as fuzzy,
	sum(case when pageview_url = '/the-forever-love-bear' then 1 else 0 end) as bear,
	sum(case when pageview_url = '/cart' then 1 else 0 end) as cart,
	sum(case when pageview_url = '/shipping' then 1 else 0 end) as shipping,
	sum(case when pageview_url = '/billing-2' then 1 else 0 end) as billing,
	sum(case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as thank
    
from website_pageviews	
where created_at between '2013-01-06' and '2013-04-10'  and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear', '/cart', '/shipping', '/billing-2', '/thank-you-for-your-order')
group by website_session_id;


-- to fuzzy and to bear %  

drop table funnel_2;
create temporary table funnel_2
select
	website_session_id,
    fuzzy,
    bear,
    cart,
    shipping,
    billing,
    thank,
	case when fuzzy = 1 then 'fuzzy' else 'bear' end as fuzzy_or_bear
from funnel;

create temporary table to_page
select
	fuzzy_or_bear,
	count(website_session_id) as sessions,
	sum(cart) as to_cart,
	sum(shipping) as to_shipping,
	sum(billing) as to_billing,
    sum(thank) as to_thank
from funnel_2
group by fuzzy_or_bear;


-- CTR for each page
select
fuzzy_or_bear,
to_cart/sessions as product_page_CTR,
to_shipping/to_cart as cart_page_CTR,
to_billing/to_shipping as shipping_page_CTR,
to_thank/to_billing as billing_page_CTR
from to_page
order by 1 








-- adding before_or_after date
drop table funnel3;
create temporary table funnel3
select
	funnel_2.website_session_id,
    case when created_at>'2013-01-06' then 'after_launch' else 'before_launch' end as before_or_after,
    products,
    fuzzy,
    bear,
	funnel_2.pct_next_page
from funnel_2
	left join website_sessions 
		on funnel_2.website_session_id=website_sessions.website_session_id;

select 
before_or_after,
count(distinct website_session_id) as sessions,
sum(pct_next_page) as w_nex_page,
sum(pct_next_page)/count(distinct website_session_id) as pct_next_page,
sum(fuzzy) as to_fuzzy,
round(sum(fuzzy)/sum(products)*100,2) as pct_to_fuzzy,
sum(bear) as to_bear,
round(sum(bear)/sum(products)*100,2) as pct_to_bear

from funnel3
group by before_or_after
order by 1 desc;

-- split by time_period


