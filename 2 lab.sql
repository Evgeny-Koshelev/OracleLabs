--1.Выбрать клиентов, у которых были заказы в июле 1999 года. Упорядочить по коду
--клиента. Использовать внутреннее соединение (inner join) и distinct.
--Ответ: 47 строк
select  distinct(c.customer_id) as cust_id,
        c.cust_last_name||' '||c.cust_first_name as cust_name,
        o.order_date as o_date
  from  customers c
        inner join orders o on
          o.customer_id=c.customer_id
  where date'1999-07-01'<=o.order_date and
        o.order_date<date'1999-08-01'
  order by cust_id
;

--2. Выбрать всех клиентов и сумму их заказов за 2000 год, упорядочив их по сумме заказов
--(клиенты, у которых вообще не было заказов за 2000 год, вывести в конце), затем по ID
--заказчика. Вывести поля: код заказчика, имя заказчика (фамилия + имя через пробел),
--сумма заказов за 2000 год. Использовать внешнее соединение (left join) таблицы
--заказчиков с подзапросом для выбора суммы товаров (по таблице заказов) по клиентам
--за 2000 год (подзапрос с группировкой).
--Ответ: 319 строк
select  c.customer_id as c_id,
        c.cust_first_name || ' ' || c.cust_last_name as c_name,
        o.sum as o_total
  from  customers c
    left join (
      select  o.customer_id,
              sum(o.order_total) as sum
        from  orders o
        where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
        group by o.customer_id
    ) o on
    c.customer_id = o.customer_id
  order by  o.sum desc nulls last,
            c_id
;

