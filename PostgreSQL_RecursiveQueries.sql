--Interogări recursive în SQL și Cyber. O analiză cantitativă
--COUNT query--
SELECT 
(LENGTH('select * from INNER JOIN') - LENGTH(REPLACE('select * from INNER JOIN', 'INNER JOIN', ''))) / LENGTH('INNER JOIN') AS INNER_JOIN_count,
(LENGTH('select * from INNER JOIN WHERE') - LENGTH(REPLACE('select * from INNER JOIN WHERE', 'WHERE', ''))) / LENGTH('WHERE') AS WHERE_count

--1. Afisarea unei liste cu primii 300 clienti inregistrati incepand cu, clientul 100 (name)
WITH RECURSIVE RSFC (allcustomers, Id) AS (
SELECT CAST ('All customers: ' || c_name AS text), c_custkey
FROM customer
WHERE c_custkey='100'
UNION ALL 
	SELECT CAST (R.allcustomers ||', ' || c_name AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN customer c
	on (R.Id + 1)=c.c_custkey and c.c_custkey <= 400
)
select allcustomers
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--2. Afisarea unei liste cu primii 100 clienti (key-name)
WITH RECURSIVE RSFC (allcustomers, Id) AS (
SELECT CAST ('All customers:' || c_custkey || '-' || c_name AS text), c_custkey
FROM customer
WHERE c_custkey='1'
UNION ALL 
	SELECT CAST (R.allcustomers ||', ' || c_custkey || '-' || c_name AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN customer c
	on (R.Id + 1)=c.c_custkey AND c.c_custkey<=100
)
select allcustomers
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--3. Afisarea unei liste cu numele tuturor regiunilor
WITH RECURSIVE RSFC (allregions, Id) AS (
SELECT CAST ('All regions:' || r_name AS text), r_regionkey
FROM region
WHERE r_regionkey = '0'
UNION ALL 
	SELECT CAST (R.allregions ||', ' || r_name AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN region re
	on (R.Id + 1) = re.r_regionkey
)
select allregions
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--4. Afisarea unei liste cu toate natiunile (key-name)
WITH RECURSIVE RSFC (allnations, Id) AS (
SELECT CAST ('All nations:' || n_nationkey || '-' || n_name AS text), n_nationkey
FROM nation
WHERE n_nationkey='0'
UNION ALL 
	SELECT CAST (R.allnations ||', ' || n_nationkey || '-' || n_name AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN nation n
	on (R.Id + 1) = n.n_nationkey
)
select allnations
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--5. Afisarea unei liste cu numele tuturor natiunilor
WITH RECURSIVE RSFC (allnations, Id) AS (
SELECT CAST ('All nations: ' || n_name AS text), n_nationkey
FROM nation
WHERE n_nationkey='0'
UNION ALL 
	SELECT CAST (R.allnations ||', ' || n_name AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN nation n
	on (R.Id + 1) = n.n_nationkey
)
select allnations
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--6. Afisarea unei liste cu numele tuturor natiunilor (folosind minuscule)
WITH RECURSIVE RSFC (allnations, Id) AS (
    SELECT CAST ('All nations: ' || lower(n_name) AS text), n_nationkey
    FROM nation
    WHERE n_nationkey='0'
    UNION ALL 
    SELECT CAST (R.allnations ||', ' || lower(n_name) AS text), R.Id+1 
    FROM RSFC R 
    INNER JOIN nation n
    ON (R.Id + 1) = n.n_nationkey
)
SELECT allnations
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--7. Afisarea unei liste cu toti furnizorii (key-name)
WITH RECURSIVE RSFC (allsuppliers, Id) AS (
SELECT CAST ('All suppliers: ' || s_suppkey || '-' || UPPER(s_name) AS text), s_suppkey
FROM supplier
WHERE s_suppkey='1'
UNION ALL 
	SELECT CAST (R.allsuppliers ||', ' || s_suppkey || '-' || UPPER(s_name) AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN supplier s
	ON (R.Id + 1)=s.s_suppkey
)
SELECT allsuppliers
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--8. Afisarea unei liste cu primele 100 produse, incepand cu produsul ce are id-ul 30 (id: brand, size)
WITH RECURSIVE RSFC (allproducts, Id) AS (
SELECT CAST ('All products: ' || p_partkey || ': ' || p_brand ||', '|| p_size AS text), p_partkey
FROM part
WHERE p_partkey='30'
UNION ALL 
	SELECT CAST (R.allproducts ||'; ' || p_partkey || ': ' || p_brand ||', '|| p_size AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN part p
	ON (R.Id + 1) = p.p_partkey and p.p_partkey<=130
)
SELECT allproducts
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--9. Afisarea unei liste cu primele 100 produsele (id: brand)
WITH RECURSIVE RSFC (allproducts, Id) AS (
SELECT CAST ('All products: ' || p_partkey || ': ' || p_brand  AS text), p_partkey
FROM part
WHERE p_partkey='1'
UNION ALL 
	SELECT CAST (R.allproducts ||'; ' || p_partkey || ': ' || p_brand AS text), R.Id+1 
	FROM RSFC R 
	INNER JOIN part p
	ON (R.Id + 1) = p.p_partkey and p.p_partkey<=100
)
SELECT allproducts
FROM RSFC
ORDER BY id DESC
LIMIT 1;

--10. Afisarea unei liste cu toate natiunile pe regiuni
WITH RECURSIVE h (RegionId, RegionName, RegionNumber, RegionNo, Lines) AS (
	SELECT r.r_regionkey,r.r_name, n.n_nationkey, 1, CAST (n.n_nationkey || ' - ' ||n.n_name AS VARCHAR(1000))
	FROM nation n
		INNER JOIN region r ON n.n_regionkey = r.r_regionkey
	WHERE (n.n_regionkey , n_nationkey) IN	(
		SELECT n_regionkey, MIN(n_nationkey)
		FROM nation
		GROUP BY n_regionkey)
UNION ALL
	SELECT n.n_regionkey, r.r_name, n_nationkey, h.RegionNo + 1,
		CAST (h.lines || '; ' || n.n_nationkey || ' - ' ||n.n_name AS VARCHAR(1000))
	FROM nation n
		INNER JOIN region r ON n.n_regionkey = r.r_regionkey
		INNER JOIN h ON n.n_regionkey = h.RegionId  AND n.n_nationkey =
			(SELECT MIN(n_nationkey)
			 FROM nation n
			 WHERE n.n_regionkey = h.RegionId AND n_nationkey > h.RegionNumber))
SELECT RegionId, RegionName,lines AS nation_list
FROM h
WHERE (RegionId, RegionNo) IN
	(SELECT RegionId, max(RegionNo)
	FROM h
	GROUP BY RegionId)
ORDER BY 1;

--11. Dintre primele 1000 comenzi, afisati-le pe toate care au aceeasi prioritate (o_orderpriority) ca și comanda X (2 atr selectate)
WITH RECURSIVE RSFC (orderid, orderpriority) AS (
SELECT o_orderkey, o_orderpriority
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey,o.o_orderpriority 
	FROM RSFC R 
	INNER JOIN orders o 
	ON R.orderpriority =o.o_orderpriority and o_orderkey<=1000
)
SELECT orderid , orderpriority as priority_order
FROM RSFC
order by orderid;

--12.  Dintre primele 1000 comenzi, afisati-le pe toate care au aceeasi prioritate (o_orderpriority) ca și comanda X  (toate atr selectate)
WITH RECURSIVE RSFC (o_orderkey, o_custkey, o_orderstatus, o_orderdate, o_orderpriority, o_clerk, o_shippriority, o_comment) AS (
SELECT o_orderkey, o_custkey, o_orderstatus, o_orderdate, o_orderpriority, o_clerk, o_shippriority, o_comment
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o.o_orderkey, o.o_custkey, o.o_orderstatus, o.o_orderdate, o.o_orderpriority, o.o_clerk, o.o_shippriority, o.o_comment 
	FROM RSFC R 
	INNER JOIN orders o
	on R.o_orderpriority =o.o_orderpriority and o.o_orderkey<=1000
)
SELECT o_orderkey AS OrderId, o_custkey as CustomerId, o_orderstatus AS OrderStatus, 
	   o_orderdate AS OrderDate, o_orderpriority AS OrderPriority, o_clerk AS OrderClerk, 
	   o_shippriority AS OrderShippriority, o_comment AS OrderComment
FROM RSFC
order by o_orderkey;

--13. Clientii care au aceeasi natiune ca a clientului X
WITH RECURSIVE RSFC (custid, nation_id, nation_name) AS (
    SELECT c_custkey, c_nationkey, n_name
    FROM customer
	INNER JOIN nation ON customer.c_nationkey=nation.n_nationkey 
    WHERE c_custkey = '1'
    UNION ALL 
    SELECT c.c_custkey, c.c_nationkey, n.n_name
    FROM RSFC R 
    INNER JOIN customer c ON R.nation_id = c.c_nationkey
	INNER join nation n on c.c_nationkey=n.n_nationkey 
    WHERE c.c_custkey <> '1'  
)
SELECT custid, nation_id, nation_name
FROM RSFC
LIMIT 50;

--14. Comenzile cu acelasi status ca și comanda X 
WITH RECURSIVE RSFC (orderid, orderstatus) AS (
SELECT o_orderkey, o_orderstatus
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o.o_orderstatus
	FROM RSFC R INNER JOIN orders o 
	ON R.orderstatus =o.o_orderstatus
)
SELECT orderid as order, orderstatus
FROM RSFC
LIMIT 100;

--15. Comenzile cu același responsabil (o_clerk) ca și comanda X
WITH RECURSIVE RSFC (orderid, clerk) AS (
SELECT o_orderkey, o_clerk
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o.o_clerk
	FROM RSFC R INNER JOIN orders o ON R.clerk =o.o_clerk
)
SELECT orderid as order, clerk
FROM RSFC
LIMIT 100;

--16. Comenzile din acelasi an cu comanda X
WITH RECURSIVE RSFC (orderid, order_date, order_year) AS (
SELECT o_orderkey, o_orderdate, CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate, EXTRACT('YEAR' FROM o_orderdate)
	FROM RSFC R INNER JOIN orders o ON  R.order_year = CAST(EXTRACT('YEAR' FROM o.o_orderdate) AS numeric)
)
SELECT orderid, order_date as Date
FROM RSFC
LIMIT 100;

--17. Comenzile din acelasi an, luna cu comanda X
WITH RECURSIVE RSFC (orderid, order_date, order_year, order_month) AS (
SELECT o_orderkey, o_orderdate, CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric), CAST(EXTRACT('Month' FROM o_orderdate) AS numeric)
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate, EXTRACT('YEAR' FROM o_orderdate), EXTRACT('MONTH' FROM o_orderdate)
	FROM RSFC R INNER JOIN orders o ON ( R.order_year = CAST(EXTRACT('YEAR' FROM o.o_orderdate) AS numeric)
										AND R.order_month = CAST(EXTRACT('MONTH' FROM o.o_orderdate) AS numeric))
)
SELECT orderid, order_date
FROM RSFC;


--18. Comenzile din aceeasi luna cu comanda X
WITH RECURSIVE RSFC (orderid, order_date, order_month) AS (
SELECT o_orderkey, o_orderdate, CAST(EXTRACT('Month' FROM o_orderdate) AS numeric)
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate, EXTRACT('MONTH' FROM o_orderdate)
	FROM RSFC R INNER JOIN orders o ON R.order_month = CAST(EXTRACT('MONTH' FROM o.o_orderdate) AS numeric)
)
SELECT orderid, order_date
FROM RSFC
LIMIT 500;

--19. Comenzile din aceeasi zi cu comanda X
WITH RECURSIVE RSFC (orderid, order_date, order_day) AS (
SELECT o_orderkey, o_orderdate, CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate, EXTRACT('DAY' FROM o_orderdate)
	FROM RSFC R INNER JOIN orders o ON R.order_day = CAST(EXTRACT('DAY' FROM o.o_orderdate) AS numeric)
)
SELECT orderid, order_date
FROM RSFC
LIMIT 500;

--20. Comenzile plasate in acelasi an, luna, zi cu comanda X
WITH RECURSIVE RSFC (orderid, order_date) AS (
SELECT o_orderkey, o_orderdate
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate
	FROM RSFC R INNER JOIN orders o ON R.order_date = o.o_orderdate
)
SELECT orderid, order_date
FROM RSFC;

--21. Comenzile care au acelasi total si sunt plasate in acleasi an cu comanda X
WITH RECURSIVE RSFC (orderid, order_date, order_year, order_total_price) AS (
SELECT o_orderkey, o_orderdate, CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric), o_totalprice
FROM orders
WHERE o_orderkey='1'
UNION 
	SELECT o_orderkey, o_orderdate, order_year, o_totalprice
	FROM RSFC R INNER JOIN orders o ON R.order_total_price = o.o_totalprice 
									AND R.order_year = CAST(EXTRACT('YEAR' FROM o.o_orderdate) AS numeric)
)
SELECT orderid as order, order_date as date, order_total_price as total
FROM RSFC;

--22. Comenzile cu un număr de linii cel putin egal cu numarul de linii din comanda X
WITH RECURSIVE RSFC (orderid, number_of_lines) AS (
SELECT o_orderkey, MAX(l_linenumber)
FROM orders o
	INNER JOIN lineitem l ON o.o_orderkey=l.l_orderkey
GROUP BY o_orderkey
HAVING o_orderkey='1'
UNION 
	SELECT o_orderkey, l.l_linenumber
	FROM orders o 
	INNER JOIN lineitem l ON o.o_orderkey=l.l_orderkey
	INNER JOIN RSFC r ON R.number_of_lines < l.l_linenumber
)
SELECT orderid, number_of_lines
FROM RSFC
WHERE orderid <> 1
LIMIT 1000;

--23. Comenzile cu același număr de linii ca și comanda X
WITH RECURSIVE RSFC (orderid, number_of_lines) AS (
SELECT o_orderkey, MAX(l_linenumber)
FROM orders o
	INNER JOIN lineitem l ON o.o_orderkey=l.l_orderkey
GROUP BY o_orderkey
HAVING o_orderkey='1'
UNION 
	SELECT o_orderkey, l.l_linenumber
	FROM orders o 
	INNER JOIN lineitem l ON o.o_orderkey=l.l_orderkey
	INNER JOIN RSFC r ON R.number_of_lines = l.l_linenumber
)
SELECT orderid, number_of_lines
FROM RSFC
limit 1000;

--24. Comenzile cu același total ca și comanda X
WITH RECURSIVE RSFC (orderid, total) AS (
SELECT o_orderkey, o_totalprice
FROM orders o
where o_orderkey='1'
UNION 
	SELECT o_orderkey, o_totalprice
	FROM orders o 
	INNER JOIN RSFC r ON R.orderid = o.o_orderkey
)
SELECT orderid, total
FROM RSFC
ORDER BY orderid;

--25. Clientii din aceeasi țară cu clientul X
WITH RECURSIVE RSFC (custkey, custname, nationkey, nationname) AS (
SELECT c_custkey, c_name, c_nationkey, n.n_name
FROM customer c
INNER JOIN nation n ON c.c_nationkey=n.n_nationkey
WHERE c_custkey='1'
UNION 
	SELECT c_custkey, c_name, c_nationkey, n.n_name
	FROM RSFC R INNER JOIN customer c ON R.nationkey =c.c_nationkey
	INNER JOIN nation n ON c.c_nationkey=n.n_nationkey
)
SELECT custkey as CustomerId, custname as CustomerName, nationkey as NationId, nationname as NationName
FROM RSFC
WHERE custkey<>'1';

--26. Furnizorii din aceeasi țară cu furnizorul X
WITH RECURSIVE RSFC (supplierkey, suppliername, nationkey, nationname) AS (
SELECT s_suppkey, s_name, s_nationkey, n.n_name
FROM supplier s
INNER JOIN nation n ON s.s_nationkey=n.n_nationkey
WHERE s_suppkey='6'
UNION 
	SELECT s_suppkey, s_name, s_nationkey, n.n_name
	FROM RSFC R INNER JOIN supplier s ON R.nationkey =s.s_nationkey
	INNER JOIN nation n ON s.s_nationkey=n.n_nationkey
)
SELECT supplierkey, suppliername, nationkey, nationname
FROM RSFC;

--27. Furnizorii din aceeasi țară cu clientul X
WITH RECURSIVE RSFC (supplierkey, suppliername, nationkey, nationname) AS (
SELECT c_custkey, c_name, c_nationkey, n.n_name
FROM customer c 
	inner join nation n on c.c_nationkey=n.n_nationkey
WHERE c_custkey='1'
UNION 
	SELECT s_suppkey, s_name, s_nationkey, r.nationname
	FROM RSFC R INNER JOIN supplier s ON R.nationkey =s.s_nationkey
)
SELECT supplierkey AS SupplierId, suppliername AS SupplierName, nationkey AS NationId, nationname AS NationName
FROM RSFC
OFFSET 1;

--28. Furnizorii din aceeasi regiune cu furnizorul X
WITH RECURSIVE RSFC (supplierkey, suppliername, regionkey, regionname) AS (
SELECT s_suppkey, s_name, r_regionkey, r_name
FROM supplier s
INNER JOIN nation n ON s.s_nationkey=n.n_nationkey
INNER JOIN region rg ON rg.r_regionkey=n.n_regionkey
WHERE s_suppkey='3'
UNION 
	SELECT s_suppkey, s_name, r_regionkey, r_name
	FROM RSFC R 
	INNER JOIN region rg ON R.regionkey=rg.r_regionkey
	INNER JOIN nation n ON rg.r_regionkey=n.n_regionkey	
	INNER JOIN supplier s ON s.s_nationkey =n.n_nationkey
)
SELECT supplierkey AS SupplierId, suppliername AS Supplier, regionkey AS RegionId, regionname AS RegionName
FROM RSFC
WHERE supplierkey<>'3'
ORDER BY supplierkey;

--29. Produsele furnizate de furnizori ai produsului X 
WITH RECURSIVE RSFC (supplierkey, keyy, nname) AS (
SELECT s_suppkey, p_partkey, p_name
FROM part p
INNER JOIN partsupp ps ON p.p_partkey=ps.ps_partkey
INNER JOIN supplier s ON s.s_suppkey=ps.ps_suppkey
WHERE p_partkey='3'
UNION 
	SELECT s_suppkey, p_partkey, p_name
	FROM RSFC R 
	INNER JOIN supplier s ON s.s_suppkey=R.supplierkey
	INNER JOIN partsupp ps ON s.s_suppkey=ps.ps_suppkey
	INNER JOIN part p ON p.p_partkey=ps.ps_partkey
)
SELECT supplierkey AS SupplierId, keyy AS ProductId, nname AS ProductName
FROM RSFC
ORDER BY supplierkey, keyy;

--30. Dintre primele 1000 produse inregistrate in sistem, afisati produsele furnizate de țări furnizoare ale produsului X
WITH RECURSIVE RSFC (supplierkey, keyy, nname, nation_key) AS (
SELECT s_suppkey, p_partkey, p_name, n_nationkey
FROM part p
INNER JOIN partsupp ps ON p.p_partkey=ps.ps_partkey
INNER JOIN supplier s ON s.s_suppkey=ps.ps_suppkey
INNER JOIN nation n on n.n_nationkey=s.s_nationkey
WHERE p_partkey='1'
UNION 
	SELECT s_suppkey, p_partkey, p_name, n_nationkey
	FROM RSFC R 
	INNER JOIN nation n on n.n_nationkey=R.nation_key
	INNER JOIN supplier s ON s.s_nationkey=n.n_nationkey
	INNER JOIN partsupp ps ON s.s_suppkey=ps.ps_suppkey
	INNER JOIN part p ON p.p_partkey=ps.ps_partkey and p_partkey<=1000
)
SELECT supplierkey AS SupplierId, keyy AS ProductId, nname AS ProductName
FROM RSFC
ORDER BY supplierkey, keyy;

--31. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Europa, utilizand numele
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
	INNER JOIN region re on n.n_regionkey=re.r_regionkey
    where re.r_name='EUROPE' and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from EU: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter 
)
select customersids
FROM RSFC
order by counter desc
limit 1;

--32. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Europa, utilizand cheia unica
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
	INNER JOIN region re on n.n_regionkey=re.r_regionkey
    where re.r_regionkey=3 and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from EU: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids
FROM RSFC
order by counter desc
limit 1;

--33. Dintre primii 1500 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Franta
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where n.n_name='FRANCE' and c.c_custkey<=1500
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from France: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids AS AllCustomersFromFrance
FROM RSFC
order by counter desc
limit 1;

--34. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Franta sau Germania
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where (n.n_name='FRANCE' or n.n_name='GERMANY') and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from France or Germany: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids as AllCustomersFromFranceAndGermany
FROM RSFC
order by counter desc
limit 1;

--35. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Brazil, Canada, Egypt
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where (n.n_name='BRAZIL' or n.n_name='CANADA' OR n.n_name='EGYPT') and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from Brazil, Canada, Egypt: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids as Customers
FROM RSFC
order by counter desc
limit 1;

--36. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Brazil, Canada, Egypt, Iran
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where (n.n_name='BRAZIL' or n.n_name='CANADA' OR n.n_name='EGYPT' OR n.n_name='IRAN') and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from Brazil, Canada, Egypt, Iran: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids as Customers
FROM RSFC
order by counter desc
limit 1;

--37. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Brazil, Canada, Egypt, Iran folosing UPPER x 2
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where (UPPER(n.n_name)=UPPER('Brazil') or UPPER(n.n_name)=UPPER('Canada') OR UPPER(n.n_name)=UPPER('Egypt') OR UPPER(n.n_name)=UPPER('Iran')) and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from Brazil, Canada, Egypt, Iran: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids as Customers
FROM RSFC
order by counter desc
limit 1;

--38. Dintre primii 1000 clienti inregistrati in sistem, afisati o lista cu toti aceia care provin din Brazil, Canada, Egypt, Iran folosing UPPER x 1
WITH RECURSIVE Liness AS (
SELECT  c.c_custkey AS customerid, ROW_NUMBER() OVER (ORDER BY c_custkey) AS counter
    FROM customer c
	INNER JOIN nation n ON n.n_nationkey=c.c_nationkey
    where (UPPER(n.n_name)='BRAZIL' or UPPER(n.n_name)='CANADA' OR UPPER(n.n_name)='EGYPT' OR UPPER(n.n_name)='IRAN') and c.c_custkey<=1000
),
RSFC (customersids, counter) AS (
SELECT  CAST ('All customers from Brazil, Canada, Egypt, Iran: ' AS text), 0 from Liness 	
UNION ALL 
	SELECT CAST (R.customersids || l.customerid||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
select customersids as Customers
FROM RSFC
order by counter desc
limit 1;

--39. Dintre primele 1000 comenzi inregistrate in sistem, afisati lista comenzilor cu aceiași prioritate (o_orderpriority) ca și comanda X(66)
WITH RECURSIVE Liness AS (
SELECT o.o_orderpriority as orderprior, o.o_orderkey AS orderid, ROW_NUMBER() OVER (ORDER BY o_orderkey) AS counter
    FROM orders o
    WHERE o_orderpriority = (select o_orderpriority from orders where o_orderkey='66')
	and o.o_orderkey <= 1000
),
RSFC (orderprior, orderids, counter) AS (
SELECT orderprior, CAST ('Orders with same priority: ' AS text), 0 from Liness where orderid='66'	
UNION ALL 
	SELECT R.orderprior, CAST (R.orderids || l.orderid ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Liness l
	on (R.counter + 1)=l.counter
)
SELECT orderids as OrdersWithSamePriority
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--40. Dintre primele 1000 comenzi inregistrate in sistem, afisati lista cu toate comenzile care au o medie a discountului egala cu media comenzii X
WITH RECURSIVE Order_AVG_discount AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter,AVG(l_discount)
    FROM lineitem
	GROUP BY l_orderkey
    HAVING ROUND(AVG(l_discount), 2)= (SELECT ROUND(AVG(l_discount), 2) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	and l_orderkey <= 1000
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_discount 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_discount o
	on (R.counter + 1)=o.counter
)
select orderids AS ordersWithSameAVGdiscount
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--41.Dintre primele 1000 comenzi inregistrate in sistem, afisati lista cu toate comenzile care au o medie a discountului mai mica sau egala cu media comenzii X
WITH RECURSIVE Order_AVG_discount AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter,AVG(l_discount)
    FROM lineitem
	GROUP BY l_orderkey
    HAVING ROUND(AVG(l_discount), 2)<= (SELECT ROUND(AVG(l_discount), 2) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=32802)
	and l_orderkey <= 1000
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_discount 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_discount o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--42. Afisarea listei cu toate comenzile care au o medie a cantitatii egala cu media comenzii X
WITH RECURSIVE Order_AVG_qty AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter,AVG(l_quantity)
    FROM lineitem
	GROUP BY l_orderkey
    HAVING ROUND(AVG(l_quantity), 2)= (SELECT ROUND(AVG(l_quantity), 2) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_qty 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_qty o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--43. Dintre primele 2000 comenzi inregistrate in sistem, afisati lista cu toate comenzile care au un numar de produse egal cu al comenzii X
WITH RECURSIVE Order_SUM_qty AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter, SUM(l_quantity)
    FROM lineitem
	GROUP BY l_orderkey
    HAVING SUM(l_quantity)= (SELECT SUM(l_quantity) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	and l_orderkey <= 2000
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_SUM_qty 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_SUM_qty o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--44. Afisarea listei cu toate comenzile clientului X care au un numar de produse egal cu al comenzii X
WITH RECURSIVE Order_SUM_qty AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter, SUM(l_quantity)
    FROM lineitem l 
	INNER JOIN orders o on l.l_orderkey=o.o_orderkey
	GROUP BY l_orderkey, o_custkey
    HAVING SUM(l_quantity)= (SELECT SUM(l_quantity) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	AND o_custkey=370
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_SUM_qty 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_SUM_qty o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--45. Dintre primele 5000 comenzi inregistrate in sistem, afisati lista cu toate comenzile care au un numar de produse egal cu al comenzii X si acelasi order status
WITH RECURSIVE Order_AVG_discount AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter, SUM(l_quantity),o_orderstatus, o_orderpriority
    FROM lineitem l 
	INNER JOIN orders o on l.l_orderkey=o.o_orderkey
	WHERE (o_orderstatus) IN (SELECT o_orderstatus FROM orders WHERE o_orderkey=1)
	GROUP BY l_orderkey, o_custkey,o_orderstatus, o_orderpriority
    HAVING SUM(l_quantity)= (SELECT SUM(l_quantity) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	and l_orderkey <= 5000
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_discount 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_discount o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--46. Afisarea listei cu toate comenzile care au un numar de produse egal cu al comenzii X si acelasi order status, respectiv order priority.
WITH RECURSIVE Order_AVG_discount AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter, SUM(l_quantity),o_orderstatus, o_orderpriority
    FROM lineitem l 
	INNER JOIN orders o on l.l_orderkey=o.o_orderkey
	WHERE (o_orderstatus, o_orderpriority) IN (SELECT o_orderstatus, o_orderpriority FROM orders WHERE o_orderkey=1)
	GROUP BY l_orderkey, o_custkey,o_orderstatus, o_orderpriority
    HAVING SUM(l_quantity)= (SELECT SUM(l_quantity) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_discount 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_discount o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--47. Afisarea listei cu toate comenzile care au un numar de produse egal cu al comenzii X si acelasi order status, order priority, order clerk
WITH RECURSIVE Order_AVG_discount AS (
SELECT  l_orderkey, ROW_NUMBER() OVER (ORDER BY l_orderkey) AS counter, SUM(l_quantity),o_orderstatus, o_orderpriority
    FROM lineitem l 
	INNER JOIN orders o on l.l_orderkey=o.o_orderkey
	WHERE (o_orderstatus, o_orderpriority, o_clerk) IN (SELECT o_orderstatus, o_orderpriority, o_clerk FROM orders WHERE o_orderkey=1)
	GROUP BY l_orderkey, o_custkey,o_orderstatus, o_orderpriority
    HAVING SUM(l_quantity)= (SELECT SUM(l_quantity) FROM lineitem GROUP BY l_orderkey HAVING l_orderkey=1)
	
),
RSFC (orderids, counter) AS (
SELECT  CAST ('All orders: ' AS text), 0 from Order_AVG_discount 	
UNION ALL 
	SELECT CAST (R.orderids ||o.l_orderkey ||', ' AS text), R.counter+1 
	FROM RSFC R INNER JOIN Order_AVG_discount o
	on (R.counter + 1)=o.counter
)
select orderids AS orders
FROM RSFC
ORDER BY counter DESC
LIMIT 1;

--48. Lista tuturor produselor vândute per comanda pentru toti clientii.

WITH RECURSIVE h (OrderId, OrderStatus, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId AS OrderId, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, Customer,max(LineNo)
	FROM h
	GROUP BY OrderId, OrderStatus, Customer)
ORDER BY 1
LIMIT 1000;

--49. Lista tuturor produselor vândute per comanda pentru client X (Client:1036).
WITH RECURSIVE h (OrderId, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, lines AS lines_list
FROM h
WHERE (OrderId, Customer, LineNo) IN
	(SELECT OrderId, Customer, max(LineNo)
	FROM h
	WHERE Customer='1036'
	GROUP BY OrderId, Customer)
ORDER BY 1
LIMIT 1000;

--50. Lista tuturor produselor vândute per comanda pentru clientul X si Y.
WITH RECURSIVE h (OrderId, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, Customer, lines AS lines_list
FROM h
WHERE (OrderId, Customer, LineNo) IN
	(SELECT OrderId, Customer, max(LineNo)
	FROM h
	WHERE Customer='1036' or Customer='1037'
	GROUP BY OrderId, Customer)
ORDER BY 1
LIMIT 1000;

--51. Lista tuturor produselor vândute per comanda pentru clientul X, Y si Z.
WITH RECURSIVE h (OrderId, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, Customer, lines AS lines_list
FROM h
WHERE (OrderId, Customer, LineNo) IN
	(SELECT OrderId, Customer, max(LineNo)
	FROM h
	WHERE Customer='1036' or Customer='1037' or Customer='1039'
	GROUP BY OrderId, Customer)
ORDER BY 1
LIMIT 1000;

--52. Lista produselor vândute, pentru comanda X (Comanda 20199).
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_orderpriority, customer.c_custkey, l_linenumber, 1, CAST ( '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_orderpriority, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer,max(LineNo)
	FROM h
	WHERE OrderId='20198' 
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderPriority, Customer)
ORDER BY 1;

--53. Lista produselor vândute, pentru comanda X si Y.
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_orderpriority, customer.c_custkey, l_linenumber, 1, CAST ( '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_orderpriority, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer,max(LineNo)
	FROM h
	WHERE OrderId='20198' OR OrderId='20199'
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderPriority, Customer)
ORDER BY 1;

--54. Lista produselor vândute, pentru comanda X, Y si Z.
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_orderpriority, customer.c_custkey, l_linenumber, 1, CAST ( '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN (
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_orderpriority, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines || ', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderPriority, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderPriority, Customer,max(LineNo)
	FROM h
	WHERE OrderId='20197' OR OrderId='20198' OR OrderId='20199'
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderPriority, Customer)
ORDER BY 1;

--55. Lista produselor vandute pe comanda, pentru anul 1996
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
limit 1000;

--56. Lista produselor vandute pe comanda, pentru anul 1996 sau 1995
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996 OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1995
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
limit 1000;

--57. Lista produselor vandute pe comanda, pentru anul 1996/1995/1992
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1,CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996 
	      OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1995
	      OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1992
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
limit 1000;

--58. Lista produselor vandute pe comanda, pentru anul 1996 si clientul cu id-ul 370
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1,CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996
	AND Customer = 370
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1;

--59. Lista produselor vandute pe comanda, pentru anul 1996/1995 si clientul cu id-ul 370
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996 
	      OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1995) 
	      AND Customer = 370
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1;

--60. Lista produselor vandute pe comanda, pentru anul 1996/1995 si clientul cu id-ul 370/781
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996 
	      OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1995) 
	      AND (Customer = 370 OR Customer = 781)
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1;


--61. Lista produselor vandute pe comanda, pentru anul 1996/1995/1992 si clientul cu id-ul 370/781/557
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1996 
	      OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1995
		  OR CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric) = 1992) 
	      AND (Customer = 370 OR Customer = 781 OR Customer = 557)
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1;

--62. Lista produselor vandute pe comanda, pentru anul 1996/1995/1992 si clientul cu id-ul 370/781/557 (utilizand clauza IN)
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric)) IN (1996,1995,1992) 
	      AND Customer IN (370,781,557)
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1;

--63. Lista produselor vandute pe comanda, pentru luna iunie
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('MONTH' FROM OrderDate) AS numeric)) = 6 
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
LIMIT 1000;

--64. Lista produselor vandute pe comanda, pentru luna iunie a tuturor anilor cuprinsi intre 1995 si 2000
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer,max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('MONTH' FROM OrderDate) AS numeric)) = 6 
	       AND (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric)) >= 1995 
	       AND (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric)) <= 2000
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
LIMIT 1000;

--65. Lista produselor vandute pe comanda, in perioada 01.1996-08.1996
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, max(LineNo)
	FROM h
	WHERE (CAST(EXTRACT('MONTH' FROM OrderDate) AS numeric)) >= 1
		   AND (CAST(EXTRACT('MONTH' FROM OrderDate) AS numeric)) <= 8
	       AND (CAST(EXTRACT('YEAR' FROM OrderDate) AS numeric)) = 1996 
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
LIMIT 1000;

--66. Lista produselor vândute pe comanda, in perioada prima zi a anului
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, max(LineNo)
	FROM h
	WHERE CAST(EXTRACT('MONTH' FROM OrderDate) AS numeric) = 1
		   AND (CAST(EXTRACT('DAY' FROM OrderDate) AS numeric)) = 1
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
LIMIT 1000;

--67. Lista produselor vandute pe comanda, care sunt in statusul o si au o valoare cuprinsa intre 100-300 mii
WITH RECURSIVE h (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNumber, LineNo, Lines) AS (
	SELECT lineitem.l_orderkey, orders.o_orderstatus,orders.o_totalprice, orders.o_OrderDate, customer.c_custkey, l_linenumber, 1, CAST ('"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
		INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
	WHERE (lineitem.l_orderkey, l_linenumber) IN	(
		SELECT l_orderkey, MIN(l_linenumber)
		FROM lineitem
		GROUP BY l_orderkey)
UNION ALL
	SELECT lineitem.l_orderkey, orders.o_orderstatus, orders.o_totalprice,orders.o_OrderDate, customer.c_custkey, l_linenumber, h.lineno + 1,
		 CAST (h.lines||', '|| '"' || part.p_name || '"' AS VARCHAR(1000))
	FROM orders
		INNER JOIN customer ON orders.o_custkey = customer.c_custkey
		INNER JOIN lineitem ON orders.o_orderkey = lineitem.l_orderkey
	    INNER JOIN partsupp ON lineitem.l_partkey =partsupp.ps_partkey and lineitem.l_suppkey = partsupp.ps_suppkey 
		INNER JOIN part ON partsupp.ps_partkey = part.p_partkey
		INNER JOIN h ON lineitem.l_orderkey = h.orderid  AND lineitem.l_linenumber =
			(SELECT MIN(l_linenumber)
			 FROM lineitem
			 WHERE l_orderkey = h.orderid AND l_linenumber > h.linenumber))
SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, lines AS lines_list
FROM h
WHERE (OrderId, OrderStatus, OrderTotal, OrderDate, Customer, LineNo) IN
	(SELECT OrderId, OrderStatus, OrderTotal, OrderDate, Customer, max(LineNo)
	FROM h
	WHERE OrderStatus = 'O' and ordertotal >= 100000 and ordertotal <= 300000 
	GROUP BY OrderId, OrderStatus, OrderTotal, OrderDate, Customer)
ORDER BY 1
LIMIT 1000;


--68. Afisarea unei liste cu primele 1000 comenzi, per client
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST (o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		where o.o_orderkey <= 1000
)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--69. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 10
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 10: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 2000
	and c.c_custkey=10
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		where o.o_orderkey <= 2000
)
SELECT lines AS OrdersWithSameCustomer
FROM h
ORDER BY 1 desc
limit 1;

--70. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientilor cu id-ul 4, 10
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id ' || c_custkey|| ': '|| o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 2000
	and (c.c_custkey=10 or c.c_custkey=4)
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		where o.o_orderkey <= 2000
)
SELECT lines AS OrdersWithSameCustomer
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY CustomerId;

--71. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientilor cu id-ul 4, 10, 370
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id ' || c_custkey|| ': '|| o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 2000
	and (c.c_custkey=4 or c.c_custkey=10 or c.c_custkey=370)
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
and o.o_orderkey <= 2000)
SELECT lines AS OrdersWithSameCustomer
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY CustomerId;

--72. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor cu id-ul 286, 322, 568, 818, 862
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id ' || c_custkey|| ': '|| o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 1000
	and (c.c_custkey=286 or c.c_custkey=322 or c.c_custkey=568 or c.c_custkey=818 or c.c_custkey=862)
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 1000)
SELECT lines AS OrdersWithSameCustomer
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY CustomerId;

