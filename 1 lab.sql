--1. Написать запрос, выводящий всю информацию о департаментах. Упорядочить по коду
--департамента.
--Ответ: 27 строк
select  d.*
  from  departments d
  order by  d.department_id
;
--2. Написать запрос, выбирающий ID, имя+фамилию (в виде одного столбца через пробел)
--и адрес электронной почты всех клиентов. (Использовать конкатенацию строк и
--переименование столбца с именем и фамилией на «NAME»). Упорядочить по коду
--клиента.
--Ответ: 319 строк.
select  c.customer_id as cust_id,
        c.cust_last_name || ' ' || c.cust_first_name as Name,
        c.cust_email
  from  customers c
  order by  cust_id
;
--3. Написать запрос, выводящий сотрудников, зарплата которых за год лежит в диапазоне
--от 100 до 200 тыс. дол., упорядочив их по занимаемой должности, зарплате (от большей
--к меньшей) и фамилии. Выбранные данные должны включать фамилию, имя, должность
--(код должности), email, телефон, зарплату за месяц за вычетом налогов. Будем считать,
--что у нас прогрессивная шкала налогообложения: с зарплаты за год от 100 до 150 тыс.
--дол. налог составляет 30%, выше – 35%. Результат округлить до целого дол.
--Обязательно использовать between и case.
--Ответ: 27 строк
select  e.employee_id,
        e.last_name,
        e.first_name,
        e.job_id,
        e.email,
        e.phone_number,
        case
          when e.salary*12 between 100000 and 150000 then
            round((e.salary - e.salary*0.3))
          when e.salary*12 between 150000 and 200000 then
            round((e.salary - e.salary*0.35))
          end as e_sal
  from  employees e
  where e.salary * 12 between 100000 and 200000
  order by e.job_id,
           e_sal desc,
           e.last_name
;

--4. Выбрать страны с идентификаторами DE, IT или RU. Переименовать столбцы на «Код
--страны», «Название страны». Упорядочить по названию страны.
--Ответ: 2 строки
select c.country_id as "Код_страны",
       c.country_name as "Название_страны"
  from countries c
  where c.country_id ='DE' or c.country_id = 'IT' or c.country_id = 'RU'
  order by  c.country_name
;

--5. Выбрать имя+фамилия сотрудников, у которых в фамилии вторая буква «a» (латинская),
--а в имени присутствует буква «d» (не важно, в каком регистре). Упорядочить по имени.
--Использовать оператор like и функции приведения к нужному регистру.
--Ответ: 5 строк.
select  e.first_name || ' ' || e.last_name as name
  from  employees e
  where (e.last_name like '_a%') and (upper(e.first_name) like '%D%') 
  order by e.first_name
;

--6. Выбрать сотрудников у которых фамилия или имя короче 5 символов. Упорядочить
--записи по суммарной длине фамилии и имени, затем по длине фамилии, затем просто по
--фамилии, затем просто по имени.
--Ответ: 27 строк
select  e.*
  from  employees e
  where (length(e.first_name) < 5) or (length(e.last_name) < 5)
  order by (length(e.first_name) + length(e.last_name)),
            length(e.last_name),
            e.last_name,
            e.first_name
;

--7. Выбрать должности в порядке их «выгодности» (средней зарплаты, за среднюю взять
--среднее-арифметическое минимальной и максимальной зарплат). Более «выгодные»
--должности должны быть первыми, в случае одинаковой зарплаты упорядочить по коду
--должности. Вывести столбцы код должности, название должности, средняя зарплата
--после налогов, округленная до сотен. Считаем шкалу налогообложения плоской – 18%.
--Ответ: 19 строк
select  j.job_id as id,
        j.job_title as title,
        round(((j.max_salary + j.min_salary) / 2) - 0.18*(j.max_salary + j.min_salary) / 2, 2) as mid_salary
  from  jobs j
  order by ((j.max_salary + j.min_salary) / 2) desc,
            j.job_id
;

--8. Будем считать, что все клиенты делятся на категории A, B, C. Категория A – клиенты с
--кредитным лимитом >= 3500, B >= 1000, C – все остальные. Вывести всех клиентов,
--упорядочив их по категории в обратном порядке (сначала клиенты категории A), затем
--по фамилии. Вывести столбцы фамилия, имя, категория, комментарий. В комментарии
--для клиентов категории A должно быть строка «Внимание, VIP-клиенты», для
--остальных клиентов комментарий должен остаться пустым (NULL).
--Ответ: 319 строк.
select  c.*,
        case
          when c.rank = 'A' then
            'Внимание, VIP-клиенты'
        end as "Комментарий"
  from  (
          select  c.cust_last_name,
                  c.cust_first_name,
                  case
                    when c.credit_limit >= 3500  then 
                      'A'
                    when (c.credit_limit >= 1000) and (c.credit_limit < 3500) then 
                      'B'
                    else 
                      'C'
                  end as rank
            from customers c
        ) c
  order by  rank,
            c.cust_last_name
;

--9. Вывести месяцы (их название на русском), в которые были заказы в 1998 году. Месяцы
--не должны повторяться и должны быть упорядочены. Использовать группировку по
--функции extract от даты для исключения дублирования месяцев и decode для выбора
--названия месяца по его номеру. Подзапросы не использовать.
--Ответ: 5 строк
select  decode(
          extract(month from o.order_date),
            1,'Январь',
            2,'Февраль',
            3,'Март',
            4,'Апрель',
            5,'Май',
            6,'Июнь',
            7,'Июль',
            8,'Август',
            9,'Сентябрь',
            10,'Октябрь',
            11,'Ноябрь',
            12,'Декабрь'
          ) as month
  from  orders o
  where date'1998-01-01' <= o.order_date and o.order_date < date'1999-01-01'
  group by extract(month from o.order_date)
  order by extract(month from o.order_date)
