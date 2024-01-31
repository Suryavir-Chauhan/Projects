-- answer 1...What is the total amount each customer spent at the restaurant?

select sales.customer_id as customer, sum(menu.price) as total_price
from sales
join menu
on sales.product_id=menu.product_id
group by sales.customer_id
order by total_price  desc


-- answer 2...How many days has each customer visited the restaurant?

select customer_id as customer, count(distinct(order_date)) as no_of_days_visited
from sales
group by customer_id
order by no_of_days_visited desc


--answer 3...What was the first item from the menu purchased by each customer?
with cte_popular as
(
select sales.customer_id as customer,
	   menu.product_name as product_name,
	   row_number() over
	   (
	   partition by sales.customer_id
	   order by sales.order_date
	   ) as rnk
	   
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
)
select customer,
	   product_name
from cte_popular
where rnk=1




-- answer 4...What is the most purchased item on the menu and how many times was it purchased by all customers?

select top(1) menu.product_name, count(sales.product_id) as total_ordered_item
from menu
join sales
on menu.product_id=sales.product_id
group by menu.product_name
order by total_ordered_item desc



-- answer 5... Which item was the most popular for each customer?
with cte_popular_item
as
(
select sales.customer_id as customer,
	   menu.product_name as product_name,
	   count(sales.product_id) as count_product,
	   rank() over
	   (partition by sales.customer_id
	   order by count(menu.product_id) desc
	   ) as rnk
from sales
join menu on sales.product_id=menu.product_id
group by sales.customer_id,
		 menu.product_name
)
select *
from cte_popular_item
where rnk = 1



--answer 6... Which item was purchased first by the customer after they became a member?

with cte_purchsefirst_aftermember
as
(
select sales.customer_id as customer,
	   menu.product_name as product_name,
	   rank() over
	   (partition by members.customer_id
	   order by sales.order_date asc) 
	   as rnk
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where sales.order_date>=members.join_date
)
select customer, product_name 
from cte_purchsefirst_aftermember
where rnk = 1


-- answer 7... Which item was purchased just before the customer became a member?

with cte_curstomer_purchase
as
(
select sales.customer_id as customer,
	   menu.product_name as product_name,
	   rank() over (
			 partition by sales.customer_id
			 order by sales.order_date desc
			) as rnk
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where members.join_date>sales.order_date

)
select customer,
	   product_name
from cte_curstomer_purchase
where rnk = 1




-- answer 8...What is the total items and amount spent for each member before they became a member?
select sales.customer_id,
	   count(sales.product_id) as no_of_product_sold,
	   sum(menu.price) as Total_price
from sales
join menu 
	on sales.product_id=menu.product_id
join members
	on sales.customer_id=members.customer_id
where sales.order_date<members.join_date
group by sales.customer_id




-- answer 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte_points
as
(
select sales.customer_id as customer,
	   sum
	   (
		case
			when menu.product_name = 'sushi' then (20*menu.price)
			else (10*menu.price)
		end
	   )as total_points

from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
group by sales.customer_id
)
select *
from cte_points



/* answer 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January? */

with cte_points
as
(
select sales.customer_id as customer,
	   sum
	   (
	   case
			when members.join_date
			menu.product_name='sushi' then (menu.price)
			else (2*menu.price)
	   )
)