--73. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor cu id-ul cuprins intre [100,150]
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id ' || c_custkey|| ': '|| o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 1000
	and c.c_custkey>=100 AND c.c_custkey<=150 
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 1000)
SELECT lines AS OrdersWithSameCustomer
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY CustomerId;

--74. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor cu id-ul cuprins intre [100,150] sau intre [200,250]
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id ' || c_custkey|| ': '|| o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 1000
	and ((c.c_custkey>=100 AND c.c_custkey<=150) OR (c.c_custkey>=200 AND c.c_custkey<=250)) 
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 1000)
SELECT lines AS OrdersWithSameCustomer
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1;

--75. Afisarea unei liste cu toate comenzile care au un id <=1500 ale clientului cu id-ul 445 ce au fost plasate in anul 1994
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 445: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1994
		GROUP BY o_custkey)
	and o.o_orderkey <= 1500
	and c.c_custkey = 445
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1994
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 1500
)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--76. Afisarea unei liste cu toate comenzile care au un id <=1600 ale clientului cu id-ul 19 care au fost plasate intre anii 1990 si 2000
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 19: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1990
		AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=2000
		GROUP BY o_custkey)
	and o.o_orderkey <= 1600
	and c.c_custkey = 19	
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1990
		     AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=2000
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 1600)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--77. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 352 care au fost plasate in perioada [01.1992;08.1992]
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 352: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=8
		GROUP BY o_custkey)
	and o.o_orderkey <= 2000
	and c.c_custkey = 352
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=8
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 2000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--78. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 352 care au fost plasate in luna a 2-a
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 10: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=2
		GROUP BY o_custkey)
		and o.o_orderkey <= 2000
		and c.c_custkey = 352
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=2
			 AND o_orderkey > h.OrdersNumber)
			and o.o_orderkey <= 2000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--79. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 62 care au fost plasate in prima zi a lunii
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 62: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
		GROUP BY o_custkey)
		and o.o_orderkey <= 2000
		and c.c_custkey = 62
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
			 AND o_orderkey > h.OrdersNumber)
			and o.o_orderkey <= 2000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--80. Afisarea unei liste cu toate comenzile clientului cu id-ul 391 care au fost plasate in prima zi a lunii ianuarie
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 391: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=1
		GROUP BY o_custkey)
	AND c.c_custkey=391
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=1
			 AND o_orderkey > h.OrdersNumber))
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--81. Afisarea unei liste cu toate comenzile clientului cu id-ul 464 care au fost plasate in cea de-a doua zi a lunii februarie 1998
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 464: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=2
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=2
		AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
		GROUP BY o_custkey)
	AND c.c_custkey=464
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=2
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=2
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			 AND o_orderkey > h.OrdersNumber))
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);