;

--10. Написать предыдущий запрос, используя для получения названия месяца функцию
--to_char (указать для функции nls_date_language 3-м параметром). Вместо группировки
--использовать distinct, подзапросы не использовать.
--Ответ: аналогичный предыдущему заданию.
select distinct(to_char(o.order_date,'Month','nls_date_language = RUSSIAN')) as month
  from  orders o
  where date'1998-01-01' <= o.order_date and o.order_date < date'1999-01-01'
  order by to_date(month,'Month','nls_date_language = RUSSIAN')
;

--11. Написать запрос, выводящий все даты текущего месяца. Текущий месяц должен браться
--из sysdate. Второй столбец должен содержать комментарий в виде строки «Выходной»
--для суббот и воскресений. Для определения дня недели воспользоваться функций
--to_char. Для выбора чисел от 1 до 31 можно воспользоваться псевдостолбцом rownum,
--выбирая данные из любой таблицы, где количество строк более 30.
--Ответ: 30 или 31 строка (ну если только задание сдается не в феврале)
select  trunc(sysdate, 'MM') + rownum - 1 as day,
        case
          when to_char(trunc(sysdate, 'MM') + rownum - 1, 'DY', 'nls_date_language = ENGLISH') in ('SAT','SUN')  then
            'Выходной'
        end as comm
    from  customers c
    where rownum <= 31
;

--12. Выбрать всех сотрудников (код сотрудника, фамилия+имя через пробел, код должности,
--зарплата, комиссия - %), которые получают комиссию от заказов. Воспользоваться
--конструкцией is not null.Упорядочить сотрудников по проценту комиссии (от большего к
--меньшему), затем по коду сотрудника.
--Ответ: 35 строк.
select  e.employee_id as emp_id,
        (e.last_name || ' ' || e.first_name) as name,
        e.job_id,
        e.salary,
        e.commission_pct as commis 
  from employees e
  where e.commission_pct is not null
  order by  commis DESC,
            emp_id
;

--13. Получить статистику по сумме продаж за 1995-2000 годы в разрезе кварталов (1 квартал
-- январь-март и т.д.). В выборке должно быть 6 столбцов – год, сумма продаж за 1-ый, 2-
--ой, 3-ий и 4-ый квартала, а также общая сумма продаж за год. Упорядочить по году.
--Воспользоваться группировкой по году, а также суммированием по выражению с case
--или decode, которое будут отделять продажи за нужный квартал.
--Ответ: 5 строк.
select  extract(year from o.order_date) as year, 
        sum(
          case
            when extract(month from o.order_date) <= 3  then o.order_total
          end
        ) as q_sum,
        sum(
          case
            when (3 < extract(month from o.order_date)) and (extract(month from o.order_date) <= 6) then o.order_total
          end
        ) as q2_sum,
        sum(
          case
            when (6 < extract(month from o.order_date)) and (extract(month from o.order_date) <= 9) then o.order_total
           end
        ) as q3_sum,
        sum(
          case
            when (9 < extract(month from o.order_date)) and (extract(month from o.order_date) <= 12) then o.order_total
          end
        ) as q4_sum,
        sum(o.order_total) as all_sum
    from orders o
    group by extract(year from o.order_date)
    having (1995 <= extract(year from o.order_date)) and (extract(year from o.order_date) <= 2000)
    order by year
;

--14. Выбрать из таблицы товаров всю оперативную память. Считать таковой любой товар
--для которого в названии указан размер в MB или GB (в любом регистре), название
--товара не начинается с HD, а также в первых 30 символах описания товара не
--встречаются слова disk, drive и hard. Вывести столбцы: код товара, название товара,
--гарантия, цена (по прайсу – LIST_PRICE), url в каталоге. В поле гарантия должно быть
--выведено целое число – количество месяцев гарантии (учесть, что гарантия может быть
--год и более). Упорядочить по размеру памяти (от большего к меньшему), затем по цене
--(от меньшей к большей). Размер для упорядочивания извлечь из названия товара по
--шаблону NN MB/GB (не забыть при этом сконвертировать GB в мегабайты) c помощью
--regexp_replace. Like не использовать, вместо него использовать regexp_like с явным
--указанием, что регистр букв следует игнорировать.
--Ответ: 24 строки.
select  pi.product_id as p_id,
        pi.product_name as p_name,
        extract(year from pi.warranty_period)*12 + extract(month from pi.warranty_period) as p_garant,
        pi.list_price as p_price,
        pi.catalog_url as p_url
  from product_information pi
  where regexp_like(pi.product_name,'(\d+\s*)(GB|MB)(\s|$)','i') and
        not regexp_like(pi.product_name,'^HD','i') and
        not regexp_like(substr(pi.product_name,1,30),'disk|drive|hard','i')
  order by  case regexp_substr(p_name,'(\d+\s*)(GB|MB)(\s|$)', 1, 1, 'i', 2)
              when  'GB' then
                to_number(regexp_substr(p_name,'(\d+)(\s*)(GB|MB)(\s|$)',1,1,'i',1)) * 1024
              when 'MB' then
                to_number(regexp_substr(p_name,'(\d+)(\s*)(GB|MB)(\s|$)',1,1,'i',1))
            end desc,
            p_price
;

--15. Вывести целое количество минут, оставшихся до окончания занятий. Время окончания
--занятия в запросе должно быть задано в виде строки, например «21:30». Явного указания
--текущей даты в запросе быть не должно. Можно воспользоваться комбинацией функций
--to_char/to_date.
--Ответ: 1 строка (1 число).
select  (to_date('21:30','HH24:MI') - to_date(to_char(sysdate,'HH24:MI'),'HH24:MI'))*24*60 as min
  from dual
;



