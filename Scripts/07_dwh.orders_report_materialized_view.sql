--Запрос на удаление MATERIALIZED VIEW. Применять можно при необходимости
--DROP MATERIALIZED VIEW IF EXISTS dwh.orders_report_materialized_view;

CREATE MATERIALIZED VIEW IF NOT EXISTS dwh.orders_report_materialized_view
AS
SELECT 	
		SUM(T1.product_price) 	AS total_money, 	-- сумма денег по всем заказам
		COUNT(T1.product_name)	AS total_products, 	-- количество заказанных товаров
		AVG(T1.craftsman_age) 	AS avg_age_craftsman, -- средний возраст мастера
		AVG(T1.customer_age) 	AS avg_age_customer, -- средний возраст заказчика
		SUM(CASE WHEN T1.order_status = 'created' THEN 1 ELSE 0 END) AS count_order_created, -- количество созданных заказов
		SUM(CASE WHEN T1.order_status IN ('in progress', 'in-progress') THEN 1 ELSE 0 END) AS count_order_in_progress, -- количество заказов в процессе изготовки
		SUM(CASE WHEN T1.order_status = 'delivery' THEN 1 ELSE 0 END) AS count_order_delivery, -- количество заказов в доставке
		SUM(CASE WHEN T1.order_status = 'done' THEN 1 ELSE 0 END) AS count_order_done, -- количество завершённых заказов
		SUM(CASE WHEN T1.order_status != 'done' THEN 1 ELSE 0 END) AS count_order_not_done, -- количество незавершённых заказов
		AVG(T2.diff_order_date) AS avg_days_complete_orders, -- среднее количество дней на выполнение заказа
		PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY T2.diff_order_date) AS median_days_complete_orders, -- медианное количество дней на выполнение заказа
		TO_CHAR(T1.order_created_date, 'yyyy-mm') AS report_period  -- отчётный месяц
	FROM (
		SELECT 	
				fo.order_id AS order_id, 										-- идентификатор заказа
				fo.order_completion_date AS order_completion_date, 				-- дата исполнения заказа
				fo.order_created_date AS order_created_date, 					-- дата создания заказа
				dp.product_price AS product_price, 								-- цена товара
				dp.product_name AS product_name, 								-- название товара
				fo.order_status AS order_status, 								-- статус выполнения заказа
				TO_CHAR(fo.order_created_date, 'yyyy-mm') AS report_period, 	-- год и месяц, по которому будет происходить группировка
				DATE_PART('year', AGE(dc.craftsman_birthday)) AS craftsman_age,	-- возраст мастера
				DATE_PART('year', AGE(dcs.customer_birthday)) AS customer_age 	-- возраст заказчика
				FROM dwh.f_order fo 
				INNER JOIN dwh.d_craftsman dc ON fo.craftsman_id = dc.craftsman_id 
				INNER JOIN dwh.d_customer dcs ON fo.customer_id = dcs.customer_id 
				INNER JOIN dwh.d_product dp ON fo.product_id = dp.product_id 
	) AS T1 -- даём имя T1 таблице, полученной из вложенного запроса выше
		LEFT JOIN ( -- присоединяем таблицу со сроками в днях по всем заказам из вложенного запроса ниже
			SELECT 	
					inner_fo.order_id, -- чтобы выполнить join с таблицей T1
					inner_fo.order_completion_date - inner_fo.order_created_date AS diff_order_date -- количество дней от момента создания заказа до его выполнения
					FROM dwh.f_order inner_fo
						WHERE inner_fo.order_completion_date IS NOT NULL -- из списка всех заказов берём только те, которые завершились и у которых есть дата завершения заказа, чтобы избежать неполных данных в записях
		) AS T2 ON T2.order_id = T1.order_id -- даём имя вложенной таблице с количеством дней на заказ T2 и присоединяем её по order_id к таблице T1
			GROUP BY TO_CHAR(T1.order_created_date, 'yyyy-mm') -- группируем по месяцам итоговую таблицу
            ORDER BY total_money; -- сортируем по сумме денег

-- Запрос, который проверяет, что отчёт не пустой со строкой-примером данных                
 SELECT * FROM dwh.orders_report_materialized_view limit 1;

/*
SELECT order_id, product_id, craftsman_id, customer_id, order_created_date, order_completion_date, order_status, load_dttm
FROM dwh.f_order;

SELECT DISTINCT order_status
FROM dwh.f_order;
*/