--82. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 685 care au fost plasate in prima saptamana a lunii ianuarie 
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 685: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)>=1
		AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)<=7
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=1
		GROUP BY o_custkey)
	    and o.o_orderkey <= 2000
		and c.c_custkey = 685
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)>=1
		     AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)<=7
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)=1
			 AND o_orderkey > h.OrdersNumber)
		and c.c_custkey = 685)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--83. Afisarea unei liste cu toate comenzile care au un id <=2000 ale clientului cu id-ul 685 care au fost plasate in perioada [06.1992;12.1992] sau in perioada [01.1994;06.1994]
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 685: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=6
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=12) OR 
		(CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1994
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=6)
		GROUP BY o_custkey)
	    and o.o_orderkey <= 2000
		and c.c_custkey = 685
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND ( (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=6
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=12) OR 
		(CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1994
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=6) )
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 2000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--84. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor ce poarta numele de xxx (de ex cadou de Sf Andrei, etc)
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND c.c_name LIKE '%001%'
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, c.c_name AS CustomerName, lines AS orders_list
FROM h
INNER JOIN customer c on h.CustomerId=c.c_custkey
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--85. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor ce poarta numele de xxx sau yyy
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST (o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND (c.c_name LIKE '%001%' OR c.c_name LIKE '%002%')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, c.c_name AS CustomerName, lines AS orders_list
FROM h
INNER JOIN customer c on h.CustomerId=c.c_custkey
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--86. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor de natiune japoneza
WITH RECURSIVE h (CustomerId, CustomerName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, c.c_name, o.o_orderkey, 1, CAST (o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
        INNER JOIN nation n on n.n_nationkey=c.c_nationkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND Upper(n.n_name)='JAPAN'
UNION ALL
	SELECT o.o_custkey, c.c_name, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, CustomerName,  lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--87. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor de natiune franceza sau germana
WITH RECURSIVE h (CustomerId, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, n_name, o.o_orderkey, 1, CAST(o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	    INNER JOIN nation n on n.n_nationkey=c.c_nationkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND (Upper(n_name) in ('FRANCE','GERMANY'))
UNION ALL
	SELECT o.o_custkey, h.NationName, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, NationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--88. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor din Europa
WITH RECURSIVE h (CustomerId, RegionName, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, r_name, n_name, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
		INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND Upper(r_name)='EUROPE' 
UNION ALL
	SELECT o.o_custkey, h.RegionName, h.NationName,o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, regionName, nationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId) 
ORDER BY 1
LIMIT 1000;

--89. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor din Europa sau Asia
WITH RECURSIVE h (CustomerId, RegionName, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, r_name, n_name, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
		INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA') 
UNION ALL
	SELECT o.o_custkey, h.RegionName, h.NationName,o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, regionName, nationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId) 
ORDER BY 1
LIMIT 1000;

--90. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor din Europa, Asia sau America
WITH RECURSIVE h (CustomerId, RegionName, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, r_name, n_name, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
		INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
UNION ALL
	SELECT o.o_custkey, h.RegionName, h.NationName,o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, regionName, nationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId) 
ORDER BY 1
LIMIT 1000;

--91. Afisarea unei liste cu toate comenzile care au un id <=1000 ale clientilor din Europa, Asia sau America folosind clauza IN
WITH RECURSIVE h (CustomerId, RegionName, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, r_name, n_name, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
		INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1000
	AND Upper(r_name) IN ('EUROPE','ASIA','AMERICA')
UNION ALL
	SELECT o.o_custkey, h.RegionName, h.NationName,o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, regionName, nationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId) 
ORDER BY 1
LIMIT 1000;

--92. Afisarea unei liste cu toate comenzile clientilor plasate in anul 2000
WITH RECURSIVE h (CustomerId, OrderDate, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderdate, o.o_orderkey, 1, CAST ('id: ' || o.o_orderkey || ', date: ' || o.o_orderdate AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		where CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=2000
		GROUP BY o_custkey)
UNION ALL
	SELECT o.o_custkey, o.o_orderdate, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || 'id: ' || o.o_orderkey || ', date: ' || o.o_orderdate AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=2000 AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber))
SELECT CustomerId, c.c_name as customerName, lines AS orders_list
FROM h
INNER JOIN customer c on h.CustomerId=c.c_custkey
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1;

--93. Afisarea unei liste cu toate comenzile care au un id <=1500 si o valoare mai mare de 200000, per client
WITH RECURSIVE h (CustomerId, CustomerName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, c_name, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		where o_totalprice>200000 
		GROUP BY o_custkey)
	AND o.o_orderkey <= 1500
UNION ALL
	SELECT o.o_custkey, h.CustomerName, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o.o_totalprice>200000 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1500
)
SELECT CustomerId, CustomerName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--94. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa, Asia sau America plasate in anul 1996
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996 
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--95. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa, Asia sau America plasate in anul 1996 sau in 1997
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996 OR CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1997
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996 OR CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1997)
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--96. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa, Asia sau America plasate intre anii 1995 si 1998
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1995
			   AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=1998) 
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1995
				  AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=1998) 
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--97. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa, Asia sau America plasate in primele 3 luni ale anului 1998
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=3
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=3
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--98. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa sau America plasate in primele 5 luni ale anului 1998
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=5
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=5
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--99. Afisarea unei liste cu toate comenzile care au un id <= 1000 ale clientilor din Europa sau America plasate in primele 5 luni ale anului 1998, care au un total mai mare de 40000
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=5
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 1000
	AND o.o_totalprice > 40000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1998
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			  AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=5
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