--3. Выбрать сотрудников, которые работают на первой своей должности (нет записей в
--истории). Использовать внешнее соединение (какое конкретно?) с таблицей истории, а
--затем отбор записей из таблицы сотрудников таких, для которых не «подцепилось»
--строк из таблицы истории. Упорядочить отобранных сотрудников по дате приема на
--работу (в обратном порядке, затем по коду сотрудника (в обычном порядке).
--Ответ: 100 строк.
select  e.*
  from  employees e
    left join job_history jh on
      e.employee_id = jh.employee_id
  where jh.start_date is null
  order by  e.hire_date desc,
            e.employee_id
;

--4. Выбрать все склады, упорядочив их по количеству номенклатуры товаров,
--представленных в них. Вывести поля: код склада, название склада, количество
--различных товаров на складе. Упорядочить по количеству номенклатуры товаров на
--складе (от большего количества к меньшему), затем по коду склада (в обычном
--порядке). Склады, для которых нет информации о товарах на складе, вывести в конце.
--Подзапросы не использовать.
--Ответ: 9 строк
select  w.warehouse_id w_id,
        w.warehouse_name w_name,
        count(i.product_id) as products_count
  from  warehouses w
    left join inventories i on
      w.warehouse_id = i.warehouse_id
  group by  w.warehouse_id,
            w.warehouse_name
  order by  products_count desc nulls last,
            w_id
;

--5. Выбрать сотрудников, которые работают в США. Упорядочить по коду сотрудника.
--Ответ: 68 строк
select  e.*
  from  employees e
        left join departments d on
          e.department_id=d.department_id
          left join locations l on
            d.location_id=l.location_id
  where l.country_id = 'US'
  order by e.employee_id
;
--6. Выбрать все товары и их описание на русском языке. Вывести поля: код товара,
--название товара, цена товара в каталоге (LIST_PRICE), описание товара на русском
--языке. Если описания товара на русском языке нет, в поле описания вывести «Нет
--описания», воспользовавшись функцией nvl или выражением case (в учебной базе
--данных для всех товаров есть описания на русском языке, однако запрос должен быть
--написан в предположении, что описания на русском языке может и не быть; для
--проверки запроса можно указать код несуществующего языка и проверить, появилось ли
--в поле описания соответствующий комментарий). Упорядочить по коду категории
--товара, затем по коду товара.
--Ответ: 288 строк.
select  pi.product_id pi_id,
        pi.category_id pi_c,
        pi.product_name pi_name,
        pi.list_price pi_price,
        nvl(pd.translated_description, 'Нет описания') as pd_td
  from  product_information pi
        left join product_descriptions pd on
          pd.product_id = pi.product_id and
          pd.language_id = 'RU'
  order by  pi_c,
            pi_id
;

--7. Выбрать товары, которые никогда не продавались. Вывести поля: код товара, название
--товара, цена товара в каталоге (LIST_PRICE), название товара на русском языке (запрос
--должен быть написан в предположении, что описания товара на русском языке может и
--не быть). Упорядочить по цене товара в обратном порядке (товары, для которых не
--указана цена, вывести в конце), затем по коду товара.
--Ответ: 103 строки.
select  pi.product_id pi_id,
        pi.product_name pi_name,
        pi.list_price as pi_price,
        nvl(pd.translated_name, 'Нет названия товара на русском языке') as pd_tn
  from  product_information pi
        left join order_items oi on
          oi.product_id = pi.product_id
        left join product_descriptions pd on
          pd.product_id = pi.product_id and
          pd.language_id = 'RU'
  where  oi.order_id is null
  order by  pi_price desc nulls last,
            pi_id
;

--8. Выбрать клиентов, у которых есть заказы на сумму больше, чем в 2 раза превышающую
--среднюю цену заказа. Вывести поля: код клиента, название клиента (фамилия + имя
--через пробел), количество таких заказов, максимальная сумма заказа. Упорядочить по
--количеству таких заказов в обратном порядке, затем по коду клиента.
--Ответ: 13 строк
select  c.customer_id c_id,
        c.cust_first_name || ' ' || c.cust_last_name as c_name,
        o.huge_sum_count as o_count,
        o.max_sum
  from  customers c
        inner join (
          select  o.customer_id,
                  count(o.order_id) as huge_sum_count,
                  max(o.order_total) as max_sum
            from  orders o
            where o.order_total > (
                    select  avg(o.order_total)
                      from  orders o
                  ) * 2
            group by  o.customer_id
        ) o on
          c.customer_id = o.customer_id
  order by  o_count desc,
            c_id
;

--9. Упорядочить клиентов по сумме заказов за 2000 год. Вывести поля: код клиента, имя
--клиента (фамилия + имя через пробел), сумма заказов за 2000 год. Упорядочить данные
--по сумме заказов за 2000 год в обратном порядке, затем по коду клиента. Клиенты, у
--которых не было заказов в 2000, вывести в конце.
--Ответ: 319 строк
select  c.customer_id c_id,
        c.cust_first_name || ' ' || c.cust_last_name as c_name,
        o.sum_orders as o_sum
  from  customers c
        left join (
          select  o.customer_id,
                  sum(o.order_total) as sum_orders
            from  orders o
            where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
            group by o.customer_id
        ) o on
          c.customer_id = o.customer_id
  order by  o_sum desc nulls last,
            c_id
;

       
--10. Переписать предыдущий запрос так, чтобы не выводить клиентов, у которых вообще не
--было заказов.
--Ответ: 16 строк.
select  c.customer_id c_id,
        c.cust_first_name || ' ' || c.cust_last_name as c_name,
        o.sum_orders as o_sum
  from  customers c
        inner join (
          select  o.customer_id,
                  sum(o.order_total) as sum_orders
            from  orders o
            where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
            group by o.customer_id
        ) o on
          c.customer_id = o.customer_id
  order by  o_sum desc nulls last,
            c_id
;

--11. Каждому менеджеру по продажам сопоставить последний его заказ. Менеджера по
--продажам считаем сотрудников, код должности которых: «SA_MAN» и «SA_REP».
--Вывести поля: код менеджера, имя менеджера (фамилия + имя через пробел), код
--клиента, имя клиента (фамилия + имя через пробел), дата заказа, сумма заказа,
--количество различных позиций в заказе. Упорядочить данные по дате заказа в обратном
--порядке, затем по сумме заказа в обратном порядке, затем по коду сотрудника. Тех
--менеджеров, у которых нет заказов, вывести в конце.
--Ответ: 35 строк
select  e.employee_id as e_id,
        e.last_name || ' ' || e.last_name as e_name,
        c.customer_id as c_id,
        c.cust_last_name || ' ' || c.cust_first_name as c_name,
        o.order_date as o_date,
        o.order_total as o_total,
        oi.items_count
  from  employees e
        left join (
            select  o.sales_rep_id,
                    o.order_date,
                    o.order_total,
                    o.order_id,
                    o.customer_id
              from orders o
              where o.order_date = (
                select  max(o1.order_date)
                  from orders o1
                  where o1.sales_rep_id = o.sales_rep_id
                  )
         ) o on
          e.employee_id = o.sales_rep_id
        left join(
          select  oi.order_id,
                  count(oi.product_id) as items_count
            from order_items oi
            group by oi.order_id
        ) oi on
          oi.order_id = o.order_id
        left join customers c on 
          c.customer_id = o.customer_id
  where e.job_id in ('SA_MAN','SA_REP')
  order by  o_date desc nulls last,
            o_total desc,
            e_id
;

--12. Проверить, были ли заказы, в которых товары поставлялись со скидкой. Считаем, что
--скидка была, если сумма заказа меньше суммы стоимости всех позиций в заказе, если
--цены товаров смотреть в каталоге (прайсе). Если такие заказы были, то вывести
--максимальный процент скидки среди всех таких заказов, округленный до 2 знаков после
--запятой.
--Ответ: 1 строка (1 число)
select  round(max(1 - o.order_total / oi.order_price) * 100, 2) as max_percent
  from  orders o
        inner join (
          select  oi.order_id,
                  sum(pi.list_price * oi.quantity) as order_price
            from  order_items oi
                  inner join product_information pi on
                    oi.product_id = pi.product_id
            group by oi.order_id
        ) oi on
          o.order_id = oi.order_id
  where not o.order_total = oi.order_price
;

--13. Выбрать товары, которые есть только на одном складе. Вывести поля: код товара,
--название товара, цена товара по каталогу (LIST_PRICE), код и название склада, на
--котором есть данный товар, страна, в которой находится данный склад. Упорядочить
--данные по названию стране, затем по коду склада, затем по названию товара.
--Ответ: 12 строк.
select  pi.product_id as pi_id,
        pi.product_name as pi_name,
        pi.list_price as pi_price,
        w.warehouse_id as w_id,
        w.warehouse_name as w_name,
        c.country_name c_name
  from  product_information pi
        inner join(
          select  i.product_id,
                  i.warehouse_id
            from inventories i
            where (select  count(i.warehouse_id)
                    from  inventories inv
                    where inv.product_id = i.product_id
                  ) = 1
        ) i on 
          pi.product_id = i.product_id
        inner join warehouses w on
          i.warehouse_id = w.warehouse_id
        left join locations l on 
          l.location_id = w.location_id
        left join countries c on
          c.country_id = l.country_id
  order by  c_name,
            w_id,
            pi_name
;

--14. Для всех стран вывести количество клиентов, которые находятся в данной стране.
--Вывести поля: код страны, название страны, количество клиентов. Для стран, в которых
--нет клиентов, в качестве количества клиентов вывести 0. Упорядочить по количеству
--клиентов в обратном порядке, затем по названию страны.
--Ответ: 25 строк.
select  c.country_id as c_id,
        c.country_name as c_name,
        count(cust.customer_id) as cust_count
  from  countries c
        left join customers cust on
          cust.cust_address_country_id = c.country_id
  group by  c.country_id,
            c.country_name
  order by  cust_count desc,
            c_name
;

--15. Для каждого клиента выбрать минимальный интервал (количество дней) между его
--заказами. Интервал между заказами считать как разницу в днях между датами 2-х
--заказов без учета времени заказа. Вывести поля: код клиента, имя клиента
--(фамилия + имя через пробел), даты заказов с минимальным интервалом (время не
--отбрасывать), интервал в днях между этими заказами. Если у клиента заказов нет или
--заказ один за всю историю, то таких клиентов не выводить. Упорядочить по коду
--клиента.
--Ответ: 18 строк
select  c.customer_id as c_id,
        c.cust_last_name || ' ' || c.cust_first_name as c_name,
        o1.order_date as o1_date,
        o2.order_date as o2_date,
        abs(trunc(o1.order_date,'DD') - trunc(o2.order_date,'DD')) as interval
  from  customers c
        inner join orders o1 on 
          c.customer_id = o1.customer_id
        inner join orders o2 on
          o1.customer_id = o2.customer_id and
          o1.order_date < o2.order_date
  where abs(trunc(o1.order_date,'DD')-trunc(o2.order_date,'DD')) = (
          select  min(abs(trunc(o1.order_date,'DD') - trunc(o2.order_date,'DD')))
            from  customers c1
                  inner join orders o1 on
                    c1.customer_id = o1.customer_id
                  inner join orders o2 on
                    o1.customer_id = o2.customer_id and
                    o1.order_date < o2.order_date
            where c.customer_id = c1.customer_id
        )
  order by c_id
;








