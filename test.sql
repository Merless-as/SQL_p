--Вопрос 1.
--Дана таблица NUMS с данными. Какие из следующих запросов вернут ровно 3 записи из этой таблицы
--Ответ: 
SELECT DISTINCT id FROM nums;
SELECT * FROM nums WHERE id <> num;


--Вопрос 2.
--Есть две таблицы
--1) Выбрать всех пользователей из таблицы users, у которых ВСЕ записи в таблице orders
--имеют status = 0
--2) Выбрать всех пользователей из таблицы users, у которых больше 5 записей в таблице
--orders имеют status = 1

--Ответ:
--1)
SELECT NAME 
FROM USERS u JOIN ORDERS o 
  ON u.USER_ID=o.USER_ID 
WHERE STATUS=0 AND 
  USER_ID NOT IN (
    SELCET USER_ID 
    FROM ORDERS 
    WHERE STATUS <> 0 OR 
      STATUS IS NULL
  ); 

--2)
SELECT NAME 
FROM USERS 
WHERE USER_ID IN (
  SELECT USER_ID 
  FROM ORDERS 
  WHERE STATUS=1 
  GROUP BY USER_ID 
  HAVING COUNT(STATUS)>5
  );


--Вопрос 3.
--Есть таблица T
--Написать запрос, который вернет максимальное значение ID и значение даты для этого ID.

--Ответ:
SELECT ID, DT 
FROM T 
WHERE ID = (
  SELECT MAX(ID) 
  FROM T
  );


--Вопрос 4.
--Есть таблицы T1 и T2
--Они не связаны между собой. Сформировать выборку вида: дата, число записей из T1 за этот день, число записей из Т2 за этот день.

--Ответ:
SELECT DT, 
  COUNT(T1.ID), 
  COUNT(T2.ID) 
FROM T1 FULL JOIN T2 
  ON T1.DT=T2.DT 
GROUP BY DT;


--Вопрос 5.
--Есть таблица звонков клиентам (клиент, дата обзвона, номер, длительность разговора)
--Вывести по каждой дате вывести всех клиентов которым осуществлен звонок, с
--указанием, последнего номера телефона на который был осуществлен звонок клиенту в
--течение дня, максимального времени звонка клиенту среди всех контактов за день,
--максимального времени звонка среди всех записей за день

--Ответ:
SELECT DT, CLIENT, 
  LAST_VALUE(PHONENUM) OVER (PATITION BY DT ORDER BY ID), 
  MAX(CALL_DURATION) OVER(PATITION BY DT, CLIENT), 
  MAX(CALL_DURATION) OVER(PARTITION BY DT) 
FROM T 
GROUP BY DT, CLIENT;


--Вопрос 6
--Таблица выданных клиентам кредитов. Клинет, кредит, цель кредита, сумма, дата выдачи
--Необходимо вывести записи таблицы для каждого 4го выданного клиенту кредита, при его
--отсутствии вывести данные для 3го выданного кредита. Кредиты у которых сумма &lt; 10000
--или не заполнена дата выдачи не должны учитываться в подсчете.

--Ответ:
WITH cte AS ( 
  SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY Client_id ORDER BY Credit_id) AS ROWS, 
    COUNT(*) OVER(PARTITION BY Client_id) ) AS COUNT 
  FROM T 
  WHERE Debt_summ >= 10000 AND Start_datetime IS NOT NULL 
)
SELECT Client_id, Redit_id, Credit_purpose, Debt_summ. Start_datetime
FROM cte
WHERE ROWS%(
  CASE
    WHEN COUNT>3
    THEN 4
    ELSE 3
  END
)=0;


--Вопрос 7
--Таблица телефонов клиентов. Клинет, тип телефона, номер, дата добавления
--Необходимо преобразовать к виду
--При наличии нескольких номеров одинакового типа, использовать последний
--добавленный по дате

--Ответ:
SELECT * FROM 
(
  SELECT Client_id, Type_phone 
  FROM Phones
)
PIVOT
(
  Last_Value(Type_phone) OVER (ORDER BY In_datetime)
  FOR (mobile AS 'Номер с типом mobile', home as 'Номер с типом home', work as 'Номер с типом work')
)
ORDER BY Client_id;


--Вопрос 8
--Таблица ставок по депозиту RATES содержит поля: валюта, срок вклада, дата изменения ставки, значение.
--Получить периоды действия каждой ставки в виде CRNC, TERM, RATE, DT_START, DT_END

--Ответ:
--1)
SELECT CRNC, TERM, RATE, 
  DT AS DT_START, 
  DT+TERM AS DT_END
FROM RATES;

--2)
SELECT  CRNC, TERM, RATE, 
  R1.DT DT_START, R2.DT DT_END
FROM RATES R1 JOIN RATES R2 
  ON R2.CRNCR=R1.CRNC, R2.TERM=R1.TERM 
  AND R1.DT<R2.DT;