--100. Afisarea unei liste cu toate comenzile care au un id <= 1500 ale clientilor de natiune franceza sau germana care au un total cuprins intre 20000-40000
WITH RECURSIVE h (CustomerId, NationName, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, n_name, o.o_orderkey, 1, CAST(o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	AND Upper(n_name) in ('FRANCE','GERMANY')
	AND o.o_orderkey <= 1500
	AND o_totalprice>=20000 AND o_totalprice<=50000
UNION ALL
	SELECT o.o_custkey, h.nationname, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_totalprice>=20000 AND o_totalprice<=50000 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 1500)
SELECT CustomerId, nationName, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;


--101. (SAME AS 69) Afisarea unei liste cu toate comenzile care au un id <=10000 ale clientului cu id-ul 10
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ('All orders for customer with id 10: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		GROUP BY o_custkey)
	and o.o_orderkey <= 10000
	and c.c_custkey=10
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId AND o_orderkey > h.OrdersNumber)
		where o.o_orderkey <= 10000
)
SELECT lines AS OrdersWithSameCustomer
FROM h
ORDER BY 1 desc
limit 1;

--102. (SAME AS 76) Afisarea unei liste cu toate comenzile care au un id cuprins intre [353,10000] ale clientului cu id-ul 19 care au fost plasate intre anii 1990 si 2000
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 353, CAST ('All orders for customer with id 19: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1990
		AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=2000
		GROUP BY o_custkey)
	and o.o_orderkey >= 353 and o.o_orderkey <= 10000
	and c.c_custkey = 19	
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)>=1990
		     AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)<=2000
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey >= 353 and o.o_orderkey <= 10000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--103. (SAME AS 77) Afisarea unei liste cu toate comenzile care au un id cuprins intre [1500,9000] ale clientului cu id-ul id-ul 352 care au fost plasate in perioada [01.1992;08.1992]
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1500, CAST ('All orders for customer with id 352: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
		AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=8
		GROUP BY o_custkey)
	and o.o_orderkey <= 9000
	and c.c_custkey = 352
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1992
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)>=1
			 AND CAST(EXTRACT('MONTH' FROM o_orderdate) AS numeric)<=8
			 AND o_orderkey > h.OrdersNumber)
		and o.o_orderkey <= 9000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);

