use modelcarsdb;
select * from customers;
select * from employees;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;

-- task_1
-- 1
select customername,creditlimit from customers order by creditlimit desc limit 10;
-- 2
select country, avg(creditlimit) as average_creditlimit from customers group by country;
-- 3
select state, count(*) as number_of_customers from customers group by state;
-- 4
select customername
from customers c left outer join orders o
on c.customernumber = o.customernumber
where o.ordernumber is null;
-- 5
select customername , sum(amount) as total_sales from customers c join payments p
on c.customernumber = p.customernumber
group by customername;
-- 6
select c.customername, concat(e.firstname, ' ',e.lastname) as employeename from customers c join employees e
on c.salesrepemployeenumber = e.employeenumber;
-- 7
select c.customername, p.paymentdate, p.amount
from customers c
join payments p on c.customernumber = p.customernumber
where p.paymentdate = (
  select max(p2.paymentdate)
  from payments p2
  where p2.customernumber = c.customernumber
);
-- 8
select c.customername, c.creditlimit, 
       sum(od.quantityordered * od.priceeach) as total_orders
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
group by c.customernumber, c.customername, c.creditlimit
having total_orders > c.creditlimit;
-- 9
select distinct c.customername
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
join products p on od.productcode = p.productcode
where p.productline = 'classic cars';
-- 10
select distinct c.customername
from customers c
join orders o on c.customernumber = o.customernumber
join orderdetails od on o.ordernumber = od.ordernumber
join products p on od.productcode = p.productcode
where p.buyprice = (
  select max(buyprice)
  from products
);

/* Task 1 Interpretation:
	This task analyses customer information.
	It checks top credit limits, average credit per country,
	inactive customers, payments made, and customers linked to employees.
	It also finds special cases like over-limit orders or premium buyers.*/

-- task_2
-- 1
select o.officecode, o.city, count(e.employeenumber) as employee_count
from offices o
left join employees e on o.officecode = e.officecode
group by o.officecode, o.city;
-- 2
select o.officecode, o.city, count(e.employeenumber) as employee_count
from offices o
left join employees e on o.officecode = e.officecode
group by o.officecode, o.city
having employee_count < 5;
-- 3
select officecode, city, territory
from offices;
-- 4
select o.officecode, o.city
from offices o
left join employees e on o.officecode = e.officecode
where e.employeenumber is null;
-- 5
select o.officecode, o.city, sum(od.quantityordered * od.priceeach) as totalsales
from offices o
join employees e on o.officecode = e.officecode
join customers c on e.employeenumber = c.salesrepemployeenumber
join orders ord on c.customernumber = ord.customernumber
join orderdetails od on ord.ordernumber = od.ordernumber
group by o.officecode, o.city
order by totalsales desc
limit 1;
-- 6
 select o.officecode, o.city,count(e.employeenumber) as emp_count from employees e
 join offices o on e.officecode = o.officecode
 group by o.officecode, o.city
 order by emp_count desc
 limit 1;
 -- 7
 select e.officecode, o.city, avg(c.creditlimit) as avg_creditlimit from customers c
 join employees e on c.salesrepemployeenumber = e.employeenumber
 join offices o on o.officecode = e.officecode
 group by e.officecode, o.city;
 -- 8
 select country,count(officecode) from offices
 group by country;
 
/* Task 2 Interpretation:
	This task focuses on offices and employees.
	It counts employees per office and filters small or empty offices.
	It calculates total sales per office and finds high-performing branches.
	It shows regional presence and customer credit levels handled by offices.*/

-- task_3
-- 1
select productline, count(productcode) as productcount from products
group by productline;
-- 2
select productline,avg(msrp) as avgprice from products
group by productline
order by avgprice
limit 1;
-- 3
select productcode, productname,msrp from products
where msrp >=50 and msrp <= 100; 
 -- 4
 SELECT p.productLine, SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine;
-- 5
select productCode, productName, quantityInStock from products
where quantityInStock < 10;
-- 6
select productcode,productname,msrp from products
order by msrp desc
limit 1;
-- 7
select p.productCode,p.productname,sum(od.quantityordered*od.priceeach) as total_sales from products p
join orderdetails od on od.productcode=p.productcode
group by p.productCode, p.productname;
-- 8
delimiter //

create procedure gettopsellingproducts(in topn int)
begin
  select p.productcode, p.productname,sum(od.quantityordered) as totalquantity
  from products p
  join orderdetails od on p.productcode = od.productcode
  group by p.productcode, p.productname
  order by totalquantity desc
  limit topn;
end //
delimiter ;

call gettopsellingproducts (5);

-- 9
select productcode, productname, quantityinstock, productline
from products
where quantityinstock < 10
  and productline in ('classic cars', 'motorcycles');
-- 10
select p.productname, count(distinct c.customername) as no_of_customer from products p
join orderdetails od on od.productcode = p.productcode
join orders o on o.ordernumber = od.ordernumber
join customers c on c.customernumber = o.customernumber
group by p.productname
having no_of_customer >10;
-- 11
select p.productcode, p.productname, p.productline,
       sum(od.quantityordered) as totalordered
from products p
join orderdetails od on p.productcode = od.productcode
group by p.productcode, p.productname, p.productline
having totalordered > (
  select avg(totalperproduct)
  from (
    select p2.productline, sum(od2.quantityordered) as totalperproduct
    from products p2
    join orderdetails od2 on p2.productcode = od2.productcode
    where p2.productline = p.productline
    group by p2.productcode
  ) as avgtable
);

/* Task 3 Interpretation:
	This task studies products and sales data.
	It counts products by line, finds average prices,
	checks stock levels, and tracks top-selling products.
	It helps spot low-stock items and highlights strong-selling product lines.*/