--104. (SAME AS 79) Afisarea unei liste cu toate comenzile care au un id cuprins intre [20000,60000] ale clientului cu id-ul 19 care au fost plasate in prima zi a lunii
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 20000, CAST ('All orders for customer with id 19: ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
		GROUP BY o_custkey)
		and o.o_orderkey <= 60000
		and c.c_custkey = 19
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || '; ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND CAST(EXTRACT('DAY' FROM o_orderdate) AS numeric)=1
			 AND o_orderkey > h.OrdersNumber)
			and o.o_orderkey <= 60000)
SELECT lines AS Orders
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId);
	
--105. (SAME AS 95) Afisarea unei liste cu toate comenzile care au un id <= 5000 ale clientilor din Europa, Asia sau America plasate in anul 1996 sau in 1997
WITH RECURSIVE h (CustomerId, OrdersNumber, OrderNo, Lines) AS (
	SELECT c.c_custkey, o.o_orderkey, 1, CAST ( o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN nation n on n.n_nationkey=c.c_nationkey
        INNER JOIN region r on r.r_regionkey=n.n_regionkey
	WHERE (o.o_custkey , o_orderkey) IN	(
		SELECT o_custkey, MIN(o_orderkey)
		FROM orders
		WHERE CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996 OR CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1997
		GROUP BY o_custkey)
	AND (Upper(r_name)='EUROPE' OR Upper(r_name)='ASIA' OR Upper(r_name)='AMERICA')
	AND o.o_orderkey <= 5000
UNION ALL
	SELECT o.o_custkey, o_orderkey, h.OrderNo + 1,
		CAST (h.lines || ', ' || o.o_orderkey AS VARCHAR(1000))
	FROM orders o
		INNER JOIN customer c ON o.o_custkey = c.c_custkey
		INNER JOIN h ON o.o_custkey = h.CustomerId  AND o.o_orderkey =
			(SELECT MIN(o_orderkey)
			 FROM orders o
			 WHERE o.o_custkey = h.CustomerId 
			 AND (CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1996 OR CAST(EXTRACT('YEAR' FROM o_orderdate) AS numeric)=1997)
			 AND o_orderkey > h.OrdersNumber)
		AND o.o_orderkey <= 5000)
SELECT CustomerId, lines AS orders_list
FROM h
WHERE (CustomerId, OrderNo) IN
	(SELECT CustomerId, max(OrderNo)
	FROM h
	GROUP BY CustomerId)
ORDER BY 1
LIMIT 1000;

